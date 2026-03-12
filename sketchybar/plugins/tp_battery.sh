#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

SEP="sep_$NAME"

percentage=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | awk '
  /Product.*=.*"Magic Trackpad"/ { found = 1 }
  /BatteryPercent/ { if (found) { print $NF; exit } }
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
  sketchybar -m --set "$NAME" drawing=on label="$label" label.color="$color" icon.color="$color" label.font="$NERD:14" \
             --set "$SEP" drawing=on
else
  sketchybar -m --set "$NAME" drawing=off --set "$SEP" drawing=off
fi
