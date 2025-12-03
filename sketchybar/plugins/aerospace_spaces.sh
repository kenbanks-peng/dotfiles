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
elif [ "$SENDER" = "aerospace_new_workspace" ]; then
  aerospace_create_new_workspace
elif [ "$SENDER" = "aerospace_workspace_next" ]; then
  aerospace_workspace_next
elif [ "$SENDER" = "aerospace_move_window_next" ]; then
  aerospace_smart_move_window "next"
elif [ "$SENDER" = "aerospace_move_window_prev" ]; then
  aerospace_smart_move_window "prev"
elif [ "$SENDER" = "aerospace_swap_workspace_left" ]; then
  aerospace_swap_workspace "left"
elif [ "$SENDER" = "aerospace_swap_workspace_right" ]; then
  aerospace_swap_workspace "right"
elif [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [[ "$FOCUS_CHANGE" != "true" ]]; then
    # aerospace exec_on_workspace_change fired
    aerospace_workspace_change "$FOCUSED_WORKSPACE" "$PREV_WORKSPACE"
  fi
  # aerospace exec_on_workspace_change or on_focus_change fired
  window_id=$(yabai_get_focused_window_id)
  appname=$(aerospace_appname_from_window_id "$window_id")
  if apptype_allow_app "$appname" "$window_id"; then
    aerospace_focused_window_change "$window_id"
  fi
elif [ "$SENDER" = "yabai_window_created" ] || [ "$SENDER" = "yabai_window_deminimized" ]; then
  window_id="$ID"
  # Get app name to check if allowed (also checks dialogs)
  appname=$(aerospace_appname_from_window_id "$window_id")
  if apptype_allow_app "$appname" "$window_id"; then
    aerospace_new_window_id "$window_id"
  fi
elif [ "$SENDER" = "yabai_window_destroyed" ] || [ "$SENDER" = "yabai_window_minimized" ]; then
  window_id="$ID"
  # Get app name to check if allowed (also checks dialogs)
  appname=$(aerospace_appname_from_window_id "$window_id")
  if apptype_allow_app "$appname" "$window_id"; then
    aerospace_remove_window_id "$window_id"
  fi
fi
