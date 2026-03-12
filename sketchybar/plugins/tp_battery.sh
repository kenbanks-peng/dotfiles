#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

battery=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | awk '
  /Product.*=.*"Magic Trackpad"/ { found = 1 }
  /BatteryPercent/ { if (found) { print $NF "%"; exit } }
')

if [ -n "$battery" ]; then
  sketchybar -m --set "$NAME" label="$battery"
fi
