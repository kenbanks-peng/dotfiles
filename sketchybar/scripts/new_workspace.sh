#!/usr/bin/env bash

# Create a new workspace after the last occupied one and switch to it
# This works by finding the highest occupied workspace number and moving to the next one

# Get all occupied workspaces sorted numerically
occupied=($(aerospace list-workspaces --all | sort -n))

if [[ ${#occupied[@]} -eq 0 ]]; then
  # No workspaces, go to 1
  aerospace workspace 1
  exit 0
fi

# Get the last (highest) occupied workspace
last_workspace="${occupied[-1]}"

# Calculate next workspace
next_workspace=$((last_workspace + 1))

# Cap at 9 (max workspace in aerospace config)
if [[ $next_workspace -le 9 ]]; then
  aerospace workspace "$next_workspace"
else
  # Already at max, just go to workspace 9
  aerospace workspace 9
fi
