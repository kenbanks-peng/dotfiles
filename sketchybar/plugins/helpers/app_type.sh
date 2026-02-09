#!/usr/bin/env bash

# List of app names to exclude from sketchybar display
# Format: "AppName" or "AppName|WindowTitlePattern"
# - "AppName" excludes all windows from that app
# - "AppName|Pattern" only excludes windows where app name AND window title match the pattern
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
  "Microsoft Outlook|*Reminder*"
  "Handy|Recording"
)

# List of app names that should stick to the current workspace
# These apps will be moved to the new workspace when switching
# Sticky apps are likely also excluded apps, since they are hopefully outside of aerospace's window management.
STICKY_APPS=(
  "Wispr Flow"
)

# Returns 0 (true) if app is allowed, 1 (false) if excluded
# Usage: apptype_allow_app "AppName" ["WindowTitle"]
# Note: Dialog detection removed - aerospace doesn't track dialogs/floating windows
apptype_allow_app() {
  local appname="$1"
  local window_title="$2"

  # Check if app name is in excluded list
  for excluded in "${EXCLUDED_APPS[@]}"; do
    # Check if exclusion has window title pattern (contains |)
    if [[ "$excluded" == *"|"* ]]; then
      # Split by | to get app name and window title pattern
      local excluded_app="${excluded%%|*}"
      local title_pattern="${excluded#*|}"

      # Match both app name and window title pattern
      if [[ "$appname" == "$excluded_app" ]]; then
        # If window title is provided, check if it matches the pattern
        if [[ -n "$window_title" ]]; then
          # Use bash pattern matching (supports wildcards like *)
          if [[ "$window_title" == $title_pattern ]]; then
            return 1  # App + window title match - excluded
          fi
        fi
        # App matches but window title doesn't - continue checking other rules
      fi
    else
      # Simple app name exclusion (no window title pattern)
      if [[ "$appname" == "$excluded" ]]; then
        return 1  # App is excluded
      fi
    fi
  done

  return 0  # App is allowed
}

# Move sticky apps from previous workspace to current workspace
# Usage: apptype_show_sticky_apps "$sid" "$prev_sid" "$all_windows"
apptype_show_sticky_apps() {
  local sid="$1"
  local prev_sid="$2"
  local all_windows="$3"

  # to avoid source loop
  source "$PLUGIN_DIR/helpers/aerospace.sh"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  for sticky_app in "${STICKY_APPS[@]}"; do
    # Get window IDs for this sticky app from all_windows JSON
    local window_ids=$(aerospace_get_window_ids_for_app "$all_windows" "$sticky_app")

    if [[ -n "$window_ids" ]]; then
      # Move each window of the sticky app to the current workspace
      for window_id in $window_ids; do
        aerospace move-node-to-workspace --window-id "$window_id" "$sid"
      done
    fi
  done
}
