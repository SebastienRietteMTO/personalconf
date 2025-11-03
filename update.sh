#!/usr/bin/bash

# Script to update repository and install

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
  cd "$(dirname "${BASH_SOURCE[0]}")"
  git pull
  ./install.sh
fi
