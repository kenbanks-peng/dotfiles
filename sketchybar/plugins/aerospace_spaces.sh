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
elif [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Handle forced sync from ensure_contiguous_workspaces.sh
  if [[ "$FORCED" == "true" ]]; then
    rebuild_workspaces
    exit 0
  fi
  if [[ "$FOCUS_CHANGE" != "true" ]]; then
    # aerospace exec_on_workspace_change fired
    aerospace_workspace_change "$FOCUSED_WORKSPACE" "$PREV_WORKSPACE"
  fi
  # aerospace exec_on_workspace_change or on_focus_change fired
  ID=$(yabai_get_focused_window_id)
  appname=$(aerospace_appname_from_window_id "$ID")
  if allow_app "$appname" "$ID"; then
    aerospace_focused_window_change $ID
  fi
elif [ "$SENDER" = "yabai_window_created" ] || [ "$SENDER" = "yabai_window_deminimized" ]; then
  # Get app name to check if allowed (also checks dialogs)
  appname=$(aerospace_appname_from_window_id "$ID")
  if allow_app "$appname" "$ID"; then
    aerospace_new_window_id "$ID"
  fi
elif [ "$SENDER" = "yabai_window_destroyed" ] || [ "$SENDER" = "yabai_window_minimized" ]; then
  # Get app name to check if allowed (also checks dialogs)
  appname=$(aerospace_appname_from_window_id "$ID")
  if allow_app "$appname" "$ID"; then
    aerospace_remove_window_id "$ID"
  fi
fi
