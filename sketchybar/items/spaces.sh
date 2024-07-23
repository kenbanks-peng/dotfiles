#!/usr/bin/env bash

SPACE_SIDS=(1 2 3 4 5 6 7 8 9 10)

for sid in "${SPACE_SIDS[@]}"; do
  sketchybar --add space space.$sid left \
    --set space.$sid space=$sid \
    label.font="sketchybar-app-font:Regular:16.0" \
    script="$PLUGIN_DIR/space.sh"
done

sketchybar --add \
  item space_separator left \
  --set space_separator \
  icon.color=$ACCENT_COLOR \
  script="$PLUGIN_DIR/space_windows.sh" \
  --subscribe space_separator space_windows_change front_app_switched
