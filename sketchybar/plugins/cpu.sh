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
  if [ "$cpuload" -ge 88 ]; then
    circle="󰪥"
  elif [ "$cpuload" -ge 75 ]; then
    circle="󰪤"
  elif [ "$cpuload" -ge 63 ]; then
    circle="󰪣"
  elif [ "$cpuload" -ge 50 ]; then
    circle="󰪢"
  elif [ "$cpuload" -ge 38 ]; then
    circle="󰪡"
  elif [ "$cpuload" -ge 25 ]; then
    circle="󰪠"
  elif [ "$cpuload" -ge 13 ]; then
    circle="󰪟"
  else
    circle="󰪞"
  fi
  sketchybar -m --set "$NAME" label="$circle" label.color="$color" label.font="$NERD:14" icon.color="$color"
fi
  
if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "Activity Monitor"
fi
