#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"
source "$PLUGIN_DIR/helpers/aerospace.sh"
source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$PLUGIN_DIR/helpers/yabai.sh"

echo "Sender: $SENDER ID: $ID"

if [ "$SENDER" = "forced" ]; then
  for space in $(aerospace_workspaces); do
    aerospace_add_apps_in_spaceid "$space"
  done
  # to initialize cache of previous window_id
  aerospace_focused_window_change
elif [ "$SENDER" = "yabai_window_focused" ]; then
  aerospace_focused_window_change $ID
elif [ "$SENDER" = "aerospace_workspace_change" ]; then
  aerospace_workspace_change "$FOCUSED_WORKSPACE" "$PREV_WORKSPACE"
elif [ "$SENDER" = "yabai_window_created" ] || [ "$SENDER" = "yabai_window_deminimized" ]; then
  aerospace_new_window_id "$ID"
elif [ "$SENDER" = "yabai_window_destroyed" ] || [ "$SENDER" = "yabai_window_minimized" ]; then
  aerospace_remove_window_id "$ID"
fi
