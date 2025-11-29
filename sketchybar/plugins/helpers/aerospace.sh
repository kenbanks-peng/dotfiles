#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$CONFIG_DIR/plugins/helpers/util.sh"
source "$CONFIG_DIR/plugins/helpers/app_type.sh"
source "$CONFIG_DIR/env.sh"


aerospace_workspaces() {
  echo "$(aerospace list-workspaces --all)"
}

aerospace_focused_workspace() {
  echo "$(aerospace list-workspaces --focused)"
}

# returns window_ids ex: 46356
aerospace_window_ids_in_workspace() {
  local sid="$1"
  local json=$(aerospace list-windows --workspace "$sid" --json --format %{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name})
  local filtered=$(echo "$json" | jq -r '.[] | ."window-id"' | jq -s -r 'join(" ")')
  echo "$filtered"
}

# returns appname ex: Cursor from window_id ex: 46356
aerospace_appname_from_window_id() {
  local window_id="$1"
  local json=$(aerospace list-windows --all --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')
  local filtered=$(echo "$json" | jq -r --arg window_id "$window_id" '.[] | select(."window-id" == ($window_id | tonumber)) | ."app-name"')
  echo "$filtered"
}

# returns window_ids ex: "46356 46357" for given app_name
aerospace_window_ids_for_app() {
  local app_name="$1"
  local json=$(aerospace list-windows --all --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')
  local filtered=$(echo "$json" | jq -r --arg app_name "$app_name" '.[] | select(."app-name" == $app_name) | ."window-id"' | jq -s -r 'join(" ")')
  echo "$filtered"
}

remove_unmatched_items() {
  local sid="$1"
  aerospace_window_ids=$(aerospace_window_ids_in_workspace "$sid")
  sketchy_apps=$(sketchy_get_window_items_in_spaceid "$sid")
  apps_to_remove=$(unmatched_items "$aerospace_window_ids" "$sketchy_apps")
  if [[ -n "$apps_to_remove" ]]; then
    sketchy_remove_item "$apps_to_remove"
  fi
}


aerospace_workspace_change() {
  # default window uses sid as window_id
  local sid="$1"
  local prev_sid="$2"

  # move sticky apps to current workspace
  show_sticky_apps "$sid" "$prev_sid"

  # keep prev workspace in sync
  remove_unmatched_items "$prev_sid"

  # keep current workspace in sync
  aerospace_add_apps_in_spaceid "$sid"

  # highlight workspace
  sketchy_highlight_workspace "$sid"

  # Sync workspaces after workspace change
  sync_workspaces
}

aerospace_focused_window_change() {
  local window_id=$1  
  local sid=$(aerospace_focused_workspace)
 
  if [ -z "$window_id" ]; then
    window_id=$(yabai_get_focused_window_id)
  fi

  sketchy_highlight_workspace "$sid"
  sketchy_highlight_window_id "$window_id"
}

# Removed: maybe_add_default_item_to_spaceid - no longer needed with persistent-workspaces=[]
# Removed: maybe_remove_default_item_from_spaceid - no longer needed with persistent-workspaces=[]

# Rebuild workspaces: completely remove and recreate all workspace dividers in correct order
rebuild_workspaces() {
  local occupied_workspaces=($(aerospace list-workspaces --all | sort -n))

  # Remove ALL existing workspace dividers and brackets
  local existing_workspaces=$(sketchybar --query bar | jq -r '.items[] | select(test("^workspace\\.(start|end|\[0-9\]+)$"))')
  if [[ -n "$existing_workspaces" ]]; then
    while IFS= read -r item; do
      sketchy_remove_item "$item"
    done <<< "$existing_workspaces"
  fi

  # Remove ALL existing window items
  local existing_windows=$(sketchybar --query bar | jq -r '.items[] | select(test("^window\\."))')
  if [[ -n "$existing_windows" ]]; then
    while IFS= read -r item; do
      sketchy_remove_item "$item"
    done <<< "$existing_windows"
  fi

  # Recreate workspaces in correct order
  local props=(
    background.padding_left=0
    background.padding_right=0
    background.height=$BAR_HEIGHT
    background.color=$BAR
    background.corner_radius=0
    width=0
    icon.drawing=off
    label.drawing=off
    y_offset=0
  )

  for sid in "${occupied_workspaces[@]}"; do
    local start="workspace.start.$sid"
    local end="workspace.end.$sid"

    sketchy_add_item "$start" left \
      --set "$start" "${props[@]}"

    sketchy_add_item "$end" left \
      --set "$end" "${props[@]}"

    sketchy_add_workspace "$sid"

    # Populate the workspace with apps
    aerospace_add_apps_in_spaceid "$sid"
  done

  # Highlight current workspace
  local focused_sid=$(aerospace_focused_workspace)
  sketchy_highlight_workspace "$focused_sid"
}

# Sync workspaces: add workspace dividers for new workspaces, remove for empty ones
sync_workspaces() {
  local occupied_workspaces=($(aerospace list-workspaces --all | sort -n))
  local sketchy_workspaces=($(sketchybar --query bar | jq -r '.items[] | select(test("^workspace\\.start\\.\\d+$"))' | sed 's/workspace\.start\.//'))

  # Add missing workspaces
  for sid in "${occupied_workspaces[@]}"; do
    if ! printf '%s\n' "${sketchy_workspaces[@]}" | grep -q "^${sid}$"; then
      # Workspace doesn't exist in sketchybar, add it
      local start="workspace.start.$sid"
      local end="workspace.end.$sid"

      local props=(
        background.padding_left=0
        background.padding_right=0
        background.height=$BAR_HEIGHT
        background.color=$BAR
        background.corner_radius=0
        width=0
        icon.drawing=off
        label.drawing=off
        y_offset=0
      )

      # Find the correct position to insert this workspace
      # Look for the next higher workspace number that exists in sketchybar
      local position_found=false
      for next_sid in "${occupied_workspaces[@]}"; do
        if [ "$next_sid" -gt "$sid" ]; then
          # Check if this next workspace exists in sketchybar
          if printf '%s\n' "${sketchy_workspaces[@]}" | grep -q "^${next_sid}$"; then
            # Insert before this workspace
            sketchy_add_item "$start" left \
              --set "$start" "${props[@]}"
            sketchybar --move "$start" before "workspace.start.$next_sid"

            sketchy_add_item "$end" left \
              --set "$end" "${props[@]}"
            sketchybar --move "$end" after "$start"

            position_found=true
            break
          fi
        fi
      done

      # If no higher workspace found, just add to left (will be at the end)
      if [ "$position_found" = false ]; then
        sketchy_add_item "$start" left \
          --set "$start" "${props[@]}"

        sketchy_add_item "$end" left \
          --set "$end" "${props[@]}"
      fi

      sketchy_add_workspace "$sid"

      # Move any existing window items for this workspace to correct position
      local existing_windows=$(sketchybar --query bar | jq -r --arg sid "$sid" '.items[] | select(test("^window\\." + $sid + "\\."))')
      if [[ -n "$existing_windows" ]]; then
        while IFS= read -r item; do
          sketchybar --move "$item" before "workspace.end.$sid"
        done <<< "$existing_windows"
      fi

      # Populate the workspace with any missing apps
      aerospace_add_apps_in_spaceid "$sid"
    fi
  done

  # Remove workspaces that don't exist in AeroSpace
  for sid in "${sketchy_workspaces[@]}"; do
    if ! printf '%s\n' "${occupied_workspaces[@]}" | grep -q "^${sid}$"; then
      # Remove all window items in this workspace first
      local window_items=$(sketchybar --query bar | jq -r --arg sid "$sid" '.items[] | select(test("^window\\." + $sid + "\\."))')
      if [[ -n "$window_items" ]]; then
        while IFS= read -r item; do
          sketchy_remove_item "$item"
        done <<< "$window_items"
      fi

      # Then remove workspace dividers and bracket
      sketchy_remove_item "workspace.start.$sid"
      sketchy_remove_item "workspace.end.$sid"
      sketchy_remove_item "workspace.$sid"
    fi
  done
}


aerospace_remove_window_id() {
  # ex: 46356
  local window_id="$1"
  local sid=$(aerospace_focused_workspace)
  # item ex:window.3.66286.WezTerm
  item=$(sketchy_get_item_by_window_id "$window_id")
  sketchy_remove_item "$item"

  # Ensure contiguous workspace numbering after removing window
  # This will also trigger Sketchybar sync
  "$CONFIG_DIR/scripts/ensure_contiguous_workspaces.sh"
}


aerospace_new_window_id() {
  # ex: 46356
  local window_id="$1"
  local sid=$(aerospace_focused_workspace)

  # Skip if window_id is empty
  if [ -z "$window_id" ]; then
    return
  fi

  # ex: Cursor
  appname=$(aerospace_appname_from_window_id "$window_id")

  # Skip if appname is empty
  if [ -z "$appname" ]; then
    return
  fi

  item="window.$sid.$window_id.$appname"

  icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
  icon_color="$(sketchy_get_space_foreground_color $window_id)"

  props=(
    background.corner_radius=0
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
    icon.width="$APP_WIDTH"
  )

  # Get aerospace's window ordering for this workspace (in DFS/visual order)
  local aerospace_window_order=($(aerospace_window_ids_in_workspace "$sid"))

  # Find the position of this window in aerospace's ordering
  local position=-1
  local index=0
  for wid in "${aerospace_window_order[@]}"; do
    if [ "$wid" = "$window_id" ]; then
      position=$index
      break
    fi
    index=$((index + 1))
  done

  # Add the item
  sketchy_add_item "$item" left \
    --set "$item" "${props[@]}" \
    icon="$icon" icon.color="$icon_color" \
    click_script="aerospace focus --window-id $window_id"

  # Position it correctly based on aerospace's ordering
  if [ $position -eq 0 ]; then
    # First window, move right after workspace.start
    sketchybar --move "$item" after "workspace.start.$sid"
  else
    # Find the window that should be before this one
    local prev_index=$((position - 1))
    local prev_window_id="${aerospace_window_order[$prev_index]}"
    local prev_item=$(sketchy_get_item_by_window_id "$prev_window_id")

    if [ -n "$prev_item" ]; then
      # Insert after the previous window
      sketchybar --move "$item" after "$prev_item"
    else
      # Fallback: insert before workspace.end
      sketchybar --move "$item" before "workspace.end.$sid"
    fi
  fi

  sketchy_highlight_window_id "$window_id"

  # Sync workspaces after adding window
  sync_workspaces
}

aerospace_add_apps_in_spaceid() {
  local sid="$1"

  local props=(
    y_offset=1
    background.corner_radius=0
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
    icon.width="$APP_WIDTH"
  )

  aerospace_window_ids=$(aerospace_window_ids_in_workspace "$sid")

  if [ -n "${aerospace_window_ids}" ]; then
    # Read space-separated window_ids into an array and iterate
    read -ra window_id_array <<< "$aerospace_window_ids"
    local prev_item="workspace.start.$sid"

    for window_id in "${window_id_array[@]}"; do
      appname=$(aerospace_appname_from_window_id "$window_id")

      # Skip windows with empty window_id or appname
      if [ -z "$window_id" ] || [ -z "$appname" ]; then
        continue
      fi

      # Skip excluded apps and dialogs
      if ! allow_app "$appname" "$window_id"; then
        continue
      fi

      item="window.$sid.$window_id.$appname"
      icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
      icon_color="$(sketchy_get_space_foreground_color $window_id)"

      # only add if doesn't already exist
      sketchy_add_item "$item" left \
        --set "$item" "${props[@]}" \
        icon="$icon" icon.color="$icon_color" \
        click_script="aerospace focus --window-id $window_id"

      # Position after the previous item to maintain aerospace's order
      sketchybar --move "$item" after "$prev_item"
      prev_item="$item"
    done
  fi
}

