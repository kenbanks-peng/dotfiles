#!/usr/bin/env bash

# Smart window movement: if on last occupied workspace, create new one to the right
# Otherwise, use default aerospace behavior

direction="$1"  # "next" or "prev"

# Log for debugging
log_file="/tmp/smart_move_window.log"
echo "=== $(date) ===" >> "$log_file"
echo "Direction: $direction" >> "$log_file"

if [[ "$direction" == "next" ]]; then
  # First, ensure workspaces are contiguous before we do anything
  echo "Ensuring contiguous workspaces before move" >> "$log_file"
  "$HOME/Software/Public/dotfiles/sketchybar/scripts/ensure_contiguous_workspaces.sh" 2>> "$log_file"

  # Get current workspace (may have changed after renumbering)
  current=$(aerospace list-workspaces --focused)
  echo "Current workspace: $current" >> "$log_file"

  # Get all occupied workspaces sorted numerically
  mapfile -t occupied < <(aerospace list-workspaces --all | sort -n)
  echo "Occupied workspaces: ${occupied[*]}" >> "$log_file"

  # Check if we're on the last occupied workspace
  last_workspace="${occupied[-1]}"
  echo "Last workspace: $last_workspace" >> "$log_file"

  if [[ "$current" == "$last_workspace" ]]; then
    echo "On last workspace" >> "$log_file"

    # Check how many windows are in the current workspace
    window_count=$(aerospace list-windows --workspace "$current" --format '%{window-id}' | wc -l | tr -d ' ')
    echo "Window count in workspace $current: $window_count" >> "$log_file"

    # Only create new workspace if there are multiple windows (so we're not the only one)
    if [[ $window_count -gt 1 ]]; then
      echo "Multiple windows, creating new workspace" >> "$log_file"

      # Find next contiguous workspace number
      # Count how many workspaces we have, next will be count + 1
      workspace_count=${#occupied[@]}
      next_workspace=$((workspace_count + 1))
      echo "Next workspace (contiguous): $next_workspace" >> "$log_file"

      # Cap at 9 (max workspace in aerospace config)
      if [[ $next_workspace -le 9 ]]; then
        echo "Moving to workspace $next_workspace" >> "$log_file"
        aerospace move-node-to-workspace "$next_workspace" </dev/null 2>> "$log_file"
        aerospace workspace "$next_workspace" </dev/null 2>> "$log_file"
      else
        echo "At max (9 workspaces), cannot create new workspace" >> "$log_file"
        # Already at max, do nothing
      fi
    else
      echo "Only one window, not creating new workspace" >> "$log_file"
    fi
  else
    echo "Not on last workspace, using default next" >> "$log_file"
    # Not on last workspace, use default behavior
    aerospace move-node-to-workspace --no-stdin next 2>> "$log_file"
    aerospace workspace --no-stdin next 2>> "$log_file"
  fi

elif [[ "$direction" == "prev" ]]; then
  echo "Moving to prev workspace" >> "$log_file"
  # For prev, just use default behavior
  aerospace move-node-to-workspace --no-stdin prev 2>> "$log_file"
  aerospace workspace --no-stdin prev 2>> "$log_file"
fi

echo "Done" >> "$log_file"
