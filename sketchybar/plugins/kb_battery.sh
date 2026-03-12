#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

SEP="sep_$NAME"

read -r percentage transport < <(ioreg -c AppleDeviceManagementHIDEventService -r -l | awk '
  /Transport/ { gsub(/"/, "", $NF); trans = $NF }
  /ProductID/ { pid = $NF }
  /BatteryPercent/ { if (pid == 666) { print $NF, trans; exit } }
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
  if [[ "$transport" == "USB" ]] || [[ "$percentage" -eq 100 ]]; then
    color="$GREEN"
  fi
  sketchybar -m --set "$NAME" drawing=on label="$label" label.color="$color" icon.color="$color" label.font="$NERD:14" \
             --set "$SEP" drawing=on
else
  sketchybar -m --set "$NAME" drawing=off --set "$SEP" drawing=off
fi
