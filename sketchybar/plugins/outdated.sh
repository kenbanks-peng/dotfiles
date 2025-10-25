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
sum=$((sum + count))

# this gives error when using --greedy and called via sketchybar
brew_output=$(brew outdated 2>&1)
if [ $? -ne 0 ]; then
  props=(
    icon.color="$RED"
    label="E"
    label.color="$RED"
  )
  sketchybar --set "$NAME" "${props[@]}"
  exit 1
fi
count=$(echo "$brew_output" | wc -l | tr -d ' ')
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
