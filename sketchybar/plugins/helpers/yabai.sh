#!/usr/bin/env bash

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

# Check if a yabai window is a dialog/popup that should be excluded
# Returns 0 (true) if window is a dialog, 1 (false) if it's a normal window
yabai_is_dialog() {
  local window_id="$1"

  # Get window properties
  local window_info=$(yabai -m query --windows --window "$window_id" 2>/dev/null)

  if [[ -z "$window_info" ]]; then
    return 0  # Treat as dialog if we can't get window info
  fi

  # Extract relevant properties
  local app=$(echo "$window_info" | jq -r '.app')
  local level=$(echo "$window_info" | jq -r '.level')
  local subrole=$(echo "$window_info" | jq -r '.subrole')
  local layer=$(echo "$window_info" | jq -r '.layer')

  # Filter out events from popup dialogs (level=3, subrole=AXSystemDialog, layer=above)
  if [[ "$level" == "3" || "$subrole" == "AXSystemDialog" || "$layer" == "above" ]]; then
    return 0  # Is a dialog
  fi

  return 1  # Not a dialog
}
