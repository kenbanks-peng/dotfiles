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
brew_output=$(/opt/homebrew/bin/brew outdated 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "DEBUG: brew exit code: $exit_code" >> /tmp/outdated_debug.log
  echo "DEBUG: brew output: $brew_output" >> /tmp/outdated_debug.log
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
