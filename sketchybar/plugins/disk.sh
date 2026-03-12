#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# Sum all macOS APFS volumes by mount point (more reliable than device names)
read used total <<< $(df -H | awk '$9 ~ /^\/$|^\/System\/Volumes\/(VM|Preboot|Data)$/ {
  # Get total from first volume (root)
  if (total == 0) {
    total_str = $2;
    gsub("G", "", total_str);
    total = total_str;
  }
  # Sum used space
  val=$3;
  if (val ~ /M$/) { gsub("M","",val); sum+=val/1000 }
  else if (val ~ /G$/) { gsub("G","",val); sum+=val }
} END {printf "%.1f %.1f", sum, total}')
pct=$(awk -v u="$used" -v t="$total" 'BEGIN {printf "%d", (u/t)*100}')

color="$SAPPHIRE"
if [ "$pct" -ge 90 ]; then
  color="$RED"
elif [ "$pct" -ge 75 ]; then
  color="$YELLOW"
fi

if [ "$pct" -ge 88 ]; then
  circle="󰪥"
elif [ "$pct" -ge 75 ]; then
  circle="󰪤"
elif [ "$pct" -ge 63 ]; then
  circle="󰪣"
elif [ "$pct" -ge 50 ]; then
  circle="󰪢"
elif [ "$pct" -ge 38 ]; then
  circle="󰪡"
elif [ "$pct" -ge 25 ]; then
  circle="󰪠"
elif [ "$pct" -ge 13 ]; then
  circle="󰪟"
else
  circle="󰪞"
fi

sketchybar -m --set "$NAME" label="$circle" label.color="$color" label.font="$NERD:14" icon.color="$color"

if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "DaisyDisk"
fi
