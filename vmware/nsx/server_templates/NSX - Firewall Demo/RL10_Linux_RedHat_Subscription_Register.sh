#!/bin/bash

# ---
# RightScript Name: RL10 Linux RedHat Subscription Register
# Description: Register a RedHat instance with the RedHat subscription service and enable
#   additional repos
# Inputs:
#   REDHAT_ACCOUNT_USERNAME:
#     Category: RightScale
#     Description: RedHat Account Username
#     Input Type: single
#     Required: false
#     Advanced: true
#     Default: blank
#   REDHAT_ACCOUNT_PASSWORD:
#     Category: RightScale
#     Description: RedHat Account Password
#     Input Type: single
#     Required: false
#     Advanced: true
#     Default: blank
#   REDHAT_ADDITIONAL_REPOS:
#     Category: RightScale
#     Description: Space separated list of additional RHEL repos to enable.
#     Input Type: single
#     Required: false
#     Advanced: true
#     Default: blank
# Attachments: []
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

# If REDHAT_ACCOUNT_USERNAME or REDHAT_ACCOUNT_PASSWORD is not set, exit
if ([[ -z $REDHAT_ACCOUNT_USERNAME ]] || [[ -z $REDHAT_ACCOUNT_PASSWORD ]]); then
  echo "Username and/or password is not set - continuing without registration"
  exit 0
fi

# Install subscription-manager
if ! type -P subscription-manager > /dev/null; then
  retry_command sudo yum --assumeyes install subscription-manager
fi

# Register server if not already
subscription_status_retries=5
while true; do
  unset failed_exit_code
  subscription_status=$(sudo subscription-manager identity 2>&1) || { failed_exit_code=$?; }
  if [[ -z $failed_exit_code ]]; then
    echo "System is already registered"
    break
  else
    if [[ $subscription_status == *"This system is not yet registered."* ]]; then
      retry_command sudo subscription-manager register --username $REDHAT_ACCOUNT_USERNAME --password $REDHAT_ACCOUNT_PASSWORD --auto-attach
      echo "System has been registered"
      break
    else
      # Unexpected error such as network connectivity issues - retry
      (( subscription_status_retries-- ))
      if [ $subscription_status_retries -gt 0 ]; then
        echo "Unexpected error occurred ($subscription_status - $failed_exit_code) - retrying"
        sleep 2
      else
        echo "Exceeded maximum retries"
        exit 1
      fi
    fi
  fi
done

# Remove source and debug repos by default. Not needed for cloud servers in general.
echo "Disabling any source/debug repos"
source_debug_repos=$(sudo subscription-manager repos --list-enabled | grep 'Repo ID' | grep -E 'debug-rpms|source-rpms' | awk '{print $3}' 2>&1)
for repo in $source_debug_repos; do
  sudo subscription-manager repos --disable=$repo
done

# Enable additional repos if provided
for repo in $REDHAT_ADDITIONAL_REPOS; do
  echo "enabling additional repo - $repo"
  retry_command sudo subscription-manager repos --enable=$repo
done
