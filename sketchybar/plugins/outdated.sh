#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"

# reprocess on mouse click
props=(
  icon.color="$BLUE"
  label.drawing=on
  label="?"
)
sketchybar --set "$NAME" "${props[@]}"

sum=0

count=$(mise list | grep -o '\boutdated\b' | wc -l | tr -d '[:space:]')
sleep 3
sum=$((sum + count))

# this gives error when using --greedy and called via sketchybar
count=$(brew outdated | wc -l | tr -d ' ')
sleep 10
sum=$((sum + count))

case "$sum" in
0)
  color="$GREEN"
  sum="$ICON_CHECKMARK"
  ;;
[1-2])
  color="$YELLOW"
  ;;
[3-4])
  color="$PEACH"
  ;;
*)
  color="$RED"
  ;;
esac

props=(
  icon.color="$color"
  label="$sum"
  label.color="$color"
)
sketchybar --set "$NAME" "${props[@]}"
