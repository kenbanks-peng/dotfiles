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

# If already contiguous, trigger rebuild and exit
# (Windows may have moved even if workspace numbers are correct)
if [[ "$is_contiguous" == "true" ]]; then
  echo "Already contiguous, triggering full rebuild" >> "$log_file"
  sketchybar --trigger aerospace_workspace_change FORCED=true &> /dev/null
  exit 0
fi

echo "Not contiguous, renumbering..." >> "$log_file"

# Get the currently focused window so we can track where it ends up
focused_window_id=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
echo "Focused window before renumbering: $focused_window_id" >> "$log_file"

# Temporarily disable yabai signals to prevent intermediate rebuilds during renumbering
echo "Disabling yabai signals during renumbering" >> "$log_file"
yabai -m signal --remove window_created 2>/dev/null
yabai -m signal --remove window_destroyed 2>/dev/null
yabai -m signal --remove window_minimized 2>/dev/null
yabai -m signal --remove window_deminimized 2>/dev/null

# Renumber workspaces directly - move windows from high to low workspace numbers
# This avoids conflicts without needing temporary workspaces
echo "Renumbering workspaces from high to low" >> "$log_file"
new_number=1
for sid in "${occupied[@]}"; do
  if [[ $sid -ne $new_number ]]; then
    # Get window IDs for this workspace
    mapfile -t window_id_array < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
    echo "  Moving workspace $sid -> $new_number (windows: ${window_id_array[*]})" >> "$log_file"

    for window_id in "${window_id_array[@]}"; do
      if [[ -n "$window_id" ]]; then
        aerospace move-node-to-workspace "$new_number" --window-id "$window_id" </dev/null
      fi
    done
  else
    echo "  Workspace $sid already correct" >> "$log_file"
  fi
  new_number=$((new_number + 1))
done

echo "Renumbering complete" >> "$log_file"

# Focus the workspace containing the previously focused window
if [[ -n "$focused_window_id" ]]; then
  new_workspace=$(aerospace list-windows --all --format '%{workspace} %{window-id}' | grep " $focused_window_id$" | awk '{print $1}')
  if [[ -n "$new_workspace" ]]; then
    echo "Focusing workspace $new_workspace (contains focused window $focused_window_id)" >> "$log_file"
    aerospace workspace "$new_workspace" </dev/null
  fi
fi

# Re-enable yabai signals
echo "Re-enabling yabai signals" >> "$log_file"
yabai -m signal --add event=window_created action="sketchybar --trigger yabai_window_created ID=\$YABAI_WINDOW_ID &> /dev/null"
yabai -m signal --add event=window_destroyed action="sketchybar --trigger yabai_window_destroyed ID=\$YABAI_WINDOW_ID &> /dev/null"
yabai -m signal --add event=window_minimized action="sketchybar --trigger yabai_window_minimized ID=\$YABAI_WINDOW_ID &> /dev/null"
yabai -m signal --add event=window_deminimized action="sketchybar --trigger yabai_window_deminimized ID=\$YABAI_WINDOW_ID &> /dev/null"

# Trigger a full rebuild now that renumbering is complete
echo "Triggering full sketchybar rebuild after renumbering" >> "$log_file"
sketchybar --trigger aerospace_workspace_change FORCED=true &> /dev/null
