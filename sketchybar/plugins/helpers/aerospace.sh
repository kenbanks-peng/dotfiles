#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$CONFIG_DIR/plugins/helpers/util.sh"
source "$CONFIG_DIR/plugins/helpers/app_type.sh"
source "$CONFIG_DIR/env.sh"

# =============================================================================
# Core Data Functions - Fetch once per event, pass data to helpers
# =============================================================================

# Returns JSON array of all windows with metadata
# Usage: all_windows=$(aerospace_all_windows)
aerospace_all_windows() {
  aerospace list-windows --all --json --format "%{window-id}%{app-name}%{workspace}%{workspace-is-focused}"
}

# Extract unique workspace IDs from all_windows JSON
# Usage: workspaces=$(aerospace_get_workspaces "$all_windows")
aerospace_get_workspaces() {
  local json="$1"
  # Filter out empty strings before sorting by number
  echo "$json" | jq -r '[.[].workspace] | unique | map(select(. != "")) | sort_by(tonumber) | .[]'
}

# Extract focused workspace from all_windows JSON
# Usage: focused_sid=$(aerospace_get_focused_workspace "$all_windows")
aerospace_get_focused_workspace() {
  local json="$1"
  # Get workspace where workspace-is-focused is true
  local focused=$(echo "$json" | jq -r '.[] | select(."workspace-is-focused" == true) | .workspace' | head -1)
  if [[ -z "$focused" ]]; then
    # Fallback to aerospace command if no windows have focus info
    focused=$(aerospace list-workspaces --focused)
  fi
  echo "$focused"
}

# Get window IDs in a specific workspace from all_windows JSON (newline-separated)
# Usage: while read -r wid; do ...; done < <(aerospace_get_windows_in_workspace "$all_windows" "$sid")
aerospace_get_windows_in_workspace() {
  local json="$1"
  local sid="$2"
  echo "$json" | jq -r --arg sid "$sid" '.[] | select(.workspace == $sid) | ."window-id"'
}

# Get app name by window ID from all_windows JSON
# Usage: appname=$(aerospace_get_appname_by_windowid "$all_windows" "$window_id")
aerospace_get_appname_by_windowid() {
  local json="$1"
  local window_id="$2"
  echo "$json" | jq -r --arg wid "$window_id" '.[] | select(."window-id" == ($wid | tonumber)) | ."app-name"'
}

# Get focused window ID using aerospace (no yabai dependency)
# Usage: focused_window_id=$(aerospace_get_focused_window_id)
aerospace_get_focused_window_id() {
  aerospace list-windows --focused --format '%{window-id}' 2>/dev/null | head -1
}

# Get window IDs for a specific app from all_windows JSON
# Usage: window_ids=$(aerospace_get_window_ids_for_app "$all_windows" "$app_name")
aerospace_get_window_ids_for_app() {
  local json="$1"
  local app_name="$2"
  echo "$json" | jq -r --arg app "$app_name" '.[] | select(."app-name" == $app) | ."window-id"' | tr '\n' ' ' | sed 's/ $//'
}

# =============================================================================
# Legacy Functions - DEPRECATED: Use new data accessor functions above
# These make individual subprocess calls. Prefer fetching all_windows once
# and using aerospace_get_* functions for better performance.
# =============================================================================

# DEPRECATED: Use aerospace_get_workspaces() with all_windows JSON
aerospace_workspaces() {
  echo "$(aerospace list-workspaces --all)"
}

# DEPRECATED: Use aerospace_get_focused_workspace() with all_windows JSON
aerospace_focused_workspace() {
  echo "$(aerospace list-workspaces --focused)"
}

# DEPRECATED: Use aerospace_get_windows_in_workspace() with all_windows JSON
aerospace_window_ids_in_workspace() {
  local sid="$1"
  local json=$(aerospace list-windows --workspace "$sid" --json --format %{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name})
  local filtered=$(echo "$json" | jq -r '.[] | ."window-id"' | jq -s -r 'join(" ")')
  echo "$filtered"
}

# DEPRECATED: Use aerospace_get_appname_by_windowid() with all_windows JSON
aerospace_appname_from_window_id() {
  local window_id="$1"
  local json=$(aerospace list-windows --all --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')
  local filtered=$(echo "$json" | jq -r --arg window_id "$window_id" '.[] | select(."window-id" == ($window_id | tonumber)) | ."app-name"')
  echo "$filtered"
}

# DEPRECATED: Use aerospace_get_window_ids_for_app() with all_windows JSON
aerospace_window_ids_for_app() {
  local app_name="$1"
  local json=$(aerospace list-windows --all --json --format '%{monitor-id}%{workspace}%{app-bundle-id}%{window-id}%{app-name}')
  local filtered=$(echo "$json" | jq -r --arg app_name "$app_name" '.[] | select(."app-name" == $app_name) | ."window-id"' | jq -s -r 'join(" ")')
  echo "$filtered"
}

remove_unmatched_items() {
  local sid="$1"
  local all_windows="$2"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  # Convert newlines to spaces for unmatched_items comparison
  aerospace_window_ids=$(aerospace_get_windows_in_workspace "$all_windows" "$sid" | tr '\n' ' ')
  sketchy_apps=$(sketchy_get_window_items_in_spaceid "$sid")
  apps_to_remove=$(unmatched_items "$aerospace_window_ids" "$sketchy_apps")
  if [[ -n "$apps_to_remove" ]]; then
    sketchy_remove_item "$apps_to_remove"
  fi
}


aerospace_workspace_change() {
  local sid="$1"
  local prev_sid="$2"
  local all_windows="$3"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  # move sticky apps to current workspace
  apptype_show_sticky_apps "$sid" "$prev_sid" "$all_windows"

  # keep prev workspace in sync
  remove_unmatched_items "$prev_sid" "$all_windows"

  # keep current workspace in sync
  aerospace_add_apps_in_spaceid "$sid" "$all_windows"

  # highlight workspace
  sketchy_highlight_workspace "$sid"

  # Sync workspaces after workspace change
  sync_workspaces "$all_windows"
}

aerospace_focused_window_change() {
  local window_id="$1"
  local all_windows="$2"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  local sid=$(aerospace_get_focused_workspace "$all_windows")

  if [[ -z "$window_id" ]]; then
    window_id=$(aerospace_get_focused_window_id)
  fi

  sketchy_highlight_workspace "$sid"
  sketchy_highlight_window_id "$window_id"
}

# Removed: maybe_add_default_item_to_spaceid - no longer needed with persistent-workspaces=[]
# Removed: maybe_remove_default_item_from_spaceid - no longer needed with persistent-workspaces=[]

# Rebuild workspaces: intelligently update workspace order without unnecessary removals
rebuild_workspaces() {
  local all_windows="$1"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  # Get workspaces from JSON (build array portably)
  local occupied_workspaces=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && occupied_workspaces+=("$ws")
  done < <(aerospace_get_workspaces "$all_windows")

  local existing_workspaces=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && existing_workspaces+=("$ws")
  done < <(sketchybar --query bar | jq -r '.items[] | select(test("^workspace\\.start\\.\\d+$"))' | sed 's/workspace\.start\.//')

  # Step 1: Remove workspaces that no longer exist (but NOT window items - Step 3 will handle those)
  for sid in "${existing_workspaces[@]}"; do
    if ! printf '%s\n' "${occupied_workspaces[@]}" | grep -q "^${sid}$"; then
      # Workspace no longer exists - remove only the workspace dividers, not window items
      sketchy_remove_item "workspace.start.$sid"
      sketchy_remove_item "workspace.end.$sid"
      sketchy_remove_item "workspace.$sid"
    fi
  done

  # Step 2: Reorder existing workspaces and add missing ones
  local prev_end="aerospace_spaces_spacer"
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

  for sid in "${occupied_workspaces[@]}"; do
    local start="workspace.start.$sid"
    local end="workspace.end.$sid"

    # Check if workspace already exists
    if printf '%s\n' "${existing_workspaces[@]}" | grep -q "^${sid}$"; then
      # Workspace exists - just move it to correct position
      sketchybar --move "$start" after "$prev_end"
      sketchybar --move "$end" after "$start"

      # Move all window items for this workspace to correct position
      local window_items=()
      while IFS= read -r wi; do
        [[ -n "$wi" ]] && window_items+=("$wi")
      done < <(sketchybar --query bar | jq -r --arg sid "$sid" '.items[] | select(test("^window\\." + $sid + "\\."))' | sort)
      local prev_item="$start"
      for item in "${window_items[@]}"; do
        sketchybar --move "$item" after "$prev_item"
        prev_item="$item"
      done
    else
      # Workspace doesn't exist - create it (Step 3 will populate windows)
      sketchy_add_item "$start" left \
        --set "$start" "${props[@]}"
      sketchybar --move "$start" after "$prev_end"

      sketchy_add_item "$end" left \
        --set "$end" "${props[@]}"
      sketchybar --move "$end" after "$start"

      sketchy_add_workspace "$sid"
    fi

    prev_end="$end"
  done

  # Step 3: Update window items to match aerospace's current state
  # First, get ALL window items across all workspaces
  local all_sketchy_items=()
  while IFS= read -r si; do
    [[ -n "$si" ]] && all_sketchy_items+=("$si")
  done < <(sketchybar --query bar | jq -r '.items[] | select(test("^window\\."))' | sort)

  for sid in "${occupied_workspaces[@]}"; do
    # Add/update windows and ensure correct order
    local prev_item="workspace.start.$sid"

    # Iterate over window IDs using while-read
    while IFS= read -r window_id; do
      [[ -z "$window_id" ]] && continue
      local appname=$(aerospace_get_appname_by_windowid "$all_windows" "$window_id")

      if [[ -z "$window_id" ]] || [[ -z "$appname" ]]; then
        continue
      fi

      # NOTE: Do NOT use apptype_allow_app here - rebuild syncs ALL windows that aerospace has
      # Filtering is done when windows are initially added, not during rebuild

      # The correct item name for this window in this workspace
      local correct_item="window.$sid.$window_id.$appname"

      # Find if an item with this window_id exists anywhere (might be in wrong workspace)
      local existing_item=""
      for item in "${all_sketchy_items[@]}"; do
        # Extract window_id from item name (format: window.SID.WINDOW_ID.APPNAME)
        local item_window_id=$(echo "$item" | awk -F'.' '{print $3}')
        if [[ "$item_window_id" == "$window_id" ]]; then
          existing_item="$item"
          break
        fi
      done

      if [[ -n "$existing_item" && "$existing_item" == "$correct_item" ]]; then
        # Item exists with correct name - just move to correct position
        sketchybar --move "$correct_item" after "$prev_item"
      elif [[ -n "$existing_item" ]]; then
        # Item exists but with wrong workspace ID in name - remove old, create new
        sketchy_remove_item "$existing_item"

        local icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
        local icon_color="$(sketchy_get_space_foreground_color false)"
        local item_props=(
          background.corner_radius=0
          icon.font="$ICON_FONT:$ICON_FONTSIZE"
          icon.width="$APP_WIDTH"
        )

        sketchy_add_item "$correct_item" left \
          --set "$correct_item" "${item_props[@]}" \
          icon="$icon" icon.color="$icon_color" \
          click_script="aerospace focus --window-id $window_id"
        sketchybar --move "$correct_item" after "$prev_item"
      else
        # Item doesn't exist - create it
        local icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
        local icon_color="$(sketchy_get_space_foreground_color false)"
        local item_props=(
          background.corner_radius=0
          icon.font="$ICON_FONT:$ICON_FONTSIZE"
          icon.width="$APP_WIDTH"
        )

        sketchy_add_item "$correct_item" left \
          --set "$correct_item" "${item_props[@]}" \
          icon="$icon" icon.color="$icon_color" \
          click_script="aerospace focus --window-id $window_id"
        sketchybar --move "$correct_item" after "$prev_item"
      fi

      prev_item="$correct_item"
    done < <(aerospace_get_windows_in_workspace "$all_windows" "$sid")
  done

  # Step 3.5: Remove any orphaned window items (windows that no longer exist in any workspace)
  # Extract all window IDs from all_windows JSON
  local all_aerospace_window_ids=()
  while IFS= read -r wid; do
    [[ -n "$wid" ]] && all_aerospace_window_ids+=("$wid")
  done < <(echo "$all_windows" | jq -r '.[]."window-id"')

  for item in "${all_sketchy_items[@]}"; do
    local item_window_id=$(echo "$item" | awk -F'.' '{print $3}')
    if ! printf '%s\n' "${all_aerospace_window_ids[@]}" | grep -q "^${item_window_id}$"; then
      sketchy_remove_item "$item"
    fi
  done

  # Step 4: Highlight current workspace and focused window
  local focused_sid=$(aerospace_get_focused_workspace "$all_windows")
  sketchy_highlight_workspace "$focused_sid"

  local focused_window_id=$(aerospace_get_focused_window_id)
  if [[ -n "$focused_window_id" ]]; then
    sketchy_highlight_window_id "$focused_window_id"
  fi
}

# Sync workspaces: add workspace dividers for new workspaces, remove for empty ones
sync_workspaces() {
  local all_windows="$1"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  # Get workspaces from JSON (build array portably)
  local occupied_workspaces=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && occupied_workspaces+=("$ws")
  done < <(aerospace_get_workspaces "$all_windows")

  local sketchy_workspaces=()
  while IFS= read -r sw; do
    [[ -n "$sw" ]] && sketchy_workspaces+=("$sw")
  done < <(sketchybar --query bar | jq -r '.items[] | select(test("^workspace\\.start\\.\\d+$"))' | sed 's/workspace\.start\.//')

  # Add missing workspaces
  for sid in "${occupied_workspaces[@]}"; do
    if ! printf '%s\n' "${sketchy_workspaces[@]}" | grep -q "^${sid}$"; then
      # Workspace doesn't exist in sketchybar, add it
      local start="workspace.start.$sid"
      local end="workspace.end.$sid"

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

      # Find the correct position to insert this workspace
      # Look for the next higher workspace number that exists in sketchybar
      local position_found=false
      for next_sid in "${occupied_workspaces[@]}"; do
        if [[ "$next_sid" -gt "$sid" ]]; then
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
      if [[ "$position_found" = false ]]; then
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
      aerospace_add_apps_in_spaceid "$sid" "$all_windows"
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
}


aerospace_new_window_id() {
  local window_id="$1"
  local all_windows="$2"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  local sid=$(aerospace_get_focused_workspace "$all_windows")

  # Skip if window_id is empty
  if [[ -z "$window_id" ]]; then
    return
  fi

  # Get appname from all_windows JSON
  local appname=$(aerospace_get_appname_by_windowid "$all_windows" "$window_id")

  # Skip if appname is empty
  if [[ -z "$appname" ]]; then
    return
  fi

  local item="window.$sid.$window_id.$appname"

  local icon="$($CONFIG_DIR/icons_apps.sh "$appname")"
  local icon_color="$(sketchy_get_space_foreground_color false)"

  local props=(
    background.corner_radius=0
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
    icon.width="$APP_WIDTH"
  )

  # Get aerospace's window ordering for this workspace from all_windows JSON
  # Build array portably using while-read
  local aerospace_window_order=()
  while IFS= read -r wid; do
    [[ -n "$wid" ]] && aerospace_window_order+=("$wid")
  done < <(aerospace_get_windows_in_workspace "$all_windows" "$sid")

  # Find the position of this window in aerospace's ordering
  local position=-1
  local index=0
  for ordered_window_id in "${aerospace_window_order[@]}"; do
    if [[ "$ordered_window_id" = "$window_id" ]]; then
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
  if [[ $position -eq 0 ]]; then
    # First window, move right after workspace.start
    sketchybar --move "$item" after "workspace.start.$sid"
  else
    # Find the window that should be before this one
    local prev_index=$((position - 1))
    local prev_window_id="${aerospace_window_order[$prev_index]}"
    local prev_item=$(sketchy_get_item_by_window_id "$prev_window_id")

    if [[ -n "$prev_item" ]]; then
      # Insert after the previous window
      sketchybar --move "$item" after "$prev_item"
    else
      # Fallback: insert before workspace.end
      sketchybar --move "$item" before "workspace.end.$sid"
    fi
  fi

  sketchy_highlight_window_id "$window_id"

  # Sync workspaces after adding window
  sync_workspaces "$all_windows"
}

aerospace_add_apps_in_spaceid() {
  local sid="$1"
  local all_windows="$2"

  # Use passed all_windows or fetch if not provided
  if [[ -z "$all_windows" ]]; then
    all_windows=$(aerospace_all_windows)
  fi

  local props=(
    y_offset=1
    background.corner_radius=0
    icon.font="$ICON_FONT:$ICON_FONTSIZE"
    icon.width="$APP_WIDTH"
  )

  local prev_item="workspace.start.$sid"

  # Iterate over window IDs using while-read (portable across bash/zsh)
  while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue

    # Get appname from all_windows JSON
    local appname=$(aerospace_get_appname_by_windowid "$all_windows" "$window_id")

    # Skip windows with empty appname
    if [[ -z "$appname" ]]; then
      continue
    fi

    # Skip excluded apps (no more dialog check - aerospace doesn't track dialogs)
    if ! apptype_allow_app "$appname"; then
      continue
    fi

    local item="window.$sid.$window_id.$appname"
    local icon="$($CONFIG_DIR/icons_apps.sh "$appname")"

    # Check if item already exists
    local items=$(sketchybar --query bar | jq -r '.items[]')
    if ! item_in_array "$item" "$items"; then
      # New item - set all properties including icon.color
      local icon_color="$(sketchy_get_space_foreground_color false)"
      sketchy_add_item "$item" left \
        --set "$item" "${props[@]}" \
        icon="$icon" icon.color="$icon_color" \
        click_script="aerospace focus --window-id $window_id"
    else
      # Existing item - update properties but preserve icon.color (which might be highlighted)
      sketchy_add_item "$item" left \
        --set "$item" "${props[@]}" \
        icon="$icon" \
        click_script="aerospace focus --window-id $window_id"
    fi

    # Position after the previous item to maintain aerospace's order
    sketchybar --move "$item" after "$prev_item"
    prev_item="$item"
  done < <(aerospace_get_windows_in_workspace "$all_windows" "$sid")
}


# Create a new workspace after the last occupied one and switch to it
# Migrated from scripts/new_workspace.sh
aerospace_create_new_workspace() {
  # Get all occupied workspaces sorted numerically
  local occupied=($(aerospace list-workspaces --all | sort -n))

  if [[ ${#occupied[@]} -eq 0 ]]; then
    # No workspaces, go to 1
    aerospace workspace 1
    return 0
  fi

  # Get the last (highest) occupied workspace
  local last_workspace="${occupied[-1]}"

  # Calculate next workspace
  local next_workspace=$((last_workspace + 1))

  # Cap at 9 (max workspace in aerospace config)
  if [[ $next_workspace -le 9 ]]; then
    aerospace workspace "$next_workspace"
  else
    # Already at max, just go to workspace 9
    aerospace workspace 9
  fi
}


# Smart window movement using state-based approach
# Migrated from scripts/smart_move_window.sh
aerospace_smart_move_window() {
  local direction="$1"  # "next" or "prev"

  # === STEP 1: READ CURRENT STATE ===

  local current_sid=$(aerospace list-workspaces --focused)
  local focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')

  # Build current state: array of workspaces, each with array of window_ids
  declare -A current_state  # workspace_id -> "window_id1 window_id2 ..."
  local workspace_ids=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && workspace_ids+=("$ws")
  done < <(aerospace list-workspaces --all | sort -n)

  for sid in "${workspace_ids[@]}"; do
    local windows=()
    while IFS= read -r w; do
      [[ -n "$w" ]] && windows+=("$w")
    done < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
    current_state[$sid]="${windows[*]}"
  done

  # Find current workspace index
  local current_index=-1
  for i in "${!workspace_ids[@]}"; do
    if [[ "${workspace_ids[$i]}" == "$current_sid" ]]; then
      current_index=$i
      break
    fi
  done

  if [[ $current_index -eq -1 ]]; then
    return 1
  fi

  # === STEP 2: CALCULATE DESIRED END STATE ===

  # Count windows in current workspace
  local window_count=$(echo "${current_state[$current_sid]}" | wc -w | tr -d ' ')

  # Determine if at edge
  local is_at_edge target_index
  if [[ "$direction" == "next" ]]; then
    is_at_edge=$((current_index == ${#workspace_ids[@]} - 1))
    target_index=$((current_index + 1))
  elif [[ "$direction" == "prev" ]]; then
    is_at_edge=$((current_index == 0))
    target_index=$((current_index - 1))
  fi

  # Calculate desired state
  declare -A desired_state
  declare -a desired_workspace_ids
  local new_focused_sid="$current_sid"
  local new_focused_window_id="$focused_window_id"

  if [[ $window_count -gt 1 ]]; then
    # === MULTIPLE WINDOWS: MOVE FOCUSED WINDOW ===

    if [[ $is_at_edge -eq 1 ]]; then
      # Create new workspace at edge

      if [[ "$direction" == "next" ]]; then
        # Add workspace at end
        local new_sid=$((workspace_ids[-1] + 1))
        if [[ $new_sid -gt 9 ]]; then
          # Copy current state as desired state
          for sid in "${workspace_ids[@]}"; do
            desired_state[$sid]="${current_state[$sid]}"
          done
          desired_workspace_ids=("${workspace_ids[@]}")
        else
          # Remove focused window from current, add to new workspace
          for sid in "${workspace_ids[@]}"; do
            if [[ $sid -eq $current_sid ]]; then
              # Remove focused window from current workspace
              local windows=()
              for window_id in ${current_state[$sid]}; do
                if [[ $window_id != $focused_window_id ]]; then
                  windows+=("$window_id")
                fi
              done
              desired_state[$sid]="${windows[*]}"
            else
              desired_state[$sid]="${current_state[$sid]}"
            fi
          done
          # Add new workspace with focused window
          desired_state[$new_sid]="$focused_window_id"
          desired_workspace_ids=("${workspace_ids[@]}" "$new_sid")
          new_focused_sid="$new_sid"
        fi
      else
        # Add workspace at beginning (use temp workspace 0, then renumber)
        # Remove focused window from current workspace
        for sid in "${workspace_ids[@]}"; do
          if [[ $sid -eq $current_sid ]]; then
            local windows=()
            for window_id in ${current_state[$sid]}; do
              if [[ $window_id != $focused_window_id ]]; then
                windows+=("$window_id")
              fi
            done
            desired_state[$((sid + 1))]="${windows[*]}"
          else
            desired_state[$((sid + 1))]="${current_state[$sid]}"
          fi
        done
        # Add new workspace 1 with focused window
        desired_state[1]="$focused_window_id"
        # Rebuild workspace ID list
        desired_workspace_ids=()
        for ((i=1; i<=${#workspace_ids[@]}+1; i++)); do
          if [[ -n "${desired_state[$i]}" ]]; then
            desired_workspace_ids+=("$i")
          fi
        done
        new_focused_sid=1
      fi
    else
      # Move to existing adjacent workspace
      local target_sid="${workspace_ids[$target_index]}"

      for sid in "${workspace_ids[@]}"; do
        if [[ $sid -eq $current_sid ]]; then
          # Remove focused window from current
          local windows=()
          for window_id in ${current_state[$sid]}; do
            if [[ $window_id != $focused_window_id ]]; then
              windows+=("$window_id")
            fi
          done
          desired_state[$sid]="${windows[*]}"
        elif [[ $sid -eq $target_sid ]]; then
          # Add focused window to target
          desired_state[$sid]="${current_state[$sid]} $focused_window_id"
        else
          desired_state[$sid]="${current_state[$sid]}"
        fi
      done
      desired_workspace_ids=("${workspace_ids[@]}")
      new_focused_sid="$target_sid"
    fi

  else
    # === SINGLE WINDOW: RIPPLE ===

    if [[ $is_at_edge -eq 1 ]]; then
      # No action at edge with single window
      for sid in "${workspace_ids[@]}"; do
        desired_state[$sid]="${current_state[$sid]}"
      done
      desired_workspace_ids=("${workspace_ids[@]}")
    else
      # Ripple: shift workspaces in direction
      if [[ "$direction" == "next" ]]; then
        # Ripple right: workspaces to the right shift left

        for i in "${!workspace_ids[@]}"; do
          sid="${workspace_ids[$i]}"
          if [[ $i -lt $current_index ]]; then
            # Workspaces before current: unchanged
            desired_state[$sid]="${current_state[$sid]}"
          elif [[ $i -eq $current_index ]]; then
            # Current workspace: gets windows from next workspace
            local next_sid="${workspace_ids[$((i + 1))]}"
            desired_state[$sid]="${current_state[$sid]} ${current_state[$next_sid]}"
          elif [[ $i -gt $current_index ]] && [[ $i -lt $((${#workspace_ids[@]} - 1)) ]]; then
            # Workspaces after current (except last): get windows from next
            local next_sid="${workspace_ids[$((i + 1))]}"
            desired_state[$sid]="${current_state[$next_sid]}"
          fi
          # Last workspace is omitted (will be empty, removed)
        done

        # New workspace list (last one removed)
        desired_workspace_ids=("${workspace_ids[@]:0:${#workspace_ids[@]}-1}")

      else
        # Ripple left: workspaces to the left shift right (to make room)

        for i in "${!workspace_ids[@]}"; do
          sid="${workspace_ids[$i]}"
          if [[ $i -gt $current_index ]]; then
            # Workspaces after current: unchanged
            desired_state[$sid]="${current_state[$sid]}"
          elif [[ $i -eq $current_index ]]; then
            # Current workspace: gets windows from previous workspace PLUS keeps its own
            local prev_sid="${workspace_ids[$((i - 1))]}"
            desired_state[$sid]="${current_state[$prev_sid]} ${current_state[$sid]}"
          elif [[ $i -lt $current_index ]] && [[ $i -gt 0 ]]; then
            # Workspaces before current (except first): shift right (get previous workspace's content)
            local prev_sid="${workspace_ids[$((i - 1))]}"
            desired_state[$sid]="${current_state[$prev_sid]}"
          fi
          # First workspace (i=0) is omitted (will be removed)
        done

        # New workspace list (first one removed)
        desired_workspace_ids=("${workspace_ids[@]:1}")
      fi

      # Renumber to be contiguous starting from 1
      declare -A renumbered_state
      local new_num=1
      for sid in "${desired_workspace_ids[@]}"; do
        renumbered_state[$new_num]="${desired_state[$sid]}"
        if [[ $sid -eq $current_sid ]]; then
          new_focused_sid=$new_num
        fi
        new_num=$((new_num + 1))
      done
      desired_state=()
      for key in "${!renumbered_state[@]}"; do
        desired_state[$key]="${renumbered_state[$key]}"
      done
      desired_workspace_ids=()
      for ((i=1; i<$new_num; i++)); do
        desired_workspace_ids+=("$i")
      done
    fi
  fi

  # === STEP 3: APPLY CHANGES ===

  # Apply to aerospace
  for sid in "${desired_workspace_ids[@]}"; do
    for window_id in ${desired_state[$sid]}; do
      if [[ -n "$window_id" ]]; then
        # Check if window needs to move
        local current_ws=""
        for check_sid in "${workspace_ids[@]}"; do
          if echo "${current_state[$check_sid]}" | grep -qw "$window_id"; then
            current_ws="$check_sid"
            break
          fi
        done

        if [[ "$current_ws" != "$sid" ]]; then
          aerospace move-node-to-workspace "$sid" --window-id "$window_id" </dev/null 2>/dev/null
        fi
      fi
    done
  done

  # Focus the new workspace and window
  if [[ "$new_focused_sid" != "$current_sid" ]]; then
    aerospace workspace "$new_focused_sid" </dev/null 2>/dev/null
  fi

  if [[ "$new_focused_window_id" != "$focused_window_id" ]] || [[ "$new_focused_sid" != "$current_sid" ]]; then
    aerospace focus --window-id "$new_focused_window_id" </dev/null 2>/dev/null
  fi

  # Update window items: ensure items match aerospace state

  # Get all current window items from sketchybar (build array portably)
  local all_window_items=()
  while IFS= read -r wi; do
    [[ -n "$wi" ]] && all_window_items+=("$wi")
  done < <(sketchybar --query bar 2>/dev/null | jq -r '.items[]? // empty | select(test("^window\\."))' | sort)

  # Build map of window_id -> correct_workspace_id from aerospace
  declare -A window_workspace_map
  for sid in "${desired_workspace_ids[@]}"; do
    for window_id in ${desired_state[$sid]}; do
      if [[ -n "$window_id" ]]; then
        window_workspace_map[$window_id]=$sid
      fi
    done
  done

  # Check each sketchybar item and fix if needed
  for item in "${all_window_items[@]}"; do
    # Extract: window.SID.WINDOW_ID.APPNAME (appname may contain spaces)
    # Split on first 3 dots to get SID, WINDOW_ID, and everything else as APPNAME
    local item_sid=$(echo "$item" | awk -F'.' '{print $2}')
    local item_window_id=$(echo "$item" | awk -F'.' '{print $3}')
    # Get everything after the 3rd dot (handles spaces in appname)
    local item_appname=$(echo "$item" | sed 's/^[^.]*\.[^.]*\.[^.]*\.//')

    # Get correct workspace from aerospace
    local correct_sid="${window_workspace_map[$item_window_id]}"

    if [[ -z "$correct_sid" ]]; then
      # Window no longer exists in aerospace, remove from sketchybar
      sketchy_remove_item "$item"
    elif [[ "$item_sid" != "$correct_sid" ]]; then
      # Item has wrong workspace ID, recreate it
      local icon="$($CONFIG_DIR/icons_apps.sh "$item_appname" 2>/dev/null || echo "")"
      local item_color=$(sketchy_get_space_foreground_color false)

      # Remove old item
      sketchy_remove_item "$item"

      # Create new item with correct workspace ID
      local correct_item="window.$correct_sid.$item_window_id.$item_appname"
      local props=(
        background.corner_radius=0
        icon.font="$ICON_FONT:$ICON_FONTSIZE"
        icon.width="$APP_WIDTH"
      )

      sketchy_add_item "$correct_item" left \
        --set "$correct_item" "${props[@]}" \
        icon="$icon" icon.color="$item_color" \
        click_script="aerospace focus --window-id $item_window_id"

      # Position it
      sketchybar --move "$correct_item" before "workspace.end.$correct_sid"
    fi
  done

  # Sync workspaces to create dividers and background bracket for new workspaces
  sync_workspaces

  # Highlight the focused workspace and window after sync
  sketchy_highlight_workspace "$new_focused_sid"
  sketchy_highlight_window_id "$new_focused_window_id"
}

aerospace_workspace_next() {
  # Get current workspace
  local current_sid=$(aerospace list-workspaces --focused)

  # Get all workspaces sorted (build array portably)
  local workspace_ids=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && workspace_ids+=("$ws")
  done < <(aerospace list-workspaces --all | sort -n)

  # Find current workspace index
  local current_index=-1
  for i in "${!workspace_ids[@]}"; do
    if [[ "${workspace_ids[$i]}" == "$current_sid" ]]; then
      current_index=$i
      break
    fi
  done

  if [[ $current_index -eq -1 ]]; then
    return 1
  fi

  # Check if we're at the last workspace
  if [[ $current_index -eq $((${#workspace_ids[@]} - 1)) ]]; then
    # At the end, create new workspace
    aerospace_create_new_workspace
  else
    # Not at the end, switch to next workspace
    local next_index=$((current_index + 1))
    local next_sid="${workspace_ids[$next_index]}"
    aerospace workspace "$next_sid"
  fi
}

# Swap focused workspace with adjacent workspace (left or right)
# This swaps all windows between the two workspaces and updates sketchybar
aerospace_swap_workspace() {
  local direction="$1"  # "left" or "right"

  # Get current workspace and focused window
  local current_sid=$(aerospace list-workspaces --focused)
  local focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')

  # Get all workspaces sorted (build array portably)
  local workspace_ids=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && workspace_ids+=("$ws")
  done < <(aerospace list-workspaces --all | sort -n)

  # Find current workspace index
  local current_index=-1
  for i in "${!workspace_ids[@]}"; do
    if [[ "${workspace_ids[$i]}" == "$current_sid" ]]; then
      current_index=$i
      break
    fi
  done

  if [[ $current_index -eq -1 ]]; then
    return 1
  fi

  # Determine target workspace based on direction
  local target_index
  if [[ "$direction" == "left" ]]; then
    target_index=$((current_index - 1))
  else
    target_index=$((current_index + 1))
  fi

  # Check bounds
  if [[ $target_index -lt 0 ]] || [[ $target_index -ge ${#workspace_ids[@]} ]]; then
    # No workspace to swap with in that direction
    return 0
  fi

  local target_sid="${workspace_ids[$target_index]}"

  # Get windows in each workspace
  local current_windows=($(aerospace_window_ids_in_workspace "$current_sid"))
  local target_windows=($(aerospace_window_ids_in_workspace "$target_sid"))

  # Query bar state once for existing items
  local bar_items=$(sketchybar --query bar 2>/dev/null | jq -r '.items[]')

  # Move all windows from current to a temp workspace (use 99 as temp)
  local temp_ws=99
  for window_id in "${current_windows[@]}"; do
    if [[ -n "$window_id" ]]; then
      aerospace move-node-to-workspace "$temp_ws" --window-id "$window_id" </dev/null 2>/dev/null
    fi
  done

  # Move all windows from target to current
  for window_id in "${target_windows[@]}"; do
    if [[ -n "$window_id" ]]; then
      aerospace move-node-to-workspace "$current_sid" --window-id "$window_id" </dev/null 2>/dev/null
    fi
  done

  # Move all windows from temp to target
  for window_id in "${current_windows[@]}"; do
    if [[ -n "$window_id" ]]; then
      aerospace move-node-to-workspace "$target_sid" --window-id "$window_id" </dev/null 2>/dev/null
    fi
  done

  # Focus follows the originally focused window to its new workspace (target_sid)
  aerospace workspace "$target_sid" </dev/null 2>/dev/null
  if [[ -n "$focused_window_id" ]]; then
    aerospace focus --window-id "$focused_window_id" </dev/null 2>/dev/null
  fi

  # Build batched sketchybar commands for all updates
  local batch_args=()

  # Get all window items (build array portably)
  local all_window_items=()
  while IFS= read -r wi; do
    [[ -n "$wi" ]] && all_window_items+=("$wi")
  done < <(echo "$bar_items" | grep "^window\." | sort)

  # Collect items to remove and items to add
  declare -A items_to_update  # old_item -> new_item

  for item in "${all_window_items[@]}"; do
    local item_sid=$(echo "$item" | awk -F'.' '{print $2}')
    local item_window_id=$(echo "$item" | awk -F'.' '{print $3}')
    local item_appname=$(echo "$item" | sed 's/^[^.]*\.[^.]*\.[^.]*\.//')

    local new_sid=""
    # Check if this window was in current workspace (now should be in target)
    for wid in "${current_windows[@]}"; do
      if [[ "$wid" == "$item_window_id" ]]; then
        new_sid="$target_sid"
        break
      fi
    done
    # Check if this window was in target workspace (now should be in current)
    if [[ -z "$new_sid" ]]; then
      for wid in "${target_windows[@]}"; do
        if [[ "$wid" == "$item_window_id" ]]; then
          new_sid="$current_sid"
          break
        fi
      done
    fi

    # If we need to update this item
    if [[ -n "$new_sid" && "$item_sid" != "$new_sid" ]]; then
      local correct_item="window.$new_sid.$item_window_id.$item_appname"
      items_to_update["$item"]="$correct_item:$item_window_id:$item_appname:$new_sid"
    fi
  done

  # Build batch: remove old items, add new items, move them, then highlight
  for old_item in "${!items_to_update[@]}"; do
    batch_args+=(--remove "$old_item")
  done

  local icon_color=$(sketchy_get_space_foreground_color false)
  local focused_color=$(sketchy_get_space_foreground_color true)

  for old_item in "${!items_to_update[@]}"; do
    IFS=':' read -r correct_item item_window_id item_appname new_sid <<< "${items_to_update[$old_item]}"
    local icon="$($CONFIG_DIR/icons_apps.sh "$item_appname" 2>/dev/null || echo "")"

    # Determine if this is the focused window
    local this_icon_color="$icon_color"
    if [[ "$item_window_id" == "$focused_window_id" ]]; then
      this_icon_color="$focused_color"
    fi

    batch_args+=(
      --add item "$correct_item" left
      --set "$correct_item"
        background.corner_radius=0
        "icon.font=$ICON_FONT:$ICON_FONTSIZE"
        "icon.width=$APP_WIDTH"
        "icon=$icon"
        "icon.color=$this_icon_color"
        "click_script=aerospace focus --window-id $item_window_id"
      --move "$correct_item" before "workspace.end.$new_sid"
    )
  done

  # Add highlight commands for workspaces
  local unfocused_bg=$(sketchy_get_space_background_color false)
  local focused_bg=$(sketchy_get_space_background_color true)

  # Unhighlight current_sid (no longer focused), highlight target_sid (now focused)
  batch_args+=(
    --set "workspace.$current_sid" "background.color=$unfocused_bg"
    --set "workspace.$target_sid" "background.color=$focused_bg"
  )

  # Execute all sketchybar commands in a single batch
  if [[ ${#batch_args[@]} -gt 0 ]]; then
    sketchybar -m "${batch_args[@]}"
  fi
}

