#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/helpers/util.sh"

# =============================================================================
# Bar State Cache
# =============================================================================
# Use SKETCHY_BAR_CACHE to avoid repeated sketchybar --query calls.
# Set at event entry: export SKETCHY_BAR_CACHE=$(sketchy_get_bar_items)
# Clear after modifications: unset SKETCHY_BAR_CACHE
# Functions automatically use cache if available.

# Fetch bar items list
sketchy_get_bar_items() {
  sketchybar --query bar 2>/dev/null | jq -r '.items[]'
}

# Get bar items, using cache if available
_sketchy_cached_bar_items() {
  if [[ -n "${SKETCHY_BAR_CACHE:-}" ]]; then
    echo "$SKETCHY_BAR_CACHE"
  else
    sketchy_get_bar_items
  fi
}

# Invalidate cache (call after add/remove operations)
sketchy_invalidate_cache() {
  unset SKETCHY_BAR_CACHE
}

# add item only if not exists, but always apply --set properties
sketchy_add_item() {
  local item="$1"
  local items=$(_sketchy_cached_bar_items)
  if ! item_in_array "$item" "$items"; then
    sketchybar --add item "$@" 2>/dev/null
    sketchy_invalidate_cache
  else
    # Item exists, extract and apply --set properties if present
    local set_flag=false
    local set_args=()
    for arg in "$@"; do
      if [ "$set_flag" = true ]; then
        set_args+=("$arg")
      elif [ "$arg" = "--set" ]; then
        set_flag=true
        set_args+=("$arg")
      fi
    done
    if [ "${#set_args[@]}" -gt 0 ]; then
      sketchybar "${set_args[@]}" 2>/dev/null
    fi
  fi
}

# remove item only if exists
sketchy_remove_item() {
  local item="$1"

  # Handle empty item name gracefully
  if [[ -z "$item" ]]; then
    return 0
  fi

  local items=$(_sketchy_cached_bar_items)
  if item_in_array "$item" "$items"; then
    sketchybar --remove "$@" 2>/dev/null
    sketchy_invalidate_cache
  fi
}

sketchy_filter_window_items() {
  local items="$1"
  local pattern="${2:-.}"  # default matches all windows
  echo "$items" | grep "^window\\.$pattern" || true
}

sketchy_get_window_items_in_spaceid() {
  local sid=$1
  local items=$(_sketchy_cached_bar_items)
  sketchy_filter_window_items "$items" "${sid}\\."
}

# Get all window items as an array (sorted)
# Usage: sketchy_get_window_items_array arr
#        for item in "${arr[@]}"; do ...; done
sketchy_get_window_items_array() {
  local -n _arr="$1"
  local bar_items="${2:-$(_sketchy_cached_bar_items)}"

  while IFS= read -r item; do
    [[ -n "$item" ]] && _arr+=("$item")
  done < <(echo "$bar_items" | grep "^window\\." | sort)
}

# returns item ex: window.3.66286.WezTerm
sketchy_get_item_by_window_id() {
  # ex: 46356
  local window_id="$1"
  local items=$(_sketchy_cached_bar_items)
  sketchy_filter_window_items "$items" "[0-9]*\\.${window_id}\\."
}

# Extract field from item name: window.SID.WINDOW_ID.APPNAME
# Fields: 1=prefix, 2=space, 3=window_id, 4=app
sketchy_get_item_field() {
  local item="$1"
  local field="$2"
  echo "$item" | awk -F'.' -v f="$field" '{print $f}'
}

sketchy_get_space_by_item() {
  sketchy_get_item_field "$1" 2
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
                    background.height=$BACKGROUND_HEIGHT \
                    background.color=$(sketchy_get_space_color background false)
}

sketchy_highlight_workspace() {
  local sid="$1"
  local prev_sid

  if [ -f "$CACHE_DIR/highlighted.workspace" ]; then
    read -r prev_sid <"$CACHE_DIR/highlighted.workspace"
  fi

  if [ -n "$prev_sid" ] && [ "$prev_sid" != "$sid" ]; then
    sketchybar --set "workspace.$prev_sid" background.color=$(sketchy_get_space_color background false)
  fi

  sketchybar --set "workspace.$sid" background.color=$(sketchy_get_space_color background true)

  echo "$sid" >"$CACHE_DIR/highlighted.workspace"
}


sketchy_highlight_window_id() {
  # State-based approach: iterate through ALL windows and set correct color
  local focused_window_id="$1"

  # Get colors
  local focused_color=$(sketchy_get_space_color foreground true)
  local unfocused_color=$(sketchy_get_space_color foreground false)

  # Get current focused workspace
  local current_workspace=$(aerospace list-workspaces --focused)

  # Get all window items from cache
  local items=$(_sketchy_cached_bar_items)
  local all_window_items=()
  while IFS= read -r item; do
    [[ -n "$item" ]] && all_window_items+=("$item")
  done < <(sketchy_filter_window_items "$items" | sort)

  # Build batch command for all updates
  local batch_args=()
  for item in "${all_window_items[@]}"; do
    local item_workspace=$(sketchy_get_item_field "$item" 2)
    local item_window_id=$(sketchy_get_item_field "$item" 3)

    # Only highlight if this is the focused window AND it's on the current workspace
    if [[ "$item_window_id" == "$focused_window_id" ]] && [[ "$item_workspace" == "$current_workspace" ]]; then
      batch_args+=(--set "$item" icon.color="$focused_color")
    else
      batch_args+=(--set "$item" icon.color="$unfocused_color")
    fi
  done

  # Execute all updates in single batch call
  if [[ ${#batch_args[@]} -gt 0 ]]; then
    sketchybar "${batch_args[@]}"
  fi

  # Update cache
  echo "$focused_window_id" >"$CACHE_DIR/highlighted.window_id"
}

sketchy_get_space_color() {
  local type="$1"      # "background" or "foreground"
  local focused="$2"   # true/false

  local var_name="WORKSPACE_"
  [[ "$focused" == "true" ]] && var_name+="FOCUSED_"
  var_name+=$(echo "$type" | tr '[:lower:]' '[:upper:]')

  echo "${!var_name}"
}
