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

# BUG:WORKAROUND: Bypass homebrew CPU core detection that fails in sketchybar context
# Setting this to a number (not "auto") skips Hardware::CPU.cores call
export HOMEBREW_DOWNLOAD_CONCURRENCY=4

# Redirect stdin from /dev/null to avoid pipe issues
brew_output=$(brew outdated </dev/null 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
  echo "ERROR: brew exit code: $exit_code" >>"$LOG_FILE"
  echo "ERROR: brew output: $brew_output" >>"$LOG_FILE"
  props=(
    icon.color="$RED"
    label="E"
    label.color="$RED"
  )
  sketchybar --set "$NAME" "${props[@]}"
  rm -f "$LOCK_FILE"
  exit 1
fi

count=$(printf '%s' "$brew_output" | wc -l | tr -d ' ')
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
