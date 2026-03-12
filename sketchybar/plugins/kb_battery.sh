#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

battery=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | awk '
  /ProductID/ { pid = $NF }
  /BatteryPercent/ { if (pid == 666) { print $NF "%"; exit } }
')

if [ -n "$battery" ]; then
  sketchybar -m --set "$NAME" label="$battery"
fi
