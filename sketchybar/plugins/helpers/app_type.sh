#!/usr/bin/env bash

# List of app names to exclude from sketchybar display
# see also RULES section in yabairc
EXCLUDED_APPS=(
  "LanguageTool"
  "Finder"
  "System Settings"
  "Activity Monitor"
  "Calculator"
  "Software Update"
  "About This Mac"
  "Safari"
  "App Store"
  "Dictionary"
  "Launchie"
  "mpv"
  "Wispr Flow"
  "CleanShot X"
  "Electron"
)

# List of app names that should stick to the current workspace
# These apps will be moved to the new workspace when switching
# Sticky apps are likely also excluded apps, since they are hopefully outside of aerospace's window management. 
STICKY_APPS=(
  "Wispr Flow"
)

# Returns 0 (true) if app is allowed, 1 (false) if excluded
allow_app() {
  local appname="$1"

  for excluded in "${EXCLUDED_APPS[@]}"; do
    if [[ "$appname" == "$excluded" ]]; then
      return 1  # App is excluded
    fi
  done

  return 0  # App is allowed
}

# Move sticky apps from previous workspace to current workspace
show_sticky_apps() {
  local sid="$1"
  local prev_sid="$2"

  # to avoid source loop
  source "$PLUGIN_DIR/helpers/aerospace.sh"

  for sticky_app in "${STICKY_APPS[@]}"; do
    # Get window IDs for this sticky app across all workspaces
    local window_ids=$(aerospace_window_ids_for_app "$sticky_app")

    if [[ -n "$window_ids" ]]; then
      # Move each window of the sticky app to the current workspace
      read -ra window_id_array <<< "$window_ids"
      for window_id in "${window_id_array[@]}"; do
        aerospace move-node-to-workspace --window-id "$window_id" "$sid"
      done
    fi
  done
}
