#! /bin/bash -e

# ---
# RightScript Name: RL10 Linux Setup Hostname
# Description: |
#   Changes the hostname of the server.
# 
#   ## Known Limitations:
#   On AzureRM, the Azure Linux Agent (waagent) may change the hostname if it has not finished provisioning the server after boot.
# Inputs:
#   SERVER_HOSTNAME:
#     Category: RightScale
#     Description: The server's hostname is set to the longest valid prefix or suffix
#       of this variable. E.g. 'my.example.com V2', 'NEW my.example.com', and 'database.io
#       my.example.com' all set the hostname to 'my.example.com'. Set to an empty string
#       to avoid any change to the hostname.
#     Input Type: single
#     Required: false
#     Advanced: true
#     Default: blank
# Attachments: []
# ...
#

# The server's hostname is set to the longest valid prefix or suffix of
# this SERVER_HOSTNAME variable eg 'my.example.com V2', 'NEW my.example.com', and
# 'database.io my.example.com' all set the hostname to 'my.example.com'.
# If SERVER_HOSTNAME is empty, will maintain current hostname.

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

# Ensure rsc is in the path
export PATH="/usr/local/bin:/opt/bin:$PATH"

# Give warning about the possibility of waagent on AzureRM changing the hostname again after this script
current_cloud_href=$(rsc --retry=5 --timeout=60 --rl10 cm15 index_instance_session /api/sessions/instance --x1 ':has(.rel:val("cloud")).href' 2>/dev/null || true)
cloud_type=$(rsc --retry=5 --timeout=60 --rl10 cm15 --x1='.cloud_type' show $current_cloud_href 2>/dev/null || true)
if [[ $cloud_type == "azure_v2" ]]; then
  echo "WARNING: waagent on AzureRM may change the hostname after this script is completed!"
  echo "See http://docs.rightscale.com/clouds/azure_resource_manager/reference/limitations.html#azure-linux-agent for more details"
fi

if [[ -n "$SERVER_HOSTNAME" ]]; then
  prefix=
  suffix=

  re='^[-A-Za-z0-9_][-A-Za-z0-9_.]*[-A-Za-z0-9_]( #[0-9]+){0,1}'
  if [[ "$SERVER_HOSTNAME" =~ $re ]]; then
    prefix=${BASH_REMATCH[0]}
    echo "prefix set to ${prefix}"
  fi

  re='[-A-Za-z0-9_][-A-Za-z0-9._]*[-A-Za-z0-9_]( #[0-9]+){0,1}$'
  if [[ "$SERVER_HOSTNAME" =~ $re ]]; then
    suffix=${BASH_REMATCH[0]}
    echo "suffix set to ${suffix}"
  fi

  if (( ${#prefix} >= ${#suffix} && ${#prefix} > 1 )); then
    echo "Setting hostname to prefix '$prefix'"
    hostname="$prefix"
  elif (( ${#suffix} > 1 )); then
    echo "Setting hostname to suffix '$suffix'"
    hostname="$suffix"
  fi

  #
  # Check for a numeric suffix (like in a server array)
  # example:  array_name #1
  # and convert into:  array_name-1
  #
  if [ $( echo $hostname | grep "#" -c ) -gt 0 ]; then
    numeric_suffix=$( echo $hostname | cut -d'#' -f2 )
    hostname=$( echo $hostname | cut -d'#' -f1 )
    echo "Find array numeric suffix '$numeric_suffix'"

    sname=$(echo $hostname | cut -d'.' -f 1)
    dname=${hostname#"$sname"}
    hostname="$sname-$numeric_suffix$dname"
  fi

  # Set the hostname and make it persist across reboots, etc.
  # If we are on a system with hostnamectl, it will take care of all that, but if not there are several ways that the
  # hostname may be stored.
  if type -P hostnamectl >/dev/null; then
    # even if hostnamectl is available, dbus might not be available so we install it
    if ! type -P dbus-daemon >/dev/null; then
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

      case "${ID,,}" in
      ubuntu|debian)
        retry_command sudo apt-get update
        retry_command sudo apt-get install -y dbus
        ;;
      centos|fedora|rhel)
        retry_command sudo yum install -y dbus
        sudo chkconfig dbus on
        sudo service dbus start
        ;;
      esac
    fi

    # CentOS 7, CoreOS, and Ubuntu 14+ all use hostnamectl!
    sudo hostnamectl set-hostname "$hostname"
  else
    if [[ -f /etc/sysconfig/network ]]; then
      # CentOS 6 (and probably RHEL 6 as well) uses the /etc/sysconfig/network file to store the hostname
      if grep --quiet '^HOSTNAME=' /etc/sysconfig/network; then
        sudo sed --expression="s/^HOSTNAME=.*$/HOSTNAME=$hostname/" --in-place /etc/sysconfig/network
      else
        echo "HOSTNAME=$hostname" | sudo tee -a /etc/sysconfig/network
      fi
    else
      # Ubuntu 12 uses /etc/hostname to store the hostname
      echo "$hostname" | sudo tee /etc/hostname
    fi
    sudo hostname "$hostname"
  fi

  # At least on CentOS 7, cloud-init can sometimes also try to manage the hostname, so configure cloud-init to not
  # change the hostname
  preserve_hostname='preserve_hostname: true'
  if [[ -d /etc/cloud/cloud.cfg.d ]]; then
    echo "$preserve_hostname" | sudo tee /etc/cloud/cloud.cfg.d/99_preserve_hostname.cfg
  elif [[ -f /etc/cloud/cloud.cfg ]] && ! grep --quiet "$preserve_hostname" /etc/cloud/cloud.cfg; then
    echo "$preserve_hostname" | sudo tee -a /etc/cloud/cloud.cfg
  fi
fi

# This works around spurious warnings generated by sudo if the hostname can't resolve.
# /etc/sudoers is designed to be able to be distributed among multiple servers.
# Each permission in the /etc/sudoers has a host portion. Sudo does a hostname
# lookup to enforce the host portion, and will throw a warning if it can't
# resolve the hostname in some way.

hostname=$(hostname)
if ! grep "$hostname" /etc/hosts >/dev/null 2>&1; then
  echo "Adding $hostname to /etc/hosts"
  echo "127.0.0.1 $hostname" | sudo tee -a /etc/hosts
fi
