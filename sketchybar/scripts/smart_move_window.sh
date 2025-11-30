#!/usr/bin/env bash

# Smart window movement that maintains contiguous workspace numbering
# - Multiple windows in current workspace: move focused window in direction
# - Single window in current workspace: ripple-pull all windows from direction
# - Edge case (single window at boundary): no action

# Source helpers for sketchybar management
source "$HOME/Software/Public/dotfiles/sketchybar/plugins/helpers/sketchy.sh"
source "$HOME/Software/Public/dotfiles/sketchybar/env.sh"

direction="$1"  # "next" or "prev"

# Log for debugging
log_file="/tmp/smart_move_window.log"
echo "=== $(date) ===" >> "$log_file"
echo "Direction: $direction" >> "$log_file"

# Get current state
current=$(aerospace list-workspaces --focused)
focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')
mapfile -t workspaces < <(aerospace list-workspaces --all | sort -n)

echo "Current workspace: $current" >> "$log_file"
echo "Focused window: $focused_window_id" >> "$log_file"
echo "All workspaces: ${workspaces[*]}" >> "$log_file"

# Find current workspace index
current_index=-1
for i in "${!workspaces[@]}"; do
  if [[ "${workspaces[$i]}" == "$current" ]]; then
    current_index=$i
    break
  fi
done

if [[ $current_index -eq -1 ]]; then
  echo "ERROR: Could not find current workspace in list" >> "$log_file"
  exit 1
fi

# Count windows in current workspace
window_count=$(aerospace list-windows --workspace "$current" --format '%{window-id}' | wc -l | tr -d ' ')
echo "Window count in current workspace: $window_count" >> "$log_file"

# Determine target index based on direction
if [[ "$direction" == "next" ]]; then
  target_index=$((current_index + 1))
  is_at_edge=$((current_index == ${#workspaces[@]} - 1))
elif [[ "$direction" == "prev" ]]; then
  target_index=$((current_index - 1))
  is_at_edge=$((current_index == 0))
else
  echo "ERROR: Invalid direction '$direction'" >> "$log_file"
  exit 1
fi

echo "Current index: $current_index, Target index: $target_index, At edge: $is_at_edge" >> "$log_file"

# === MAIN LOGIC ===

if [[ $window_count -gt 1 ]]; then
  # Multiple windows: move focused window in direction
  echo "Multiple windows - moving focused window" >> "$log_file"

  if [[ $is_at_edge -eq 1 ]]; then
    # At edge: create new workspace
    echo "At edge - creating new workspace" >> "$log_file"

    if [[ "$direction" == "next" ]]; then
      # Moving right from last workspace
      new_workspace=$((${workspaces[-1]} + 1))
      if [[ $new_workspace -le 9 ]]; then
        echo "Creating workspace $new_workspace" >> "$log_file"
        aerospace move-node-to-workspace "$new_workspace" --window-id "$focused_window_id" </dev/null 2>> "$log_file"
        aerospace workspace "$new_workspace" </dev/null 2>> "$log_file"
        # Sketchybar will add the new workspace via yabai signals
      else
        echo "Cannot create workspace > 9" >> "$log_file"
      fi
    else
      # Moving left from first workspace - use temporary workspace 0
      echo "Moving to workspace 0 (will become 1 after renumber)" >> "$log_file"
      aerospace move-node-to-workspace 0 --window-id "$focused_window_id" </dev/null 2>> "$log_file"

      # Renumber: 0→1, 1→2, 2→3, etc.
      renumber_workspaces_and_sketchybar

      # Focus the new workspace 1
      aerospace workspace 1 </dev/null 2>> "$log_file"
    fi
  else
    # Not at edge: move to existing adjacent workspace
    target_workspace="${workspaces[$target_index]}"
    echo "Moving to existing workspace $target_workspace" >> "$log_file"
    aerospace move-node-to-workspace "$target_workspace" --window-id "$focused_window_id" </dev/null 2>> "$log_file"
    aerospace focus --window-id "$focused_window_id" </dev/null 2>> "$log_file"
    # Sketchybar window items move via yabai signals
  fi

else
  # Single window: ripple-pull windows from direction
  echo "Single window - ripple pulling from direction" >> "$log_file"

  if [[ $is_at_edge -eq 1 ]]; then
    # At edge with single window: no action
    echo "At edge with single window - no action" >> "$log_file"
  else
    # Ripple: shift each workspace in the direction one space over
    echo "Ripple: shifting workspaces in direction" >> "$log_file"

    if [[ "$direction" == "next" ]]; then
      # Ripple right: Move windows from workspaces to the RIGHT, one space LEFT
      # Start from the rightmost and work backwards to avoid conflicts
      # Example: s1w1 s2wf s3w2 s4w3 -> s1w1,w2 s2wf s3w3
      echo "Ripple right: shifting workspaces from right to left" >> "$log_file"

      for ((i = ${#workspaces[@]} - 1; i >= target_index; i--)); do
        source_workspace="${workspaces[$i]}"
        dest_workspace="${workspaces[$((i - 1))]}"
        echo "Moving all windows from workspace $source_workspace -> $dest_workspace" >> "$log_file"

        mapfile -t windows_to_move < <(aerospace list-windows --workspace "$source_workspace" --format '%{window-id}')
        for window_id in "${windows_to_move[@]}"; do
          if [[ -n "$window_id" ]]; then
            echo "  Moving window $window_id" >> "$log_file"
            aerospace move-node-to-workspace "$dest_workspace" --window-id "$window_id" </dev/null 2>> "$log_file"
          fi
        done

        # Remove the now-empty workspace from sketchybar
        remove_sketchybar_workspace "$source_workspace"
      done
    else
      # Ripple left: Move windows from workspaces to the LEFT, one space RIGHT
      # Start from the leftmost and work forwards to avoid conflicts
      # Example: s1w1 s2w2 s3wf s4w3 -> s1 s2w2,w1 s3wf s4w3
      echo "Ripple left: shifting workspaces from left to right" >> "$log_file"

      for ((i = 0; i <= target_index; i++)); do
        source_workspace="${workspaces[$i]}"
        dest_workspace="${workspaces[$((i + 1))]}"
        echo "Moving all windows from workspace $source_workspace -> $dest_workspace" >> "$log_file"

        mapfile -t windows_to_move < <(aerospace list-windows --workspace "$source_workspace" --format '%{window-id}')
        for window_id in "${windows_to_move[@]}"; do
          if [[ -n "$window_id" ]]; then
            echo "  Moving window $window_id" >> "$log_file"
            aerospace move-node-to-workspace "$dest_workspace" --window-id "$window_id" </dev/null 2>> "$log_file"
          fi
        done

        # Remove the now-empty workspace from sketchybar
        remove_sketchybar_workspace "$source_workspace"
      done
    fi

    # After ripple, renumber aerospace and sketchybar to close gaps
    renumber_workspaces_and_sketchybar
  fi
fi

echo "Done" >> "$log_file"

# === HELPER FUNCTIONS ===

remove_sketchybar_workspace() {
  local sid="$1"
  echo "Removing sketchybar workspace $sid" >> "$log_file"

  # Remove all window items in this workspace
  local window_items=($(sketchybar --query bar | jq -r --arg sid "$sid" '.items[] | select(test("^window\\." + $sid + "\\."))'))
  for item in "${window_items[@]}"; do
    echo "  Removing window item: $item" >> "$log_file"
    sketchy_remove_item "$item"
  done

  # Remove workspace dividers and bracket
  sketchy_remove_item "workspace.start.$sid"
  sketchy_remove_item "workspace.end.$sid"
  sketchy_remove_item "workspace.$sid"
}

renumber_workspaces_and_sketchybar() {
  echo "Renumbering workspaces and sketchybar to ensure contiguity" >> "$log_file"

  # Get all workspaces sorted
  mapfile -t occupied < <(aerospace list-workspaces --all | sort -n)
  echo "Workspaces before renumber: ${occupied[*]}" >> "$log_file"

  # Check if already contiguous
  is_contiguous=true
  expected=1
  for sid in "${occupied[@]}"; do
    if [[ $sid -ne $expected ]]; then
      is_contiguous=false
      break
    fi
    expected=$((expected + 1))
  done

  if [[ "$is_contiguous" == "true" ]]; then
    echo "Already contiguous" >> "$log_file"
    return
  fi

  # Build renumbering map: old_sid -> new_sid
  declare -A renumber_map
  new_number=1
  for sid in "${occupied[@]}"; do
    renumber_map[$sid]=$new_number
    echo "Renumber map: $sid -> $new_number" >> "$log_file"
    new_number=$((new_number + 1))
  done

  # Renumber aerospace workspaces from low to high
  for sid in "${occupied[@]}"; do
    if [[ $sid -ne ${renumber_map[$sid]} ]]; then
      echo "Renumbering aerospace workspace $sid -> ${renumber_map[$sid]}" >> "$log_file"

      mapfile -t window_ids < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
      for window_id in "${window_ids[@]}"; do
        if [[ -n "$window_id" ]]; then
          aerospace move-node-to-workspace "${renumber_map[$sid]}" --window-id "$window_id" </dev/null 2>> "$log_file"
        fi
      done
    fi
  done

  # Renumber sketchybar items
  echo "Renumbering sketchybar items" >> "$log_file"
  for old_sid in "${occupied[@]}"; do
    new_sid="${renumber_map[$old_sid]}"

    if [[ $old_sid -ne $new_sid ]]; then
      echo "Renumbering sketchybar workspace $old_sid -> $new_sid" >> "$log_file"

      # Rename workspace dividers and bracket
      rename_sketchybar_item "workspace.start.$old_sid" "workspace.start.$new_sid"
      rename_sketchybar_item "workspace.end.$old_sid" "workspace.end.$new_sid"
      rename_sketchybar_item "workspace.$old_sid" "workspace.$new_sid"

      # Rename all window items in this workspace
      local window_items=($(sketchybar --query bar | jq -r --arg sid "$old_sid" '.items[] | select(test("^window\\." + $sid + "\\."))'))
      for old_item in "${window_items[@]}"; do
        # Extract window_id and appname from old item: window.OLD_SID.WINDOW_ID.APPNAME
        local window_id=$(echo "$old_item" | awk -F'.' '{print $3}')
        local appname=$(echo "$old_item" | cut -d'.' -f4-)
        local new_item="window.$new_sid.$window_id.$appname"
        echo "  Renaming window item: $old_item -> $new_item" >> "$log_file"
        rename_sketchybar_item "$old_item" "$new_item"
      done
    fi
  done

  echo "Renumbering complete" >> "$log_file"
}

rename_sketchybar_item() {
  local old_name="$1"
  local new_name="$2"

  # Sketchybar doesn't have a rename command, so we need to:
  # 1. Clone the item (copy all properties)
  # 2. Remove the old item
  # This is complex, so for now we'll just use --rename if available,
  # or reconstruct via remove/add

  # Simple approach: use sketchybar --rename (if supported)
  sketchybar --rename "$old_name" "$new_name" 2>> "$log_file"
}
