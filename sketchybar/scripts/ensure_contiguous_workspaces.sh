#!/usr/bin/env bash

# Ensure workspace numbers are contiguous (1, 2, 3...) with no gaps
# Renumbers workspaces if there are gaps

# Get all occupied workspaces sorted
occupied=($(aerospace list-workspaces --all | sort -n))

# Check if workspaces are already contiguous
is_contiguous=true
expected=1
for sid in "${occupied[@]}"; do
  if [[ $sid -ne $expected ]]; then
    is_contiguous=false
    break
  fi
  expected=$((expected + 1))
done

# If already contiguous, nothing to do
if [[ "$is_contiguous" == "true" ]]; then
  exit 0
fi

# Renumber workspaces to be contiguous SYNCHRONOUSLY
# Step 1: Move all workspaces to temporary numbers (100+) to avoid conflicts
temp_offset=100
index=0
for sid in "${occupied[@]}"; do
  temp_workspace=$((temp_offset + index))
  aerospace_window_ids=$(aerospace list-windows --workspace "$sid" --format '%{window-id}')

  if [[ -n "$aerospace_window_ids" ]]; then
    # Read into array
    read -ra window_id_array <<< "$aerospace_window_ids"
    for window_id in "${window_id_array[@]}"; do
      aerospace move-node-to-workspace "$temp_workspace" --window-id "$window_id" </dev/null
    done
  fi
  index=$((index + 1))
done

# Step 2: Move from temporary numbers to final contiguous numbers (1, 2, 3...)
new_number=1
index=0
for sid in "${occupied[@]}"; do
  temp_workspace=$((temp_offset + index))
  aerospace_window_ids=$(aerospace list-windows --workspace "$temp_workspace" --format '%{window-id}')

  if [[ -n "$aerospace_window_ids" ]]; then
    # Read into array
    read -ra window_id_array <<< "$aerospace_window_ids"
    for window_id in "${window_id_array[@]}"; do
      aerospace move-node-to-workspace "$new_number" --window-id "$window_id" </dev/null
    done
  fi
  new_number=$((new_number + 1))
  index=$((index + 1))
done

# CRITICAL: Trigger Sketchybar to re-sync AFTER all moves are complete
# This ensures Sketchybar sees the final state, not intermediate states
sketchybar --trigger aerospace_workspace_change FORCED=true
