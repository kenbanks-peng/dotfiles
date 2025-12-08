#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"
source "$PLUGIN_DIR/helpers/aerospace.sh"
source "$PLUGIN_DIR/helpers/sketchy.sh"

if [ "$SENDER" = "forced" ]; then
  # Fetch all data ONCE
  all_windows=$(aerospace_all_windows)

  # Get all workspaces from the JSON and iterate properly
  while IFS= read -r space; do
    [[ -z "$space" ]] && continue
    aerospace_add_apps_in_spaceid "$space" "$all_windows"
  done < <(aerospace_get_workspaces "$all_windows")

  # Initialize focus highlighting
  focused_window_id=$(aerospace_get_focused_window_id)
  aerospace_focused_window_change "$focused_window_id" "$all_windows"

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
  # Fetch all data ONCE
  all_windows=$(aerospace_all_windows)
  focused_window_id=$(aerospace_get_focused_window_id)

  if [[ "$FOCUS_CHANGE" != "true" ]]; then
    # aerospace exec_on_workspace_change fired
    aerospace_workspace_change "$FOCUSED_WORKSPACE" "$PREV_WORKSPACE" "$all_windows"
  fi

  # aerospace exec_on_workspace_change or on_focus_change fired
  appname=$(aerospace_get_appname_by_windowid "$all_windows" "$focused_window_id")
  if apptype_allow_app "$appname"; then
    aerospace_focused_window_change "$focused_window_id" "$all_windows"
  fi

elif [ "$SENDER" = "yabai_window_created" ] || [ "$SENDER" = "yabai_window_deminimized" ]; then
  # Yabai events as hints - refresh aerospace state
  all_windows=$(aerospace_all_windows)
  window_id="$ID"

  # Validate window exists in aerospace
  appname=$(aerospace_get_appname_by_windowid "$all_windows" "$window_id")
  if [[ -n "$appname" ]] && apptype_allow_app "$appname"; then
    aerospace_new_window_id "$window_id" "$all_windows"
  fi

elif [ "$SENDER" = "yabai_window_destroyed" ] || [ "$SENDER" = "yabai_window_minimized" ]; then
  window_id="$ID"
  # Get app name before removal for filtering check
  # Note: window may already be gone from aerospace, so just remove the sketchybar item
  aerospace_remove_window_id "$window_id"
fi
