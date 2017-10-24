#!/bin/bash

# ---
# RightScript Name: RL10 Linux Enable Docker Support (Beta)
# Description: |
#   Enable RightLink Docker features if docker is installed
# Inputs:
#   RIGHTLINK_DOCKER:
#     Category: RightLink
#     Description: |
#       Level of Docker integration for RightLink: monitoring + tagging; tagging; nothing.
#     Input Type: single
#     Required: true
#     Advanced: true
#     Default: text:all
#     Possible Values:
#     - text:all
#     - text:tags
#     - text:none
# Attachments: []
# ...

set -e

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

if ! command_exists docker; then
  echo "Docker is not installed - skipping enabling of docker support"
  exit
fi

# Check for group of socker
socket=/var/run/docker.sock
docker_group=`stat --format=%G $socket`

# Add rightlink user to docker_group
if ! id --groups --name rightlink | grep --quiet "${docker_group}"; then
  echo "Adding rightlink to '${docker_group}' group"
  sudo usermod --append --groups ${docker_group} rightlink
fi

# Determine location of rsc
[[ -e /usr/local/bin/rsc ]] && rsc=/usr/local/bin/rsc || rsc=/opt/bin/rsc

# Enable docker support
$rsc --retry=5 --timeout=10 rl10 update /rll/docker/control "enable_docker=$RIGHTLINK_DOCKER"
