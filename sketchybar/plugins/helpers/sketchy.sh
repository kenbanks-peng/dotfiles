#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/helpers/util.sh"

# add item only if not exists
sketchy_add_item() {
  local item="$1"
  local items=$(sketchybar --query bar | jq -r '.items[]')
  item=${item// /_}
  if ! item_in_array "$item" "$items"; then
    sketchybar --add item "$@"
  fi
}

# remove item only if exists
sketchy_remove_item() {
  local item="$1"
  local items=$(sketchybar --query bar | jq -r '.items[]')
  if item_in_array "$item" "$items"; then
    sketchybar --remove "$@"
  fi
}

sketchy_get_window_items_in_spaceid() {
  local sid=$1
  echo "$(sketchybar --query bar | jq -r --arg sid "$sid" '.items[] | select(test("^window\\." + $sid + "\\."))')"
}

# returns item ex: window.3.66286.WezTerm
sketchy_get_item_by_window_id() {
  # ex: 46356
  local window_id="$1"
  echo "$(sketchybar --query bar | jq -r --arg window_id "$window_id" '.items[] | select(test("^window\\.\\d+\\." + $window_id + "\\..+$"))')"
}

sketchy_get_space_by_item() {
  local item="$1"
  echo "$item" | awk -F'.' '{print $2}'
}

sketchy_get_space_by_window_id() {
  local window_id="$1"
  local item=$(sketchy_get_item_by_window_id "$window_id")
  local space=$(sketchy_get_space_by_item "$item")
  echo "$space"
}

sketchy_add_workspace() {
  local sid="$1"
  local start="workspace.start.$sid"
  local end="workspace.end.$sid"
  sketchybar --add bracket workspace.$sid "$start" "$end" \
           --set workspace.$sid \
                    background.corner_radius=0  \
                    background.color=$(sketchy_get_space_background_color_by_sid $sid)
}

sketchy_highlight_workspace() {
  local sid="$1"
  local prev_sid

  if [ -f "$CACHE_DIR/highlighted.workspace" ]; then
    read -r prev_sid <"$CACHE_DIR/highlighted.workspace"
  fi

  if [ -n "$prev_sid" ] && [ "$prev_sid" != "$sid" ]; then
    sketchybar --set "workspace.$prev_sid" background.color=$(sketchy_get_space_background_color_by_sid $prev_sid)
  fi 

  sketchybar --set "workspace.$sid" background.color=$(sketchy_get_space_background_color_by_sid $sid)

  echo "$sid" >"$CACHE_DIR/highlighted.workspace"
}


sketchy_highlight_window_id() {
  # ex: 66286 - since window.3.66286.WezTerm could now be window.4.66286.WezTerm
  local window_id="$1"
  local prev_window_id

  if [ -f "$CACHE_DIR/highlighted.window_id" ]; then
    read -r prev_window_id <"$CACHE_DIR/highlighted.window_id"
  fi

  if [ -n "$prev_window_id" ] && [ "$prev_window_id" != "$window_id" ]; then
    local prev_item=$(sketchy_get_item_by_window_id "$prev_window_id")
    if [ -n "$prev_item" ]; then
      local color=$(sketchy_get_space_foreground_color_by_window_id $prev_window_id)
      sketchybar --set "$prev_item" icon.color="$color"
    fi
  fi

  if [ -n "$window_id" ] && [ "$prev_window_id" != "$window_id" ]; then
    local item=$(sketchy_get_item_by_window_id "$window_id")
    if [ -n "$item" ]; then 
      local color=$(sketchy_get_space_foreground_color_by_window_id $window_id)
      sketchybar --set "$item" icon.color="$color"
    fi
    echo "$window_id" >"$CACHE_DIR/highlighted.window_id"
  fi
}

sketchy_get_space_background_color_by_sid() {
  local sid="$1"
  local focused=$(aerospace_focused_workspace)
  if [ "$sid" = "$focused" ]; then
    space_background="$WORKSPACE_FOCUSED_BACKGROUND"
  else
    space_background="$WORKSPACE_BACKGROUND"
  fi
  echo "$space_background"
}

sketchy_get_space_foreground_color_by_window_id() {
  local window_id="$1"
  local focused_window_id=$(yabai_get_focused_window_id)

  # if [ -z "$focused_window_id" ]; then
  #   # if no focused window, the must be default item for empty workspace
  #   # so use sid as window_id
  #   focused_window_id=$(aerospace_focused_workspace)
  # fi

  local window_color
  if [ "$focused_window_id" = "$window_id" ]; then
    window_color="$WORKSPACE_FOCUSED_FOREGROUND"
  else
    window_color="$WORKSPACE_FOREGROUND"
  fi

  echo "$window_color"
}
