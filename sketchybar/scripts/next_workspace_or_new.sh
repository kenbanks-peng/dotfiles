#!/bin/bash

# Get current workspace
current=$(aerospace list-workspaces --focused)

# Get all workspaces
all_workspaces=$(aerospace list-workspaces --all)

# Find if there's a workspace after current
next_workspace=""
found_current=false
for ws in $all_workspaces; do
  if [ "$found_current" = true ]; then
    next_workspace="$ws"
    break
  fi
  if [ "$ws" = "$current" ]; then
    found_current=true
  fi
done

# If there's a next workspace, switch to it
# Otherwise, trigger new workspace creation
if [ -n "$next_workspace" ]; then
  aerospace workspace "$next_workspace"
else
  sketchybar --trigger aerospace_new_workspace
fi
