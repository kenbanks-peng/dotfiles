#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

percentage=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | awk '
  /ProductID/ { pid = $NF }
  /BatteryPercent/ { if (pid == 666) { print $NF; exit } }
')

if [ -n "$percentage" ]; then
  color="$SAPPHIRE"
  case ${percentage} in
    9[0-9] | 100) label="$ICON_BATTERY_4" ;;
    [6-8][0-9])   label="$ICON_BATTERY_3" ;;
    [3-5][0-9])   label="$ICON_BATTERY_2" ;;
    [1-2][0-9])   label="$ICON_BATTERY_1"; color="$YELLOW" ;;
    *)            label="$ICON_BATTERY_0"; color="$RED" ;;
  esac
  sketchybar -m --set "$NAME" label="$label" label.color="$color"
fi
