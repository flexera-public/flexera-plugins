#! /bin/bash

# ---
# RightScript Name: RL10 Linux Shutdown Reason
# Description: Print out the reason for shutdown.
# Inputs: {}
# Attachments: []
# ...
#

# We pull the runlevel or equivalent from the init system and call it
# os_decom_reason. os_decom_reason possible values are:
#   shutdown = system is halting, powering off, or going into single user mode
#   reboot = system is rebooting
#   service_restart = service was restarted
#
# We pull the reason RightScale thinks the instance is going down and put it in
# rs_decom_reason. Note that this variable will only be populated if we issue a
# stop/terminate/reboot from either the RightScale dashboard or the API. It will
# be empty if we shutdown or rebooted at the command line, or if a shutdown/reboot
# was issued on the cloud provider's console. Note we can't tell if a terminate
# was issued on a cloud provider's console, as we just know the system is going
# down. rs_decom_reason possible values are:
#   stop = instance is being stopped/shutdown but disk persists
#   terminate = instance is being destroyed/deleted
#   reboot = instance is being rebooted
#
# DECOM_REASON synthesizes the two values. We export this value as an environment
# parameter so subsequent scripts in the decommission bundle may have use it. The
# following values are possible:
#   stop
#   terminate
#   reboot
#   service_restart

# Determine location of rsc
[[ -e /usr/local/bin/rsc ]] && rsc=/usr/local/bin/rsc || rsc=/opt/bin/rsc

echo "Decommissioning. Calculating reason for decommission: "

rs_decom_reason="$($rsc --retry=5 --timeout=10 rl10 show /rll/proc/shutdown_kind)"
os_decom_reason=service_restart # Our default
if [[ `systemctl 2>/dev/null` =~ -\.mount ]] || [[ "$(readlink /sbin/init)" =~ systemd ]]; then
  # Systemd doesn't use runlevels, so we can't rely on that
  jobs="$(systemctl list-jobs)"
  echo "$jobs" | egrep -q 'reboot.target.*start'   && os_decom_reason=reboot
  echo "$jobs" | egrep -q 'halt.target.*start'     && os_decom_reason=shutdown
  echo "$jobs" | egrep -q 'poweroff.target.*start' && os_decom_reason=shutdown
else
  # upstart, sysvinit, or unknown system. The current runlevel should tell us what's up
  [[ `runlevel | cut -d ' ' -f 2` == "6" ]]   && os_decom_reason=reboot
  [[ `runlevel | cut -d ' ' -f 2` =~ 0|1|S ]] && os_decom_reason=shutdown
fi

case "$os_decom_reason" in
reboot|service_restart)
  decom_reason=$os_decom_reason
  ;;
shutdown)
  if [[ "$rs_decom_reason" == "terminate" ]]; then
    decom_reason=terminate
  else
    decom_reason=stop
  fi
  ;;
esac

echo "  OS decommission reason is: $os_decom_reason"
echo "  RightScale decommission reason is: $rs_decom_reason"
echo "  Combined DECOM_REASON is: $decom_reason"
echo ""
echo "exporting DECOM_REASON=$decom_reason into the environment for subsequent scripts"
$rsc --retry=5 --timeout=10 rl10 update /rll/env/DECOM_REASON payload=$decom_reason
