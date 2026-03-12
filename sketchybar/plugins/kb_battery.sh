#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

percentage=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | awk '
  /ProductID/ { pid = $NF }
  /BatteryPercent/ { if (pid == 666) { print $NF; exit } }
')

if [ -n "$percentage" ]; then
  color="$SAPPHIRE"
  case ${percentage} in
    9[0-9] | 100) label="$ICON_VBAT_4" ;;
    [6-8][0-9])   label="$ICON_VBAT_3" ;;
    [3-5][0-9])   label="$ICON_VBAT_2" ;;
    [1-2][0-9])   label="$ICON_VBAT_1"; color="$YELLOW" ;;
    *)            label="$ICON_VBAT_0"; color="$RED" ;;
  esac
  sketchybar -m --set "$NAME" label="$label" label.color="$color" label.font="$NERD:14"
fi
