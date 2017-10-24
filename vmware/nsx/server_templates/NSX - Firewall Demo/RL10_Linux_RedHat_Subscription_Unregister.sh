#!/bin/bash

# ---
# RightScript Name: RL10 Linux RedHat Subscription Unregister
# Description: Unregister a RedHat instance from the RedHat subscription service
# Inputs: {}
# Attachments: []
# ...

set -e

# Read/source os-release to obtain variable values determining OS
if [[ -e /etc/os-release ]]; then
  source /etc/os-release
# RHEL 6 does not use os-release, so use redhat-release
elif [[ -e /etc/redhat-release ]]; then
  # Assumed format example: Red Hat Enterprise Linux Server release 6.8 (Santiago)
  if [[ $(cut -d" " -f1-5 /etc/redhat-release) == "Red Hat Enterprise Linux Server" ]]; then
    ID="rhel"
  fi
else
  echo "Unable to determine OS as /etc/os-release or /etc/redhat-release does not exist"
fi
if [[ "$ID" != "rhel" ]]; then
  echo "RedHat Subscription Management is only used by RedHat Linux"
  exit 0
fi

# Continue unregistartion if DECOM_REASON is not given (manual run of script) or if we are terminating the server
if [[ -z "$DECOM_REASON" ]]; then
  echo "Not a decommission script - continuing with unregistration"
elif [[ "$DECOM_REASON" == "terminate" ]]; then
  echo "Terminating server - continuing with unregistration"
else
  echo "Decommission reason of '$DECOM_REASON' does not require unregistering from RedHat Subscription"
  exit 0
fi

# Unregister server if currently registered
unregister_retries=5
while true; do
  unset subscription_status_fail_code
  unset unregister_status_fail_code
  subscription_status=$(sudo subscription-manager identity 2>&1 ) || { subscription_status_fail_code=$?; }
  if [[ -z $subscription_status_fail_code ]]; then
    # System is registered
    unregister_status=$(sudo subscription-manager unregister 2>&1 ) || { unregister_status_fail_code=$?; }
    if [[ -z $unregister_status_fail_code ]]; then
      echo "System now unregistered"
      break
    else
      echo "Unexpected error on unregistration ($unregister_status $unregister_status_fail_code) - retring"
    fi
  else
    if [[ $subscription_status == *"This system is not yet registered."* ]]; then
      echo "System already unregistered"
      break
    else
      echo "Unexpected error occurred ($subscription_status $subscription_status_fail_code) - retrying"
    fi
  fi
  (( unregister_retries-- ))
  if [[ $unregister_retries -gt 0 ]]; then
    sleep 2
  else
    echo "Exceeded maximum retries"
    exit 1
  fi
done
