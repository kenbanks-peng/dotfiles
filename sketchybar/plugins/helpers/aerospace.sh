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
        icon.width=10
        icon.padding_left=5
        icon.padding_right=5
      )

      sketchy_add_item "$start" left \
        --set "$start" "${props[@]}"

      sketchy_add_item "$end" left \
        --set "$end" "${props[@]}"

      sketchy_add_workspace "$sid"

      # Populate the workspace with existing apps
      aerospace_add_apps_in_spaceid "$sid"
    fi
  done

  # Remove empty workspaces
  for sid in "${sketchy_workspaces[@]}"; do
    if ! printf '%s\n' "${occupied_workspaces[@]}" | grep -q "^${sid}$"; then
      # Workspace exists in sketchybar but not in aerospace, remove it
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
  sketchy_add_item "$item" left \
    --move "$item" before "workspace.end.$sid" \
    --set "$item" "${props[@]}" \
    icon="$icon" icon.color="$icon_color" \
    click_script="aerospace focus --window-id $window_id"

  sketchy_highlight_window_id "$window_id"

  # Sync workspaces after adding window
  sync_workspaces
}

aerospace_add_apps_in_spaceid() {
  local sid="$1"

  props=(
    y_offset=1
    background.corner_radius=0
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
    icon.width="$APP_WIDTH"
  )

  aerospace_window_ids=$(aerospace_window_ids_in_workspace "$sid")

  if [ -n "${aerospace_window_ids}" ]; then
    # Read space-separated window_ids into an array and iterate
    read -ra window_id_array <<< "$aerospace_window_ids"
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
        --move "$item" before "workspace.end.$sid" \
        --set "$item" "${props[@]}" \
        icon="$icon" icon.color="$icon_color" \
        click_script="aerospace focus --window-id $window_id"
    done
  fi
}

