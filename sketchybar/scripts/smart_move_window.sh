#!/usr/bin/env bash

# Smart window movement: if on last occupied workspace, create new one to the right
# Otherwise, use default aerospace behavior

direction="$1"  # "next" or "prev"

# Get current workspace
current=$(aerospace list-workspaces --focused)

# Get all occupied workspaces sorted numerically
occupied=($(aerospace list-workspaces --all | sort -n))

# Find position of current workspace in occupied list
current_index=-1
for i in "${!occupied[@]}"; do
  if [[ "${occupied[$i]}" == "$current" ]]; then
    current_index=$i
    break
  fi
done

if [[ "$direction" == "next" ]]; then
  # Check if we're on the last occupied workspace
  if [[ $current_index -eq $((${#occupied[@]} - 1)) ]]; then
    # We're on the last workspace - find next available number
    next_workspace=$((current + 1))

    # Cap at 9 (max workspace in aerospace config)
    if [[ $next_workspace -le 9 ]]; then
      aerospace move-node-to-workspace "$next_workspace"
      aerospace workspace "$next_workspace"
    else
      # Already at max, just use default behavior
      aerospace move-node-to-workspace next
      aerospace workspace next
    fi
  else
    # Not on last workspace, use default behavior
    aerospace move-node-to-workspace next
    aerospace workspace next
  fi
elif [[ "$direction" == "prev" ]]; then
  # For prev, just use default behavior
  aerospace move-node-to-workspace prev
  aerospace workspace prev
fi
