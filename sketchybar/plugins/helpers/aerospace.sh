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
  aerospace list-windows --all --json --format "%{window-id}%{app-name}%{window-title}%{workspace}%{workspace-is-focused}"
}

# Ensure all_windows is populated - returns passed value or fetches fresh
# Usage: all_windows=$(aerospace_ensure_all_windows "$all_windows")
aerospace_ensure_all_windows() {
  local all_windows="$1"
  if [[ -n "$all_windows" ]]; then
    echo "$all_windows"
  else
    aerospace_all_windows
  fi
}

# Read props from a getter function into an array
# Usage: local props=($(props_to_array get_window_item_props))
# Or for explicit control:
#   local props=()
#   props_to_array get_window_item_props props
props_to_array() {
  local getter="$1"
  local -n arr="${2:-_props_tmp}"  # Use nameref if array name provided

  if [[ -z "$2" ]]; then
    # No array provided, just output for $() capture
    $getter
  else
    # Array name provided, populate it directly
    while IFS= read -r line; do
      [[ -n "$line" ]] && arr+=("$line")
    done < <($getter)
  fi
}

# Parse window item name into components
# Usage: parse_window_item "$item" sid wid appname
# Sets variables: sid, wid, appname
parse_window_item() {
  local item="$1"
  local -n _sid="$2"
  local -n _wid="$3"
  local -n _appname="$4"

  _sid=$(echo "$item" | awk -F'.' '{print $2}')
  _wid=$(echo "$item" | awk -F'.' '{print $3}')
  _appname=$(echo "$item" | sed 's/^[^.]*\.[^.]*\.[^.]*\.//')
}

# Create or update a window item in sketchybar
# Usage: aerospace_create_window_item "$item" "$window_id" "$appname" "$icon_color" [--move-after "$ref_item"]
aerospace_create_window_item() {
  local item="$1"
  local window_id="$2"
  local appname="$3"
  local icon_color="$4"
  local move_ref=""
  local move_pos=""

  # Parse optional --move-after or --move-before
  shift 4
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --move-after)
        move_pos="after"
        move_ref="$2"
        shift 2
        ;;
      --move-before)
        move_pos="before"
        move_ref="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  local icon="$($CONFIG_DIR/helpers/icons/icons_apps.sh "$appname" 2>/dev/null || echo "")"

  # Get props
  local props=()
  props_to_array get_window_item_props props

  sketchy_add_item "$item" left \
    --set "$item" "${props[@]}" \
    icon="$icon" icon.color="$icon_color" \
    click_script="aerospace focus --window-id $window_id"

  # Move if requested
  if [[ -n "$move_ref" && -n "$move_pos" ]]; then
    sketchybar --move "$item" "$move_pos" "$move_ref"
  fi
}

# Returns JSON array of all workspaces
# Usage: workspaces_json=$(aerospace_list_workspaces_json)
# Output: [{"workspace": "1"}, {"workspace": "2"}, ...]
aerospace_list_workspaces_json() {
  aerospace list-workspaces --all --json
}

# Get sorted workspace IDs from JSON (returns newline-separated list)
# Usage: while read -r sid; do ...; done < <(aerospace_get_workspace_ids_sorted "$workspaces_json")
# Or from all_windows: aerospace_get_workspace_ids_sorted "$(aerospace_list_workspaces_json)"
aerospace_get_workspace_ids_sorted() {
  local json="$1"
  echo "$json" | jq -r '[.[].workspace] | map(select(. != "")) | sort_by(tonumber) | .[]'
}

# Find next/prev workspace ID given current workspace
# Usage: next_sid=$(aerospace_adjacent_workspace "$workspaces_json" "$current_sid" "next")
# Returns empty string if at boundary
aerospace_adjacent_workspace() {
  local json="$1"
  local current_sid="$2"
  local direction="$3"  # "next" or "prev"

  echo "$json" | jq -r --arg sid "$current_sid" --arg dir "$direction" '
    [.[].workspace] | map(select(. != "")) | sort_by(tonumber) |
    (to_entries | map(select(.value == $sid)) | .[0].key) as $idx |
    if $idx == null then ""
    elif $dir == "next" then .[$idx + 1] // ""
    else (if $idx > 0 then .[$idx - 1] else "" end)
    end
  '
}

# Get workspaces to add (in aerospace but not in sketchybar)
# Usage: while read -r sid; do ...; done < <(aerospace_workspaces_to_add "$all_windows" "$bar_items")
aerospace_workspaces_to_add() {
  local all_windows="$1"
  local bar_items="$2"

  local aerospace_ws=$(aerospace_get_workspaces "$all_windows")
  local sketchy_ws=$(echo "$bar_items" | grep "^workspace\\.start\\.[0-9]*$" | sed 's/workspace\.start\.//')

  # Use jq to compute set difference: aerospace - sketchy
  jq -rn --arg aero "$aerospace_ws" --arg sketchy "$sketchy_ws" '
    ($aero | split("\n") | map(select(. != ""))) as $a |
    ($sketchy | split("\n") | map(select(. != ""))) as $s |
    ($a - $s) | sort_by(tonumber) | .[]
  '
}

# Get workspaces to remove (in sketchybar but not in aerospace)
# Usage: while read -r sid; do ...; done < <(aerospace_workspaces_to_remove "$all_windows" "$bar_items")
aerospace_workspaces_to_remove() {
  local all_windows="$1"
  local bar_items="$2"

  local aerospace_ws=$(aerospace_get_workspaces "$all_windows")
  local sketchy_ws=$(echo "$bar_items" | grep "^workspace\\.start\\.[0-9]*$" | sed 's/workspace\.start\.//')

  # Use jq to compute set difference: sketchy - aerospace
  jq -rn --arg aero "$aerospace_ws" --arg sketchy "$sketchy_ws" '
    ($aero | split("\n") | map(select(. != ""))) as $a |
    ($sketchy | split("\n") | map(select(. != ""))) as $s |
    ($s - $a) | sort_by(tonumber) | .[]
  '
}

# Find the next higher workspace that exists in sketchybar (for positioning)
# Usage: next=$(aerospace_next_existing_workspace "$sid" "$all_windows" "$bar_items")
aerospace_next_existing_workspace() {
  local sid="$1"
  local all_windows="$2"
  local bar_items="$3"

  local aerospace_ws=$(aerospace_get_workspaces "$all_windows")
  local sketchy_ws=$(echo "$bar_items" | grep "^workspace\\.start\\.[0-9]*$" | sed 's/workspace\.start\.//')

  jq -rn --arg sid "$sid" --arg aero "$aerospace_ws" --arg sketchy "$sketchy_ws" '
    ($aero | split("\n") | map(select(. != "")) | sort_by(tonumber)) as $a |
    ($sketchy | split("\n") | map(select(. != ""))) as $s |
    [$a[] | select((. | tonumber) > ($sid | tonumber)) | select(. as $w | $s | index($w))] |
    first // ""
  '
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
  # Return empty if window_id is empty (prevents jq tonumber error)
  [[ -z "$window_id" ]] && return
  echo "$json" | jq -r --arg wid "$window_id" '.[] | select(."window-id" == ($wid | tonumber)) | ."app-name"'
}

# Get window title by window ID from all_windows JSON
# Usage: window_title=$(aerospace_get_window_title_by_windowid "$all_windows" "$window_id")
aerospace_get_window_title_by_windowid() {
  local json="$1"
  local window_id="$2"
  # Return empty if window_id is empty (prevents jq tonumber error)
  [[ -z "$window_id" ]] && return
  echo "$json" | jq -r --arg wid "$window_id" '.[] | select(."window-id" == ($wid | tonumber)) | ."window-title"'
}

# Check if a window should be excluded from display
# Usage: if should_exclude_window "$appname" "$window_title"; then skip; fi
# Returns 0 (true) if window should be excluded, 1 (false) otherwise
should_exclude_window() {
  local appname="$1"
  local window_title="$2"

  # Exclude Outlook Reminder windows
  if [[ "$appname" == "Microsoft Outlook" ]] && [[ "$window_title" =~ [0-9]+[[:space:]]*Reminder ]]; then
    return 0  # Should exclude
  fi

  return 1  # Should not exclude
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


remove_unmatched_items() {
  local sid="$1"
  local all_windows=$(aerospace_ensure_all_windows "$2")

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
  local all_windows=$(aerospace_ensure_all_windows "$3")

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
  local all_windows=$(aerospace_ensure_all_windows "$2")

  local sid=$(aerospace_get_focused_workspace "$all_windows")

  if [[ -z "$window_id" ]]; then
    window_id=$(aerospace_get_focused_window_id)
  fi

  sketchy_highlight_workspace "$sid"
  sketchy_highlight_window_id "$window_id"
}

# Sync workspaces: add workspace dividers for new workspaces, remove for empty ones
sync_workspaces() {
  local all_windows=$(aerospace_ensure_all_windows "$1")

  local bar_items=$(_sketchy_cached_bar_items)

  # Add missing workspaces (in aerospace but not in sketchybar)
  while IFS= read -r sid; do
    [[ -z "$sid" ]] && continue

    local start="workspace.start.$sid"
    local end="workspace.end.$sid"

    # Use centralized props from env.sh
    local props=()
    props_to_array get_workspace_divider_props props

    # Find the correct position to insert this workspace
    local next_sid=$(aerospace_next_existing_workspace "$sid" "$all_windows" "$bar_items")

    if [[ -n "$next_sid" ]]; then
      # Insert before this workspace
      sketchy_add_item "$start" left \
        --set "$start" "${props[@]}"
      sketchybar --move "$start" before "workspace.start.$next_sid"

      sketchy_add_item "$end" left \
        --set "$end" "${props[@]}"
      sketchybar --move "$end" after "$start"
    else
      # No higher workspace found, just add to left (will be at the end)
      sketchy_add_item "$start" left \
        --set "$start" "${props[@]}"

      sketchy_add_item "$end" left \
        --set "$end" "${props[@]}"
    fi

    sketchy_add_workspace "$sid"

    # Move any existing window items for this workspace to correct position
    local existing_windows=$(echo "$bar_items" | grep "^window\\.${sid}\\.")
    if [[ -n "$existing_windows" ]]; then
      while IFS= read -r item; do
        sketchybar --move "$item" before "workspace.end.$sid"
      done <<< "$existing_windows"
    fi

    # Populate the workspace with any missing apps
    aerospace_add_apps_in_spaceid "$sid" "$all_windows"
  done < <(aerospace_workspaces_to_add "$all_windows" "$bar_items")

  # Remove workspaces that don't exist in AeroSpace
  while IFS= read -r sid; do
    [[ -z "$sid" ]] && continue

    # Remove all window items in this workspace first
    local window_items=$(echo "$bar_items" | grep "^window\\.${sid}\\.")
    if [[ -n "$window_items" ]]; then
      while IFS= read -r item; do
        sketchy_remove_item "$item"
      done <<< "$window_items"
    fi

    # Then remove workspace dividers and bracket
    sketchy_remove_item "workspace.start.$sid"
    sketchy_remove_item "workspace.end.$sid"
    sketchy_remove_item "workspace.$sid"
  done < <(aerospace_workspaces_to_remove "$all_windows" "$bar_items")
}


aerospace_remove_window_id() {
  # ex: 46356
  local window_id="$1"
  # item ex:window.3.66286.WezTerm
  local item=$(sketchy_get_item_by_window_id "$window_id")
  sketchy_remove_item "$item"
}


aerospace_new_window_id() {
  local window_id="$1"
  local all_windows=$(aerospace_ensure_all_windows "$2")

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

  # Skip excluded windows by title (e.g., Outlook Reminders)
  local window_title=$(aerospace_get_window_title_by_windowid "$all_windows" "$window_id")
  if should_exclude_window "$appname" "$window_title"; then
    return
  fi

  local item="window.$sid.$window_id.$appname"
  local icon_color="$(sketchy_get_space_color foreground false)"

  # Get aerospace's window ordering for this workspace from all_windows JSON
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

  # Determine position reference for item creation
  local move_ref move_pos
  if [[ $position -eq 0 ]]; then
    move_ref="workspace.start.$sid"
    move_pos="--move-after"
  else
    local prev_index=$((position - 1))
    local prev_window_id="${aerospace_window_order[$prev_index]}"
    local prev_item=$(sketchy_get_item_by_window_id "$prev_window_id")

    if [[ -n "$prev_item" ]]; then
      move_ref="$prev_item"
      move_pos="--move-after"
    else
      move_ref="workspace.end.$sid"
      move_pos="--move-before"
    fi
  fi

  # Create the item with position
  aerospace_create_window_item "$item" "$window_id" "$appname" "$icon_color" $move_pos "$move_ref"

  sketchy_highlight_window_id "$window_id"

  # Sync workspaces after adding window
  sync_workspaces "$all_windows"
}

aerospace_add_apps_in_spaceid() {
  local sid="$1"
  local all_windows=$(aerospace_ensure_all_windows "$2")

  # Use centralized props from env.sh, with y_offset override
  local props=()
  props_to_array get_window_item_props props
  props+=("y_offset=1")

  local prev_item="workspace.start.$sid"

  # Cache bar items once for this function (avoid querying inside loop)
  local bar_items=$(_sketchy_cached_bar_items)

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

    # Skip excluded windows by title (e.g., Outlook Reminders)
    local window_title=$(aerospace_get_window_title_by_windowid "$all_windows" "$window_id")
    if should_exclude_window "$appname" "$window_title"; then
      continue
    fi

    local item="window.$sid.$window_id.$appname"
    local icon="$($CONFIG_DIR/helpers/icons/icons_apps.sh "$appname")"

    # Check if item already exists (using cached bar items)
    if ! item_in_array "$item" "$bar_items"; then
      # New item - set all properties including icon.color
      local icon_color="$(sketchy_get_space_color foreground false)"
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
  local workspaces_json=$(aerospace_list_workspaces_json)

  # Get the last (highest) occupied workspace using jq
  local last_workspace=$(echo "$workspaces_json" | jq -r '
    [.[].workspace] | map(select(. != "")) | sort_by(tonumber) | last // empty
  ')

  if [[ -z "$last_workspace" ]]; then
    aerospace workspace 1
    return 0
  fi

  local next_workspace=$((last_workspace + 1))

  # Cap at 9 (max workspace in aerospace config)
  if [[ $next_workspace -le 9 ]]; then
    aerospace workspace "$next_workspace"
  else
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

  # Fetch all data as JSON once
  local all_windows=$(aerospace_all_windows)
  local workspaces_json=$(aerospace_list_workspaces_json)

  # Build workspace_ids array from JSON
  local workspace_ids=()
  while IFS= read -r ws; do
    [[ -n "$ws" ]] && workspace_ids+=("$ws")
  done < <(aerospace_get_workspace_ids_sorted "$workspaces_json")

  # Build current state: workspace_id -> "window_id1 window_id2 ..."
  declare -A current_state
  for sid in "${workspace_ids[@]}"; do
    current_state[$sid]=$(aerospace_get_windows_in_workspace "$all_windows" "$sid" | tr '\n' ' ' | sed 's/ $//')
  done

  # Find current workspace index using jq
  local current_index=$(echo "$workspaces_json" | jq -r --arg sid "$current_sid" '
    [.[].workspace] | map(select(. != "")) | sort_by(tonumber) |
    to_entries | map(select(.value == $sid)) | .[0].key // -1
  ')

  if [[ "$current_index" -eq -1 ]]; then
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

  # Get all current window items from cache
  local bar_items=$(_sketchy_cached_bar_items)
  local all_window_items=()
  sketchy_get_window_items_array all_window_items "$bar_items"

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
    local item_sid item_window_id item_appname
    parse_window_item "$item" item_sid item_window_id item_appname

    # Get correct workspace from aerospace
    local correct_sid="${window_workspace_map[$item_window_id]}"

    if [[ -z "$correct_sid" ]]; then
      # Window no longer exists in aerospace, remove from sketchybar
      sketchy_remove_item "$item"
    elif [[ "$item_sid" != "$correct_sid" ]]; then
      # Item has wrong workspace ID, recreate it
      local item_color=$(sketchy_get_space_color foreground false)

      # Remove old item
      sketchy_remove_item "$item"

      # Create new item with correct workspace ID
      local correct_item="window.$correct_sid.$item_window_id.$item_appname"
      aerospace_create_window_item "$correct_item" "$item_window_id" "$item_appname" "$item_color" \
        --move-before "workspace.end.$correct_sid"
    fi
  done

  # Sync workspaces to create dividers and background bracket for new workspaces
  sync_workspaces

  # Highlight the focused workspace and window after sync
  sketchy_highlight_workspace "$new_focused_sid"
  sketchy_highlight_window_id "$new_focused_window_id"
}

aerospace_workspace_next() {
  local current_sid=$(aerospace list-workspaces --focused)
  local workspaces_json=$(aerospace_list_workspaces_json)

  local next_sid=$(aerospace_adjacent_workspace "$workspaces_json" "$current_sid" "next")

  if [[ -z "$next_sid" ]]; then
    # At the end, create new workspace
    aerospace_create_new_workspace
  else
    aerospace workspace "$next_sid"
  fi
}

# Swap focused workspace with adjacent workspace (left or right)
# This swaps all windows between the two workspaces and updates sketchybar
aerospace_swap_workspace() {
  local direction="$1"  # "left" or "right"

  # Fetch all window data once
  local all_windows=$(aerospace_all_windows)

  # Get current workspace and focused window
  local current_sid=$(aerospace_get_focused_workspace "$all_windows")
  local focused_window_id=$(aerospace_get_focused_window_id)

  # Map direction to adjacent_workspace direction ("left" -> "prev", "right" -> "next")
  local adj_direction="next"
  [[ "$direction" == "left" ]] && adj_direction="prev"

  # Get workspaces as JSON for the helper
  local workspaces_json=$(echo "$all_windows" | jq '[{workspace: .[].workspace}] | unique')
  local target_sid=$(aerospace_adjacent_workspace "$workspaces_json" "$current_sid" "$adj_direction")

  # No workspace to swap with in that direction
  if [[ -z "$target_sid" ]]; then
    return 0
  fi

  # Get windows in each workspace using cached all_windows
  local current_windows=()
  while IFS= read -r wid; do
    [[ -n "$wid" ]] && current_windows+=("$wid")
  done < <(aerospace_get_windows_in_workspace "$all_windows" "$current_sid")

  local target_windows=()
  while IFS= read -r wid; do
    [[ -n "$wid" ]] && target_windows+=("$wid")
  done < <(aerospace_get_windows_in_workspace "$all_windows" "$target_sid")

  # Use cached bar state
  local bar_items=$(_sketchy_cached_bar_items)

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

  # Get all window items
  local all_window_items=()
  sketchy_get_window_items_array all_window_items "$bar_items"

  # Collect items to remove and items to add
  declare -A items_to_update  # old_item -> new_item

  for item in "${all_window_items[@]}"; do
    local item_sid item_window_id item_appname
    parse_window_item "$item" item_sid item_window_id item_appname

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

  local icon_color=$(sketchy_get_space_color foreground false)
  local focused_color=$(sketchy_get_space_color foreground true)

  for old_item in "${!items_to_update[@]}"; do
    IFS=':' read -r correct_item item_window_id item_appname new_sid <<< "${items_to_update[$old_item]}"
    local icon="$($CONFIG_DIR/helpers/icons/icons_apps.sh "$item_appname" 2>/dev/null || echo "")"

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
  local unfocused_bg=$(sketchy_get_space_color background false)
  local focused_bg=$(sketchy_get_space_color background true)

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
