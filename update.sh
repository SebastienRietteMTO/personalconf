#!/usr/bin/bash

# Script to update repository and install
# The script can be run more frequently than the desired frequency
# We check the time elapsed since to determine whether to perform
# the update.

# The script must output nothing on success (to not send emails when
# run by cron).

function usage {
  echo "Usage: $0 [-h] [--daily] [--hourly]"
}

delay=0
while [ -n "$1" ]; do
  case "$1" in
    '-h') usage; exit;;
    '--daily') delay=86400;;
    '--hourly') delay=3600;;
    *) usage; exit 1;;
  esac
  shift
done

if [ ! -f ~/.personalconf_last_update ]; then
  delay=0
  touch ~/.personalconf_last_update
fi
if [ $(($(date +%s) - $(date -r ~/.personalconf_last_update +%s))) -ge $delay ]; then
  touch ~/.personalconf_last_update
  cd "$(dirname "${BASH_SOURCE[0]}")"
  commit=$(git rev-parse HEAD)
  output=$(git pull 2>&1)
  if [ $? -ne 0 ]; then
    echo "${output}"
    exit 2
  fi
  if [ $(git rev-parse HEAD) != $commit ]; then
    # Only perform installation if the repository has been updated
    output="${output} $(./install.sh)"
    if [ $? -ne 0 ]; then
      echo "${output}"
      exit 3
    fi
  fi
fi
