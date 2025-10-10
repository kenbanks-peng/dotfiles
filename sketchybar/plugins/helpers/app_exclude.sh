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
  "Wisper Flow"
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
