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

# Renumber workspaces to be contiguous
new_number=1
for sid in "${occupied[@]}"; do
  if [[ $sid -ne $new_number ]]; then
    # Move all windows from old workspace to new workspace
    aerospace_window_ids=$(aerospace list-windows --workspace "$sid" --format '%{window-id}')

    if [[ -n "$aerospace_window_ids" ]]; then
      # Read into array
      read -ra window_id_array <<< "$aerospace_window_ids"
      for window_id in "${window_id_array[@]}"; do
        aerospace move-node-to-workspace "$new_number" --window-id "$window_id" </dev/null
      done
    fi
  fi
  new_number=$((new_number + 1))
done
