#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# Sum all macOS APFS volumes (Data + System + Preboot + VM) and get container size
read used total <<< $(df -H | awk '/disk4s[1346]/ {
  # Get total from first volume
  if (total == 0) {
    total_str = $2;
    gsub("G", "", total_str);
    total = total_str;
  }
  # Sum used space
  val=$3;
  if (val ~ /M$/) { gsub("M","",val); sum+=val/1000 }
  else if (val ~ /G$/) { gsub("G","",val); sum+=val }
} END {printf "%.1f %d", sum, total}')
percentage=$(awk -v u="$used" -v t="$total" 'BEGIN {printf "%d%%", (u/t)*100}')

sketchybar -m --set "$NAME" label="$percentage"

if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "DaisyDisk"
fi
