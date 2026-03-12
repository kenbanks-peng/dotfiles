#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

cpuload="$(top -l 2 | grep -E "^CPU" | tail -1 | awk '{ print int($3 + $5 + 0.5) }')"

if [ -n "$cpuload" ]; then
  color="$SAPPHIRE"
  if [ "$cpuload" -ge 80 ]; then
    color="$RED"
  elif [ "$cpuload" -ge 50 ]; then
    color="$YELLOW"
  fi
  sketchybar -m --set "$NAME" label="${cpuload}%" label.color="$color" icon.color="$color"
fi
  
if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "Activity Monitor"
fi
