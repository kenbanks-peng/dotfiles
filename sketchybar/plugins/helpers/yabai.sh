#!/usr/bin/env bash

# Toggle yabai focus_follows_mouse setting
# Returns: "disabled", "autofocus", or "autoraise"
yabai_autofocus() {
  local setting=$(yabai -m config focus_follows_mouse)
  if [ "$setting" != "disabled" ]; then
    yabai -m config focus_follows_mouse off
  else
    yabai -m config focus_follows_mouse autofocus
  fi
  echo "$(yabai -m config focus_follows_mouse)"
}
