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
echo "$(date): mise count=$count" >>"$CACHE_DIR/$LOG_FILE"

# BUG:WORKAROUND: Bypass homebrew CPU core detection that fails in sketchybar context
# Setting this to a number (not "auto") skips Hardware::CPU.cores call
export HOMEBREW_DOWNLOAD_CONCURRENCY=4

# Redirect stdin from /dev/null to avoid pipe issues
# Split formula and cask checks to avoid --greedy curl timeout bug in sketchybar context
formula_output=$(brew outdated --formula </dev/null 2>&1)
formula_exit=$?
cask_output=$(brew outdated --cask </dev/null 2>&1)
cask_exit=$?

if [ $formula_exit -ne 0 ] || [ $cask_exit -ne 0 ]; then
  [ $formula_exit -ne 0 ] && {
    echo "ERROR: brew formula exit code: $formula_exit" >>"$CACHE_DIR/$LOG_FILE"
    echo "ERROR: brew formula output: $formula_output" >>"$CACHE_DIR/$LOG_FILE"
  }
  [ $cask_exit -ne 0 ] && {
    echo "ERROR: brew cask exit code: $cask_exit" >>"$CACHE_DIR/$LOG_FILE"
    echo "ERROR: brew cask output: $cask_output" >>"$CACHE_DIR/$LOG_FILE"
  }
  props=(
    icon.color="$RED"
    label="E"
    label.color="$RED"
  )
  sketchybar --set "$NAME" "${props[@]}"
  rm -f "$LOCK_FILE"
  exit 1
fi

# Log actual brew outputs for debugging
echo "$(date): === BREW FORMULA OUTPUT ===" >>"$CACHE_DIR/$LOG_FILE"
echo "$formula_output" >>"$CACHE_DIR/$LOG_FILE"
echo "$(date): === BREW CASK OUTPUT ===" >>"$CACHE_DIR/$LOG_FILE"
echo "$cask_output" >>"$CACHE_DIR/$LOG_FILE"
echo "$(date): === END BREW OUTPUT ===" >>"$CACHE_DIR/$LOG_FILE"

# Combine and count outputs, filtering out brew error messages
count=$(printf '%s\n%s' "$formula_output" "$cask_output" | grep -v '^✘' | grep -v '^Error:' | grep -c . || echo 0)
echo "$(date): brew count=$count" >>"$CACHE_DIR/$LOG_FILE"
sum=$((sum + count))
echo "$(date): final sum=$sum" >>"$CACHE_DIR/$LOG_FILE"

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
