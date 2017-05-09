#!/bin/bash

#
# rs-ssh-keys.sh - tool to obtain users' ssh public keys from the RightScale policy file.
#

set -e

# Check that username is provided
if [ $# -eq 0 ]; then
  logger -i -p auth.warn -t rs-ssh-keys.sh "username was not provided and is required"
  exit 1
fi
username=$1

# Grab username info from policy file and exit if it does not exist
policy_username_entry=`grep -E "^$username:|^[0-9a-z_\-]*:$username:" /var/lib/rightlink/login_policy` || true
if [[ "$policy_username_entry" == "" ]]; then
  # Not in policy file
  exit 0
fi
read preferred_name unique_name policy_uid <<< $(echo $policy_username_entry | cut -d: -f1,2,4 --output-delimiter=' ')

# Grab username info from system
system_username_entry=`getent passwd ${username}` || true
if [[ "$system_username_entry" == "" ]]; then
  # At this point, user from policy file should be returned. If nothing or error is returned, exit 1 with no keys.
  logger -i -p auth.warn -t rs-ssh-keys.sh "issue searching for username: ${username}"
  exit 1
fi
read system_uid <<< $(echo $system_username_entry | cut -d: -f3 --output-delimiter=' ')

# Determine if the entry found has matching system UID.
# If there is another user from another NSS plugin, this is not our user, so return no keys.
if [[ "$system_uid" == "$policy_uid" ]]; then
  # User is from policy file so get and set keys
  logger -i -p auth.info -t rs-ssh-keys.sh "username '${username}' matches entry in login policy - sending keys"
  echo $policy_username_entry | cut -d: -f7- | tr : "\n"
else
  logger -i -p auth.warn -t rs-ssh-keys.sh "username '${username}' matches another NSS method - not using login policy keys"
fi
