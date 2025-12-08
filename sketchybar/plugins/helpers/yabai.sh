#!/usr/bin/env bash

# =============================================================================
# DEPRECATED: This file contains yabai helper functions that are being phased out
# in favor of aerospace-based alternatives. Use aerospace_get_* functions instead.
# =============================================================================

yabai_get_windows_in_space() {
  local sid="$1"
  local result=()
  while IFS= read -r window_id; do
    result+=("$window_id")
  done < <(yabai -m query --spaces --space "$sid" | jq -r ".windows[]")

  # Return the result as a space-separated string
  echo "${result[@]}"
}

yabai_get_window_app_name() {
  local window_id="$1"
  yabai -m query --windows --window "$window_id" | jq -r '.app'
}

# DEPRECATED: Use aerospace_get_focused_window_id() instead
yabai_get_focused_window_id() {
  local window_id=$(yabai -m query --windows | jq -r '.[] | select(.["has-focus"] == true) | .id')
  if [[ -z "${window_id// }" ]]; then
    window_id=""
  fi
  echo "$window_id"
}

yabai_autofocus() {
  # autofocus / off / autoraise
  setting="$(yabai -m config focus_follows_mouse)"
  if [ "$setting" != "disabled" ]; then
    yabai -m config focus_follows_mouse off
  else
    yabai -m config focus_follows_mouse autofocus
  fi
  # requery
  echo "$(yabai -m config focus_follows_mouse)"
}

# DEPRECATED: No longer used - aerospace doesn't track dialogs/floating windows
# so if a window appears in aerospace's list, it's a valid tiling window.
# Returns 0 (true) if window is a dialog, 1 (false) if it's a normal window
yabai_is_dialog() {
  local window_id="$1"

  # Get window properties
  local window_info=$(yabai -m query --windows --window "$window_id" 2>/dev/null)

  if [[ -z "$window_info" ]]; then
    # if we can't get window info, the app was likely just destroyed
    return 1
  fi

  # Extract relevant properties
  local app=$(echo "$window_info" | jq -r '.app')
  local level=$(echo "$window_info" | jq -r '.level')
  local subrole=$(echo "$window_info" | jq -r '.subrole')
  local layer=$(echo "$window_info" | jq -r '.layer')

  # Filter out floating windows and dialogs
  # AXStandardWindow = normal window (NOT a dialog)
  # AXFloatingWindow = floating window (IS a dialog)
  # AXSystemDialog = system dialog (IS a dialog)
  if [[ "$level" == "3" || "$subrole" != "AXStandardWindow" || "$layer" == "above" ]]; then
    return 0  # Is a dialog
  fi

  return 1  # Not a dialog
}
