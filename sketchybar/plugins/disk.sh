#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# Sum all macOS APFS volumes (Data + System + Preboot + VM)
used=$(df -H | awk '/disk4s[1346]/ {gsub("G","",$3); sum+=$3} END {printf "%.1f", sum}')
total=200
percentage=$(awk -v u="$used" -v t="$total" 'BEGIN {printf "%d%%", (u/t)*100}')

sketchybar -m --set "$NAME" label="$percentage"

if [ "$SENDER" = "mouse.clicked" ]; then
  open -a "DaisyDisk"
fi
