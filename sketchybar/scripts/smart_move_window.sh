#!/usr/bin/env bash

# Smart window movement with three scenarios:
# 1. Same number of spaces: move focused window in arrow direction
# 2. Fewer spaces: pull other windows opposite to arrow direction
# 3. More spaces: create new space and move focused window in arrow direction

direction="$1"  # "next" or "prev"

# Log for debugging
log_file="/tmp/smart_move_window.log"
echo "=== $(date) ===" >> "$log_file"
echo "Direction: $direction" >> "$log_file"

if [[ "$direction" == "next" ]]; then
  # Get current workspace and focused window
  current=$(aerospace list-workspaces --focused)
  echo "Current workspace: $current" >> "$log_file"

  focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')
  echo "Focused window ID: $focused_window_id" >> "$log_file"

  # Get all occupied workspaces before the operation
  mapfile -t occupied_before < <(aerospace list-workspaces --all | sort -n)
  echo "Occupied workspaces before: ${occupied_before[*]}" >> "$log_file"
  workspace_count_before=${#occupied_before[@]}

  # Check if we're on the last workspace
  last_workspace="${occupied_before[-1]}"
  echo "Last workspace: $last_workspace" >> "$log_file"

  if [[ "$current" == "$last_workspace" ]]; then
    # On last workspace - check window count
    window_count=$(aerospace list-windows --workspace "$current" --format '%{window-id}' | wc -l | tr -d ' ')
    echo "Window count in workspace $current: $window_count" >> "$log_file"

    if [[ $window_count -gt 1 ]]; then
      # Multiple windows - Scenario 3: Create new space and move focused window
      echo "Scenario 3: Creating new workspace and moving focused window" >> "$log_file"

      # Find next available workspace number
      next_workspace=$((last_workspace + 1))
      if [[ $next_workspace -le 9 ]]; then
        echo "Creating workspace $next_workspace and moving window $focused_window_id" >> "$log_file"
        aerospace move-node-to-workspace "$next_workspace" </dev/null 2>> "$log_file"
        aerospace workspace "$next_workspace" </dev/null 2>> "$log_file"

        echo "Ensuring contiguous workspaces" >> "$log_file"
        "$HOME/Software/Public/dotfiles/sketchybar/scripts/ensure_contiguous_workspaces.sh" 2>> "$log_file"
      else
        echo "Already at max workspace 9" >> "$log_file"
      fi
    else
      echo "Only one window, no action" >> "$log_file"
    fi
  else
    # Not on last workspace - check if next workspace exists
    next_workspace=""
    for i in "${!occupied_before[@]}"; do
      if [[ "${occupied_before[$i]}" == "$current" ]] && [[ $((i + 1)) -lt ${#occupied_before[@]} ]]; then
        next_workspace="${occupied_before[$((i + 1))]}"
        break
      fi
    done

    if [[ -n "$next_workspace" ]]; then
      # Check if current workspace will become empty after moving focused window
      window_count_current=$(aerospace list-windows --workspace "$current" --format '%{window-id}' | wc -l | tr -d ' ')
      echo "Window count in current workspace $current: $window_count_current" >> "$log_file"

      if [[ $window_count_current -eq 1 ]]; then
        # Scenario 2: Only one window in current workspace - pull windows from next instead
        echo "Scenario 2: Only window in workspace, pulling windows from $next_workspace instead" >> "$log_file"

        # Pull all windows from next workspace to current
        mapfile -t windows_to_move < <(aerospace list-windows --workspace "$next_workspace" --format '%{window-id}')
        echo "Windows to pull: ${windows_to_move[*]}" >> "$log_file"

        for window_id in "${windows_to_move[@]}"; do
          if [[ -n "$window_id" ]]; then
            echo "  Moving window $window_id to workspace $current" >> "$log_file"
            aerospace move-node-to-workspace "$current" --window-id "$window_id" </dev/null 2>> "$log_file"
          fi
        done
      else
        # Scenario 1: Multiple windows in current workspace - move focused window
        echo "Scenario 1: Multiple windows in workspace, moving focused window to $next_workspace" >> "$log_file"
        aerospace move-node-to-workspace "$next_workspace" --window-id "$focused_window_id" </dev/null 2>> "$log_file"
      fi

      echo "Ensuring contiguous workspaces" >> "$log_file"
      "$HOME/Software/Public/dotfiles/sketchybar/scripts/ensure_contiguous_workspaces.sh" 2>> "$log_file"

      echo "Restoring focus to window $focused_window_id" >> "$log_file"
      aerospace focus --window-id "$focused_window_id" </dev/null 2>> "$log_file"
    else
      echo "No next workspace found" >> "$log_file"
    fi
  fi

elif [[ "$direction" == "prev" ]]; then
  # Get current workspace and focused window
  current=$(aerospace list-workspaces --focused)
  echo "Current workspace: $current" >> "$log_file"

  focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')
  echo "Focused window ID: $focused_window_id" >> "$log_file"

  # Get all occupied workspaces before the operation
  mapfile -t occupied_before < <(aerospace list-workspaces --all | sort -n)
  echo "Occupied workspaces before: ${occupied_before[*]}" >> "$log_file"
  workspace_count_before=${#occupied_before[@]}

  # Check if we're on the first workspace
  first_workspace="${occupied_before[0]}"
  echo "First workspace: $first_workspace" >> "$log_file"

  if [[ "$current" == "$first_workspace" ]]; then
    # On first workspace - check window count
    window_count=$(aerospace list-windows --workspace "$current" --format '%{window-id}' | wc -l | tr -d ' ')
    echo "Window count in workspace $current: $window_count" >> "$log_file"

    if [[ $window_count -gt 1 ]]; then
      # Multiple windows - Scenario 3: Create new space and move focused window
      echo "Scenario 3: Creating new workspace to the left and moving focused window" >> "$log_file"

      # Use workspace 0 temporarily
      echo "Moving window $focused_window_id to workspace 0" >> "$log_file"
      aerospace move-node-to-workspace 0 --window-id "$focused_window_id" </dev/null 2>> "$log_file"

      # Renumber (0 becomes 1, others shift right)
      echo "Ensuring contiguous workspaces" >> "$log_file"
      "$HOME/Software/Public/dotfiles/sketchybar/scripts/ensure_contiguous_workspaces.sh" 2>> "$log_file"

      echo "Restoring focus to window $focused_window_id" >> "$log_file"
      aerospace focus --window-id "$focused_window_id" </dev/null 2>> "$log_file"
    else
      echo "Only one window, no action" >> "$log_file"
    fi
  else
    # Not on first workspace - check if prev workspace exists
    prev_workspace=""
    for i in "${!occupied_before[@]}"; do
      if [[ "${occupied_before[$i]}" == "$current" ]] && [[ $i -gt 0 ]]; then
        prev_workspace="${occupied_before[$((i - 1))]}"
        break
      fi
    done

    if [[ -n "$prev_workspace" ]]; then
      # Check if current workspace will become empty after moving focused window
      window_count_current=$(aerospace list-windows --workspace "$current" --format '%{window-id}' | wc -l | tr -d ' ')
      echo "Window count in current workspace $current: $window_count_current" >> "$log_file"

      if [[ $window_count_current -eq 1 ]]; then
        # Scenario 2: Only one window in current workspace - pull windows from prev instead
        echo "Scenario 2: Only window in workspace, pulling windows from $prev_workspace instead" >> "$log_file"

        # Pull all windows from prev workspace to current
        mapfile -t windows_to_move < <(aerospace list-windows --workspace "$prev_workspace" --format '%{window-id}')
        echo "Windows to pull: ${windows_to_move[*]}" >> "$log_file"

        for window_id in "${windows_to_move[@]}"; do
          if [[ -n "$window_id" ]]; then
            echo "  Moving window $window_id to workspace $current" >> "$log_file"
            aerospace move-node-to-workspace "$current" --window-id "$window_id" </dev/null 2>> "$log_file"
          fi
        done
      else
        # Scenario 1: Multiple windows in current workspace - move focused window
        echo "Scenario 1: Multiple windows in workspace, moving focused window to $prev_workspace" >> "$log_file"
        aerospace move-node-to-workspace "$prev_workspace" --window-id "$focused_window_id" </dev/null 2>> "$log_file"
      fi

      echo "Ensuring contiguous workspaces" >> "$log_file"
      "$HOME/Software/Public/dotfiles/sketchybar/scripts/ensure_contiguous_workspaces.sh" 2>> "$log_file"

      echo "Restoring focus to window $focused_window_id" >> "$log_file"
      aerospace focus --window-id "$focused_window_id" </dev/null 2>> "$log_file"
    else
      echo "No prev workspace found" >> "$log_file"
    fi
  fi
fi

echo "Done" >> "$log_file"
