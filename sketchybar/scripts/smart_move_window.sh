#!/usr/bin/env bash

# Smart window movement that maintains contiguous workspace numbering
# - Multiple windows in current workspace: move focused window in direction
# - Single window in current workspace: ripple-pull all windows from direction
# - Edge case (single window at boundary): create new workspace

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
      else
        echo "Cannot create workspace > 9" >> "$log_file"
      fi
    else
      # Moving left from first workspace - use temporary workspace 0
      echo "Moving to workspace 0 (will become 1 after renumber)" >> "$log_file"
      aerospace move-node-to-workspace 0 --window-id "$focused_window_id" </dev/null 2>> "$log_file"

      # Renumber: 0→1, 1→2, 2→3, etc.
      renumber_workspaces

      # Focus the new workspace 1
      aerospace workspace 1 </dev/null 2>> "$log_file"
    fi
  else
    # Not at edge: move to existing adjacent workspace
    target_workspace="${workspaces[$target_index]}"
    echo "Moving to existing workspace $target_workspace" >> "$log_file"
    aerospace move-node-to-workspace "$target_workspace" --window-id "$focused_window_id" </dev/null 2>> "$log_file"
    aerospace focus --window-id "$focused_window_id" </dev/null 2>> "$log_file"
  fi

else
  # Single window: ripple-pull windows from direction
  echo "Single window - ripple pulling from direction" >> "$log_file"

  if [[ $is_at_edge -eq 1 ]]; then
    # At edge with single window: no action
    echo "At edge with single window - no action" >> "$log_file"
  else
    # Ripple-pull all windows from target direction into current workspace
    echo "Ripple pulling from index $target_index onwards" >> "$log_file"

    if [[ "$direction" == "next" ]]; then
      # Pull from right: iterate from target_index to end
      for ((i = target_index; i < ${#workspaces[@]}; i++)); do
        source_workspace="${workspaces[$i]}"
        echo "Pulling all windows from workspace $source_workspace to $current" >> "$log_file"

        mapfile -t windows_to_move < <(aerospace list-windows --workspace "$source_workspace" --format '%{window-id}')
        for window_id in "${windows_to_move[@]}"; do
          if [[ -n "$window_id" ]]; then
            echo "  Moving window $window_id" >> "$log_file"
            aerospace move-node-to-workspace "$current" --window-id "$window_id" </dev/null 2>> "$log_file"
          fi
        done
      done
    else
      # Pull from left: iterate from target_index down to 0
      for ((i = target_index; i >= 0; i--)); do
        source_workspace="${workspaces[$i]}"
        echo "Pulling all windows from workspace $source_workspace to $current" >> "$log_file"

        mapfile -t windows_to_move < <(aerospace list-windows --workspace "$source_workspace" --format '%{window-id}')
        for window_id in "${windows_to_move[@]}"; do
          if [[ -n "$window_id" ]]; then
            echo "  Moving window $window_id" >> "$log_file"
            aerospace move-node-to-workspace "$current" --window-id "$window_id" </dev/null 2>> "$log_file"
          fi
        done
      done
    fi

    # After ripple-pull, renumber to close gaps
    renumber_workspaces
  fi
fi

echo "Done" >> "$log_file"

# === HELPER FUNCTIONS ===

renumber_workspaces() {
  echo "Renumbering workspaces to ensure contiguity" >> "$log_file"

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

  # Renumber from low to high
  new_number=1
  for sid in "${occupied[@]}"; do
    if [[ $sid -ne $new_number ]]; then
      echo "Renumbering workspace $sid -> $new_number" >> "$log_file"

      mapfile -t window_ids < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
      for window_id in "${window_ids[@]}"; do
        if [[ -n "$window_id" ]]; then
          aerospace move-node-to-workspace "$new_number" --window-id "$window_id" </dev/null 2>> "$log_file"
        fi
      done
    fi
    new_number=$((new_number + 1))
  done

  echo "Renumbering complete" >> "$log_file"
}
