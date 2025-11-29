#!/usr/bin/env bash

# Ensure workspace numbers are contiguous (1, 2, 3...) with no gaps
# Renumbers workspaces if there are gaps

# Debug log file
log_file="/tmp/ensure_contiguous.log"
echo "=== $(date) ===" >> "$log_file"

# Get all occupied workspaces sorted
occupied=($(aerospace list-workspaces --all | sort -n))
echo "Occupied workspaces: ${occupied[*]}" >> "$log_file"

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
  echo "Already contiguous, exiting" >> "$log_file"
  exit 0
fi

echo "Not contiguous, renumbering..." >> "$log_file"

# Renumber workspaces to be contiguous SYNCHRONOUSLY
# Step 1: Move all workspaces to temporary numbers (100+) to avoid conflicts
temp_offset=100
index=0
echo "Step 1: Moving to temp workspaces" >> "$log_file"
for sid in "${occupied[@]}"; do
  temp_workspace=$((temp_offset + index))
  # Get window IDs - aerospace outputs one per line
  mapfile -t window_id_array < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
  echo "  Workspace $sid -> temp $temp_workspace (windows: ${window_id_array[*]})" >> "$log_file"

  for window_id in "${window_id_array[@]}"; do
    if [[ -n "$window_id" ]]; then
      aerospace move-node-to-workspace "$temp_workspace" --window-id "$window_id" </dev/null
    fi
  done
  index=$((index + 1))
done

# Step 2: Move from temporary numbers to final contiguous numbers (1, 2, 3...)
echo "Step 2: Moving to final workspaces" >> "$log_file"
new_number=1
index=0
for sid in "${occupied[@]}"; do
  temp_workspace=$((temp_offset + index))
  # Get window IDs - aerospace outputs one per line
  mapfile -t window_id_array < <(aerospace list-windows --workspace "$temp_workspace" --format '%{window-id}')
  echo "  Temp $temp_workspace -> workspace $new_number (windows: ${window_id_array[*]})" >> "$log_file"

  for window_id in "${window_id_array[@]}"; do
    if [[ -n "$window_id" ]]; then
      aerospace move-node-to-workspace "$new_number" --window-id "$window_id" </dev/null
    fi
  done
  new_number=$((new_number + 1))
  index=$((index + 1))
done

echo "Renumbering complete" >> "$log_file"

# NOTE: Do NOT trigger sketchybar here - let the caller handle it
# The caller (smart_move_window.sh) will trigger the rebuild synchronously
