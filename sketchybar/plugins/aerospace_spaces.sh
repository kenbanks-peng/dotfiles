#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"
source "$PLUGIN_DIR/helpers/aerospace.sh"
source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$PLUGIN_DIR/helpers/yabai.sh"

if [ "$SENDER" = "forced" ]; then
  for space in $(aerospace_workspaces); do
    aerospace_add_apps_in_spaceid "$space"
  done
  # to initialize cache of previous window_id
  aerospace_focused_window_change
elif [ "$SENDER" = "yabai_window_focused" ]; then
  # Skip dialogs/popups
  if ! yabai_is_dialog "$ID"; then
    aerospace_focused_window_change $ID
  fi
elif [ "$SENDER" = "aerospace_workspace_change" ]; then
  aerospace_workspace_change "$FOCUSED_WORKSPACE" "$PREV_WORKSPACE"
elif [ "$SENDER" = "yabai_window_created" ] || [ "$SENDER" = "yabai_window_deminimized" ]; then
  # Get app name to check if allowed
  appname=$(aerospace_appname_from_window_id "$ID")

  # Skip dialogs/popups and excluded apps
  if ! yabai_is_dialog "$ID" && allow_app "$appname" "$ID"; then
    aerospace_new_window_id "$ID"
  fi
elif [ "$SENDER" = "yabai_window_destroyed" ] || [ "$SENDER" = "yabai_window_minimized" ]; then
  # Skip dialogs/popups
  if ! yabai_is_dialog "$ID"; then
    aerospace_remove_window_id "$ID"
  fi
fi
