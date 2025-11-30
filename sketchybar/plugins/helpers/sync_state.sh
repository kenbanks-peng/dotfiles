#!/usr/bin/env bash

# State-based synchronization between aerospace and sketchybar
# This is the SINGLE SOURCE OF TRUTH for syncing
# Call this function whenever sync is needed (window created/destroyed/moved/minimized/etc)

source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$CONFIG_DIR/env.sh"

sync_aerospace_to_sketchybar() {
  local log_file="/tmp/sync_state.log"
  echo "=== $(date) ===" >> "$log_file"
  echo "Starting state sync" >> "$log_file"

  # === STEP 1: READ AEROSPACE STATE ===

  local focused_sid=$(aerospace list-workspaces --focused)
  local focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')

  echo "Focused workspace: $focused_sid" >> "$log_file"
  echo "Focused window: $focused_window_id" >> "$log_file"

  # Build aerospace state: workspace_id -> "window_id1 window_id2 ..."
  declare -A aerospace_state
  mapfile -t aerospace_workspace_ids < <(aerospace list-workspaces --all | sort -n)

  for sid in "${aerospace_workspace_ids[@]}"; do
    mapfile -t windows < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
    aerospace_state[$sid]="${windows[*]}"
    echo "Aerospace workspace $sid: ${aerospace_state[$sid]}" >> "$log_file"
  done

  # === STEP 2: READ SKETCHYBAR STATE ===

  # Get existing sketchybar workspaces
  mapfile -t sketchy_workspace_ids < <(sketchybar --query bar 2>/dev/null | jq -r '.items[]? // empty | select(test("^workspace\\.start\\.\\d+$"))' | sed 's/workspace\.start\.//' | sort -n)
  echo "Sketchybar workspaces: ${sketchy_workspace_ids[*]}" >> "$log_file"

  # Get all window items
  mapfile -t sketchy_window_items < <(sketchybar --query bar 2>/dev/null | jq -r '.items[]? // empty | select(test("^window\\."))' | sort)
  echo "Sketchybar window items count: ${#sketchy_window_items[@]}" >> "$log_file"

  # === STEP 3: SYNC WORKSPACES ===

  # Remove sketchybar workspaces that don't exist in aerospace
  for sid in "${sketchy_workspace_ids[@]}"; do
    exists=false
    for aerospace_sid in "${aerospace_workspace_ids[@]}"; do
      if [[ "$sid" == "$aerospace_sid" ]]; then
        exists=true
        break
      fi
    done

    if [[ $exists == false ]]; then
      echo "Removing workspace $sid (doesn't exist in aerospace)" >> "$log_file"

      # Remove all window items in this workspace
      for item in "${sketchy_window_items[@]}"; do
        local item_sid=$(echo "$item" | awk -F'.' '{print $2}')
        if [[ "$item_sid" == "$sid" ]]; then
          echo "  Removing window item: $item" >> "$log_file"
          sketchy_remove_item "$item"
        fi
      done

      # Remove workspace dividers
      sketchy_remove_item "workspace.start.$sid"
      sketchy_remove_item "workspace.end.$sid"
      sketchy_remove_item "workspace.$sid"
    fi
  done

  # Add sketchybar workspaces that exist in aerospace but not sketchybar
  for sid in "${aerospace_workspace_ids[@]}"; do
    exists=false
    for sketchy_sid in "${sketchy_workspace_ids[@]}"; do
      if [[ "$sid" == "$sketchy_sid" ]]; then
        exists=true
        break
      fi
    done

    if [[ $exists == false ]]; then
      echo "Adding workspace $sid (exists in aerospace but not sketchybar)" >> "$log_file"

      local props=(
        background.padding_left=0
        background.padding_right=0
        background.height=$BACKGROUND_HEIGHT
        background.color=$BAR
        background.corner_radius=0
        width=$WORKSPACE_DIVIDER_WIDTH
        icon.drawing=off
        label.drawing=off
        y_offset=0
      )

      # Find correct position to insert
      local prev_item="aerospace_spaces_spacer"
      for check_sid in "${aerospace_workspace_ids[@]}"; do
        if [[ $check_sid -lt $sid ]]; then
          prev_item="workspace.end.$check_sid"
        else
          break
        fi
      done

      # Add workspace dividers
      sketchy_add_item "workspace.start.$sid" left --set "workspace.start.$sid" "${props[@]}"
      sketchybar --move "workspace.start.$sid" after "$prev_item"

      sketchy_add_item "workspace.end.$sid" left --set "workspace.end.$sid" "${props[@]}"
      sketchybar --move "workspace.end.$sid" after "workspace.start.$sid"

      # Add workspace bracket
      sketchy_add_workspace "$sid"
    fi
  done

  # === STEP 4: SYNC WINDOW ITEMS ===

  # Build list of all aerospace windows
  declare -A aerospace_windows  # window_id -> workspace_id
  for sid in "${aerospace_workspace_ids[@]}"; do
    for window_id in ${aerospace_state[$sid]}; do
      if [[ -n "$window_id" ]]; then
        aerospace_windows[$window_id]=$sid
      fi
    done
  done

  # Remove sketchybar window items that don't exist in aerospace
  for item in "${sketchy_window_items[@]}"; do
    local item_window_id=$(echo "$item" | awk -F'.' '{print $3}')

    if [[ -z "${aerospace_windows[$item_window_id]}" ]]; then
      echo "Removing window item $item (window $item_window_id doesn't exist in aerospace)" >> "$log_file"
      sketchy_remove_item "$item"
    fi
  done

  # Add/update sketchybar window items to match aerospace
  for sid in "${aerospace_workspace_ids[@]}"; do
    for window_id in ${aerospace_state[$sid]}; do
      if [[ -z "$window_id" ]]; then
        continue
      fi

      local appname=$(aerospace list-windows --all --json --format '%{window-id}%{app-name}' | jq -r --arg wid "$window_id" '.[] | select(."window-id" == ($wid | tonumber)) | ."app-name"')

      if [[ -z "$appname" ]]; then
        echo "Skipping window $window_id (no appname)" >> "$log_file"
        continue
      fi

      local correct_item="window.$sid.$window_id.$appname"

      # Check if item exists with correct name
      local item_exists=false
      for existing_item in "${sketchy_window_items[@]}"; do
        if [[ "$existing_item" == "$correct_item" ]]; then
          item_exists=true
          break
        fi
      done

      if [[ $item_exists == false ]]; then
        # Check if item exists with different workspace ID (window moved)
        local old_item=""
        for existing_item in "${sketchy_window_items[@]}"; do
          local existing_wid=$(echo "$existing_item" | awk -F'.' '{print $3}')
          if [[ "$existing_wid" == "$window_id" ]]; then
            old_item="$existing_item"
            break
          fi
        done

        if [[ -n "$old_item" ]]; then
          echo "Removing old item $old_item (window moved)" >> "$log_file"
          sketchy_remove_item "$old_item"
        fi

        # Create new item
        echo "Adding window item $correct_item" >> "$log_file"
        local icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
        local icon_color=$(sketchy_get_space_foreground_color false)

        local props=(
          background.corner_radius=0
          icon.font="$ICON_FONT:$ICON_FONTSIZE"
          icon.width="$APP_WIDTH"
        )

        sketchy_add_item "$correct_item" left \
          --set "$correct_item" "${props[@]}" \
          icon="$icon" icon.color="$icon_color" \
          click_script="aerospace focus --window-id $window_id"

        # Position it correctly
        sketchybar --move "$correct_item" before "workspace.end.$sid"
      fi
    done
  done

  # === STEP 5: FIX WINDOW HIGHLIGHTING ===

  echo "Fixing window highlighting..." >> "$log_file"
  local unfocused_color=$(sketchy_get_space_foreground_color false)
  local focused_color=$(sketchy_get_space_foreground_color true)

  # Re-read all window items after additions/removals
  mapfile -t all_window_items < <(sketchybar --query bar 2>/dev/null | jq -r '.items[]? // empty | select(test("^window\\."))')

  for item in "${all_window_items[@]}"; do
    local item_window_id=$(echo "$item" | awk -F'.' '{print $3}')

    if [[ "$item_window_id" == "$focused_window_id" ]]; then
      echo "  Highlighting $item (focused)" >> "$log_file"
      sketchybar --set "$item" icon.color="$focused_color"
    else
      echo "  Unhighlighting $item" >> "$log_file"
      sketchybar --set "$item" icon.color="$unfocused_color"
    fi
  done

  # Update cache
  echo "$focused_window_id" > "$CACHE_DIR/highlighted.window_id"

  # === STEP 6: FIX WORKSPACE HIGHLIGHTING ===

  echo "Fixing workspace highlighting..." >> "$log_file"
  for sid in "${aerospace_workspace_ids[@]}"; do
    if [[ "$sid" == "$focused_sid" ]]; then
      sketchybar --set "workspace.$sid" background.color=$(sketchy_get_space_background_color true)
    else
      sketchybar --set "workspace.$sid" background.color=$(sketchy_get_space_background_color false)
    fi
  done

  echo "$focused_sid" > "$CACHE_DIR/highlighted.workspace"

  echo "State sync complete" >> "$log_file"
}
