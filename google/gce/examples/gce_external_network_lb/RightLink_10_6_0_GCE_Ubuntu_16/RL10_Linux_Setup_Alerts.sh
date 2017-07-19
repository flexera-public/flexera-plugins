#!/bin/bash
# ---
# RightScript Name: RL10 Linux Setup Alerts
# Description: |
#   Set up the RightScale Alerts on the instance to match the metrics that it is actually reporting with either built-in
#   RightLink monitoring or collectd. The RightScale Alerts on this ServerTemplate are set to match the metrics reported
#   by the built-in RightLink monitoring and collectd 5, but there are a few metrics which have names which vary based
#   on the system they are running and there are also some metrics which have different names with collectd 4 which is
#   used on older Linux distribution versions (such as Ubuntu 12.04 and CentOS 6).
# 
#   The alerts that need to be set up by this script are:
# 
#   * **rs low space in root partition**: If a Linux system is running collectd 4, the metric used for this alert will
#     be set to `df/df-root.free` rather than `df-root/df_complex-free.value`.
#   * **rs high network tx activity** and **rs high network rx activity**: On newer Linux distribution versions (such as
#     CoreOS and Ubuntu 16.04) the network interface name is not necessarily `eth0` and there may be more network
#     interfaces on the system, so this script will update and add the alerts to match the network interfaces on the
#     system.
#   * **rs low swap space**: If no swap is set up on a Linux system, no swap metrics will be sent. If you enable swap on
#     the system at a later point, this script can be rerun to re-enable the alert.
# Inputs:
#   MONITORING_METHOD:
#     Category: RightScale
#     Description: |
#       Determine the method of monitoring to use, either RightLink monitoring or collectd. Setting to
#       'auto' will use code to select method.
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: text:auto
#     Possible Values:
#     - text:auto
#     - text:collectd
#     - text:rightlink
# Attachments: []
# ...

set -e

# Create an alert spec on the instance based on a template alert spec from the ServerTemplate with optional parameter
# overrides.
#
# $1: the alert spec template name
# $2: the instance name to append to the template name which is used to name the new alert spec
# $@: the rest of the arguments are parameter name and override value pairs for the new alert spec
#
function create_alert_spec() {
  local template_name="$1"
  local name="$template_name $2"
  shift 2 # remove the first two arguments from $@
  echo -n "creating alert spec '$name' from '${template_name}': "
  if [[ $# -ne 0 ]]; then
    echo -n 'overriding '
    local -i index=0
    for override in "$@"; do
      if [[ $(((index += 1) % 2)) -eq 1 ]]; then
        echo -n "$override="
      else
        echo -n "'$override' "
      fi
    done
    echo -n '... '
  fi

  # check in the alert specs to see if the one we want to create is already created
  if rsc json --x1 "object:has(.name:val(\"$name\"))" <<<"$alert_specs" 1>/dev/null 2>&1; then
    echo 'already exists'
    return
  fi

  # create an associative array of the parameters with our new name and all of the other parameters from the template
  # alert spec
  local -A parameters=([name]="$name")
  for parameter in condition description duration escalation_name file threshold variable vote_tag vote_type; do
    value=`rsc json --x1 "object:has(.name:val(\"$template_name\")).$parameter" <<<"$alert_specs" 2>/dev/null || true`
    if [[ -n "$value" ]]; then
      parameters[$parameter]="$value"
    fi
  done

  # iterate through the rest of the arguments to override any parameters
  while [[ $# -gt 0 ]]; do
    local parameter="$1"
    local value="$2"
    parameters[$parameter]="$value"
    shift 2 # remove these two arguments from $@
  done

  # transform the associative array of parameters into an array of arguments for rsc
  local -a arguments
  for parameter in "${!parameters[@]}"; do
    arguments[${#arguments[@]}]="alert_spec[$parameter]=${parameters[$parameter]}"
  done

  # use rsc to create the new alert spec with the parameters as arguments
  rsc --rl10 cm15 create "$RS_SELF_HREF/alert_specs" "${arguments[@]}"
  echo 'created'
}

# Destroy an alert if the matching alert spec is defined on the ServerTemplate or destroy an alert spec if it is defined
# on the instance. No action will be taken if the alert or alert spec has already been destroyed or does not otherwise
# exist.
#
# $1: the name of the alert spec to destroy the alert for or to just destroy
#
function destroy_alert_or_alert_spec() {
  local name="$1"
  echo -n "destroying alert or alert spec '$name' from instance: ... "

  # check if the alert or alert spec has already been destroyed
  if ! alert_for_alert_spec_exists "$name"; then
    echo 'already destroyed'
    return
  fi

  # destroy the alert if the alert spec is inherited from the ServerTemplate or delete the alert spec otherwise
  if [[ $subject_href =~ ^/api/server_templates/[^/]+$ ]]; then
    alert_href=`rsc json --xj "object:has(.href:val(\"$alert_spec_href\")) ~ object" <<<"$alerts" | rsc json --x1 'object:has(.rel:val("self")).href'`
    rsc --rl10 cm15 destroy "$alert_href"
  else
    rsc --rl10 cm15 destroy "$alert_spec_href"
  fi

  echo 'destroyed'
}

# Check if an alert for an alert spec exists on the instance.
#
# $1: the name of the alert spec to check for
#
# Output variables:
#
# alert_spec_href: the HREF of the named alert spec
# subject_href:    the HREF of the subject of the named alert spec
#
function alert_for_alert_spec_exists() {
  local name="$1"

  # get the alert spec and subject HREFs for the named alert spec
  alert_spec_href=`rsc json --x1 "object:has(.name:val(\"$name\")) object:has(.rel:val(\"self\")).href" <<<"$alert_specs" 2>/dev/null`
  subject_href=`rsc json --x1 "object:has(.name:val(\"$name\")) object:has(.rel:val(\"subject\")).href" <<<"$alert_specs" 2>/dev/null`

  # check if the alert spec HREF was found
  if [[ -n $alert_spec_href ]]; then
    if [[ $subject_href =~ ^/api/server_templates/[^/]+$ ]]; then
      # the subject of the alert spec is a ServerTemplate so the alert spec is inherited
      # check if there is an alert for the alert spec
      if rsc json --x1 "object:has(.href:val(\"$alert_spec_href\"))" <<<"$alerts" 1>/dev/null 2>&1; then
        # an alert for the alert spec exists
        return 0
      else
        # there is no alert for the alert spec
        return 1
      fi
    else
      # the alert spec is not inherited from the ServerTemplate and it exists so it definitely exists
      return 0
    fi
  else
    # there was no alert spec HREF found so the named alert spec does not exist
    return 1
  fi
}

# Ensure rsc is in the path
export PATH="/usr/local/bin:/opt/bin:$PATH"

# Determine what mode to use if MONITORING_METHOD is set to 'auto'
if [[ "$MONITORING_METHOD" == "auto" ]]; then
  # Currently, the only criteria to automatically use RightLink monitoring is if OS is CoreOS
  if grep -iq "id=coreos" /etc/os-release 2> /dev/null; then
    monitoring_method="rightlink"
  else
    monitoring_method="collectd"
  fi
else
  monitoring_method=$MONITORING_METHOD
fi

# Determine which network interfaces exist excluding lo so we can update alert specs
interfaces=(`ip -o link | awk '{ sub(/:$/, "", $2); if ($2 != "lo") { print $2; } }'`)

# Determine if swap is enabled
if [[ $(sudo swapon -s | wc -l) -gt 1 ]]; then
  swap=1
else
  swap=0
fi

# get all of the alert specs and alerts defined on the instance; these variables are used with rsc json by the above
# functions instead of making individual API calls to query this data
alert_specs=`rsc --rl10 cm15 index "$RS_SELF_HREF/alert_specs" with_inherited=true`
[[ -z "$alert_specs" ]] && alert_specs='{}'
alerts=`rsc --rl10 cm15 index "$RS_SELF_HREF/alerts"`
[[ -z "$alerts" ]] && alerts='{}'

if [[ $swap -eq 0 ]]; then
  # if swap is not enabled, remove the swap alert
  destroy_alert_or_alert_spec 'rs low swap space'
  destroy_alert_or_alert_spec 'rs low swap space recreated'
else
  # if swap was previously disabled, recreate the alert now that it is enabled
  if ! alert_for_alert_spec_exists 'rs low swap space' && ! alert_for_alert_spec_exists 'rs low swap space recreated'; then
    create_alert_spec 'rs low swap space' recreated
  fi
fi

disable_eth0=1 # by default remove the original network alert specs
reenable_eth0=0 # by default do not create new network alert specs for eth0
interface_file='interface-eth0/if_octets' # this is the format for the network metric for collectd 5 and built-in

if [[ $monitoring_method == collectd && "$(collectd -h)" =~ "collectd 4" ]]; then
  # change the root partition alert to use the collectd4 metric
  destroy_alert_or_alert_spec 'rs low space in root partition'
  create_alert_spec 'rs low space in root partition' 'collectd4' file df/df-root variable free

  reenable_eth0=1 # since the metric for interfaces is different on collectd 4, the alert specs needs to be redefined
  interface_file='interface/if_octets-eth0' # this is the format for the network metric for collectd 4
fi

for interface in "${interfaces[@]}"; do
  # if the interface is eth0 and the network does not need to be redefined, do not create a new alert spec
  if [[ "$interface" == eth0 && $reenable_eth0 -eq 0 ]]; then
    echo -e "keeping 'rs high network tx activity'\nkeeping 'rs high network rx activity'"
    disable_eth0=0 # since the eth0 interface exists do not remove the original network alerts
    continue
  fi

  # add network alert specs for this network interface by replacing eth0 in the network metric format with the actual
  # interface name
  create_alert_spec 'rs high network tx activity' "$interface" file "${interface_file/eth0/$interface}"
  create_alert_spec 'rs high network rx activity' "$interface" file "${interface_file/eth0/$interface}"
done

# if there is no eth0 interface or the network alerts needed to be redefined for collectd 4, remove the original alerts
if [[ disable_eth0 -eq 1 ]]; then
  destroy_alert_or_alert_spec 'rs high network tx activity'
  destroy_alert_or_alert_spec 'rs high network rx activity'
fi
