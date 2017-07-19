#!/bin/bash

# ---
# RightScript Name: RL10 Linux Enable Managed Login
# Description: |
#   Enable does install of RightScale NSS plugin, and update of PAM and SSH configuration to
#   allow SSH connectivity to RightScale accounts. Disable undoes enablement.
# Inputs:
#   MANAGED_LOGIN:
#     Category: RightScale
#     Description: To enable or disable managed login.  Default is 'enable'.
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: text:auto
#     Possible Values:
#     - text:auto
#     - text:enable
#     - text:disable
# Attachments:
# - rs-ssh-keys.sh
# - rightscale_login_policy.te
# - libnss_rightscale.tgz
# ...

set -e

# Run passed-in command with retries if errors occur.
#
# $@: full line command
#
function retry_command() {
  # Setting config variables for this function
  retries=5
  wait_time=10

  while [ $retries -gt 0 ]; do
    # Reset this variable before every iteration to be checked if changed
    issue_running_command=false
    $@ || { issue_running_command=true; }
    if [ "$issue_running_command" = true ]; then
      (( retries-- ))
      echo "Error occurred - will retry shortly"
      sleep $wait_time
    else
      # Break out of loop since command was successful.
      break
    fi
  done

  # Check if issue running command still existed after all retries
  if [ "$issue_running_command" = true ]; then
    echo "ERROR: Unable to run: '$@'"
    return 1
  fi
}

# Read/source os-release to obtain variable values determining OS
if [[ -e /etc/os-release ]]; then
  source /etc/os-release
else
  # CentOS/RHEL 6 does not use os-release, so use redhat-release
  if [[ -e /etc/redhat-release ]]; then
    # Assumed format example: CentOS release 6.7 (Final)
    ID=$(cut -d" " -f1 /etc/redhat-release)
    VERSION_ID=$(cut -d" " -f3 /etc/redhat-release)
  else
    echo "ERROR: /etc/os-release or /etc/redhat-release is required but does not exist"
    exit 1
  fi
fi
ID="${ID,,}" # convert to lowercase

# Determine location of rsc
[[ -e /usr/local/bin/rsc ]] && rsc=/usr/local/bin/rsc || rsc=/opt/bin/rsc

# Determine lib_dir and bin_dir location
if [[ "$ID" == "coreos" ]]; then
  lib_dir="/opt/lib"
  bin_dir="/opt/bin"
else
  lib_dir="/usr/local/lib"
  bin_dir="/usr/local/bin"
fi

if ! $rsc rl10 actions 2>/dev/null | grep --ignore-case --quiet /rll/login/control; then
  echo "This script must be run on a RightLink 10.5 or newer instance"
  exit 1
fi

if [[ "$MANAGED_LOGIN" == "auto" ]]; then
  if [[ "$ID" == "coreos" ]]; then
    echo "Managed login is not supported on CoreOS. Not setting up managed login."
    managed_login="disable"
  else
    managed_login="enable"
  fi
else
  managed_login=$MANAGED_LOGIN
fi

case "$managed_login" in
enable)
  if [[ "$ID" == "coreos" ]]; then
    echo "Managed login is not supported on CoreOS. MANAGED_LOGIN must be set to 'disabled' or 'auto'."
    exit 1
  fi

  echo "Enabling managed login"

  # Ubuntu 12.04 has a version of OpenSSH that does not allow AuthorizedKeysCommand. Instead use AuthorizedKeysFile.
  if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "12.04" ]]; then
    ssh_config_entry="AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2 /var/lib/rightlink_keys/%u"
    rll_login_control="compat"
    if sudo cut --delimiter=# --fields=1 /etc/ssh/sshd_config | grep --invert-match "${ssh_config_entry}" | grep --quiet "AuthorizedKeysFile\b"; then
      echo "AuthorizedKeysFile already in use. This is required to continue - exiting without configuring managed login"
      exit 1
    elif sudo cut --delimiter=# --fields=1 /etc/ssh/sshd_config | grep --quiet "${ssh_config_entry}"; then
      echo "AuthorizedKeysFile already setup"
      ssh_previously_configured="true"
    fi
  else
    # sshd does not have a version flag, but it does give a version on its error message for an invalid POSIX flag
    sshd_version=`sshd -V 2>&1 | grep "^OpenSSH" | cut --delimiter=' ' --fields=1 | cut --delimiter='_' --fields=2`
    ssh_config_entry="AuthorizedKeysCommand ${bin_dir}/rs-ssh-keys.sh"
    rll_login_control="on"
    if sudo cut --delimiter=# --fields=1 /etc/ssh/sshd_config | grep --invert-match "${ssh_config_entry}" | grep --quiet "AuthorizedKeysCommand\b"; then
      echo "AuthorizedKeysCommand already in use. This is required to continue - exiting without configuring managed login"
      exit 1
    elif sudo cut --delimiter=# --fields=1 /etc/ssh/sshd_config | grep --quiet "${ssh_config_entry}"; then
      echo "AuthorizedKeysCommand already setup"
      ssh_previously_configured="true"
    fi
    # OpenSSH version 6.2 and higher uses AuthorizedKeysCommand and requires AuthorizedKeysCommandUser
    if [[ "$(printf "$sshd_version\n6.2" | sort --version-sort | tail --lines=1)" == "$sshd_version" ]]; then
      ssh_config_entry+="\nAuthorizedKeysCommandUser nobody"
    fi
  fi

  if [[ "$ssh_previously_configured" != "true" ]]; then
    # Generate SSH staging config and test that the config is valid. If valid, just copy the staging config later.
    sshd_staging_config=$(mktemp /tmp/sshd_config.XXXXXXXXXX)
    sudo cp -a /etc/ssh/sshd_config $sshd_staging_config
    sudo bash -c "echo -e '\n${ssh_config_entry}' >> $sshd_staging_config"
    # Test staging sshd_config file
    if ! `sudo sshd -t -f $sshd_staging_config`; then
      echo "sshd_config changes are invalid - exiting without configuring managed login"
      exit 1
    fi
  fi

  # Check that pam config for sshd exists
  if [ ! -e /etc/pam.d/sshd ]; then
    echo "Unable to determine location of required PAM sshd configuration - exiting without configuring managed login"
    exit 1
  fi

  # Verify /var/lib/rightlink directory was created during install of RL10. Create if missing.
  # It may be missing due to upgrade.
  if [ ! -d /var/lib/rightlink ]; then
    echo "Expected /var/lib/rightlink directory - creating"
    sudo install --directory --group=rightlink --owner=rightlink --mode=0755 /var/lib/rightlink
  fi

  # Create /var/lib/rightlink_keys directory created if set to 'compat'
  if [[ "$rll_login_control" == "compat" ]]; then
    sudo install --directory --group=root --owner=root --mode=0755 /var/lib/rightlink_keys
  fi

  # Install $bin_dir/rs-ssh-keys.sh
  echo "Installing ${bin_dir}/rs-ssh-keys.sh"
  attachments=${RS_ATTACH_DIR:-attachments}
  sudo install --target-directory=${bin_dir} --group=root --owner=root --mode=0755 ${attachments}/rs-ssh-keys.sh

  # Copy staging sshd_config file
  if [[ "$ssh_previously_configured" != "true" ]]; then
    sudo mv $sshd_staging_config /etc/ssh/sshd_config
    # Determine if service name is ssh or sshd
    case "$ID" in
    ubuntu|debian)
      ssh_service_name='ssh'
      ;;
    *)
      ssh_service_name='sshd'
      ;;
    esac
    sudo service ${ssh_service_name} restart
  fi

  # Create /etc/sudoers.d/90-rightscale-sudo-users
  if [ -e /etc/sudoers.d/90-rightscale-sudo-users ]; then
    echo "Sudoers file already exists"
  else
    echo "Creating sudoers file"
    sudo bash -c "umask 0337 && printf '# Members of the rightscale_sudo group may gain root privileges\n%%rightscale_sudo ALL=(ALL) SETENV:NOPASSWD:ALL\n' > /etc/sudoers.d/90-rightscale-sudo-users"
  fi

  # Update pam config to create homedir on login
  if cut --delimiter=# --fields=1 /etc/pam.d/sshd | grep --quiet pam_mkhomedir; then
    echo "PAM config /etc/pam.d/sshd already contains pam_mkhomedir"
  else
    echo "Adding pam_mkhomedir to /etc/pam.d/sshd"
    sudo bash -c "printf '# Added by RightScale Managed Login script\nsession required pam_mkhomedir.so skel=/etc/skel/ umask=0022\n' >> /etc/pam.d/sshd"
  fi

  # Update nsswitch.conf
  if cut --delimiter=# --fields=1 /etc/nsswitch.conf | grep --quiet rightscale; then
    echo "/etc/nsswitch.conf already configured"
  else
    echo "Configuring /etc/nsswitch.conf"
    sudo sed -i '/^\(passwd\|group\|shadow\)/ s/$/ rightscale/' /etc/nsswitch.conf
  fi

  # Install NSS plugin library. This has been designed to overwrite existing library.
  sudo mkdir -p /etc/ld.so.conf.d ${lib_dir}
  sudo tar --no-same-owner -xzf ${attachments}/libnss_rightscale.tgz -C ${lib_dir}
  sudo bash -c "echo ${lib_dir} > /etc/ld.so.conf.d/rightscale.conf"
  sudo ldconfig

  # Configure selinux to allow sshd and pam to read the login policy file at
  # /var/lib/rightlink/login_policy. This policy adds the following rules, as
  # well as make the user's homedir on the fly.
  if which sestatus >/dev/null 2>&1; then
    if sudo sestatus | grep enabled >/dev/null 2>&1; then
      # install checkmodule if it is not installed
      if ! which checkmodule >/dev/null 2>&1; then
        case "$ID" in
        ubuntu|debian)
          retry_command sudo apt-get install -y checkpolicy
          ;;
        centos|fedora|rhel)
          retry_command sudo yum install -y checkpolicy
          ;;
        esac
      fi

      # install semodule_package if it is not installed
      if ! which semodule_package >/dev/null 2>&1; then
        case "$ID" in
        ubuntu|debian)
          retry_command sudo apt-get install -y policycoreutils
          ;;
        centos|fedora|rhel)
          retry_command sudo yum install -y policycoreutils-python
          ;;
        esac
      fi

      policy_file="${attachments}/rightscale_login_policy.te"
      installed_version=$(sudo semodule -l | grep rightscale_login_policy | awk '{print $2}' | sed 's/\.//')
      desired_version=$(grep module $policy_file | awk '{print $3}' | sed 's/[\.;]//g')
      if [[ "$desired_version" == "$installed_version" ]]; then
        echo "rightscale_login_policy selinux policy already installed, skipping re-installation."
      else
        echo "Installing selinux policy to support reading of login policy file and creation of homedir"
        checkmodule -M -m -o rightscale_login_policy.mod $policy_file
        semodule_package -m rightscale_login_policy.mod -o rightscale_login_policy.pp
        sudo semodule -i rightscale_login_policy.pp
      fi
    fi
fi

  # Send enable action to RightLink
  $rsc --retry=5 --timeout=10 rl10 update /rll/login/control "enable_login=${rll_login_control}"

  # Adding rs_login:state=user tag
  $rsc --retry=5 --timeout=60 --rl10 cm15 multi_add /api/tags/multi_add resource_hrefs[]=$RS_SELF_HREF tags[]=rs_login:state=user
  ;;
disable)
  if [[ "$ID" == "coreos" ]]; then
    exit 0
  fi

  echo "Disabling managed login"

  # Remove rs_login:state=user tag
  $rsc --retry=5 --timeout=60 --rl10 cm15 multi_delete /api/tags/multi_delete resource_hrefs[]=$RS_SELF_HREF tags[]=rs_login:state=user

  # Send disable action to RightLink
  $rsc --retry=5 --timeout=10 rl10 update /rll/login/control "enable_login=off"

  # Remove NSS plugin library files
  sudo rm -frv $lib_dir/libnss_rightscale.*
  sudo rm -frv /etc/ld.so.conf.d/rightscale.conf
  sudo ldconfig

  # Remove rightscale NSS plugin from /etc/nsswitch.conf
  sudo sed -i '/^\(passwd\|group\|shadow\)/ s/\s\?rightscale\s*/ /; s/\s*$//' /etc/nsswitch.conf

  # Remove pam_mkhomedir line from /etc/pam.d/sshd
  sudo sed  -i '/^# Added by RightScale Managed Login script$/ {N; /^#.*session required pam_mkhomedir.so skel=\/etc\/skel\/ umask=0022$/d}' /etc/pam.d/sshd

  # Remove sudoers file
  sudo rm -frv /etc/sudoers.d/90-rightscale-sudo-users

  # Remove AuthorizedKeysCommand and AuthorizedKeysCommandUser from sshd_config
  sudo sed -i '/^AuthorizedKeysCommand \/usr\/local\/bin\/rs-ssh-keys.sh$/d' /etc/ssh/sshd_config
  sudo sed -i '/^AuthorizedKeysCommandUser nobody$/d' /etc/ssh/sshd_config
  sudo sed -i '/^AuthorizedKeysFile .ssh\/authorized_keys .ssh\/authorized_keys2 \/var\/lib\/rightlink_keys\/%u$/d' /etc/ssh/sshd_config

  # Remove rs-ssh-keys.sh
  sudo rm -frv $bin_dir/rs-ssh-keys.sh

  # Remove /var/lib/rightlink folder
  sudo rm -frv /var/lib/rightlink/

  # Remove /var/lib/rightlink_keys folder
  sudo rm -frv /var/lib/rightlink_keys/

  # Remove rightscale managed login selinux policy
  if which sestatus >/dev/null 2>&1; then
    if sudo sestatus | grep enabled >/dev/null 2>&1; then
      if sudo semodule -l | grep rightscale_login_policy >/dev/null 2>&1; then
        sudo semodule -r rightscale_login_policy
      fi
    fi
  fi
  ;;
*)
  echo "Unknown action: $managed_login"
  exit 1
  ;;
esac
