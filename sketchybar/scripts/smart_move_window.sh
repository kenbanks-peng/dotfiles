#!/usr/bin/env bash

# Smart window movement using state-based approach:
# 1. Read current state from aerospace
# 2. Calculate desired end state in arrays
# 3. Apply minimal changes to both aerospace and sketchybar

# Source helpers for sketchybar management
source "$HOME/Software/Public/dotfiles/sketchybar/plugins/helpers/sketchy.sh"
source "$HOME/Software/Public/dotfiles/sketchybar/env.sh"

direction="$1"  # "next" or "prev"

# Log for debugging
log_file="/tmp/smart_move_window.log"
echo "=== $(date) ===" >> "$log_file"
echo "Direction: $direction" >> "$log_file"

# === STEP 1: READ CURRENT STATE ===

current_sid=$(aerospace list-workspaces --focused)
focused_window_id=$(aerospace list-windows --focused --format '%{window-id}')

echo "Current workspace: $current_sid" >> "$log_file"
echo "Focused window: $focused_window_id" >> "$log_file"

# Build current state: array of workspaces, each with array of window_ids
declare -A current_state  # workspace_id -> "window_id1 window_id2 ..."
mapfile -t workspace_ids < <(aerospace list-workspaces --all | sort -n)

for sid in "${workspace_ids[@]}"; do
  mapfile -t windows < <(aerospace list-windows --workspace "$sid" --format '%{window-id}')
  current_state[$sid]="${windows[*]}"
done

echo "Current state:" >> "$log_file"
for sid in "${workspace_ids[@]}"; do
  echo "  Workspace $sid: ${current_state[$sid]}" >> "$log_file"
done

# Find current workspace index
current_index=-1
for i in "${!workspace_ids[@]}"; do
  if [[ "${workspace_ids[$i]}" == "$current_sid" ]]; then
    current_index=$i
    break
  fi
done

if [[ $current_index -eq -1 ]]; then
  echo "ERROR: Could not find current workspace" >> "$log_file"
  exit 1
fi

# === STEP 2: CALCULATE DESIRED END STATE ===

# Count windows in current workspace
window_count=$(echo "${current_state[$current_sid]}" | wc -w | tr -d ' ')
echo "Window count in current workspace: $window_count" >> "$log_file"

# Determine if at edge
if [[ "$direction" == "next" ]]; then
  is_at_edge=$((current_index == ${#workspace_ids[@]} - 1))
  target_index=$((current_index + 1))
elif [[ "$direction" == "prev" ]]; then
  is_at_edge=$((current_index == 0))
  target_index=$((current_index - 1))
fi

echo "At edge: $is_at_edge, Target index: $target_index" >> "$log_file"

# Calculate desired state
declare -A desired_state
declare -a desired_workspace_ids
new_focused_sid="$current_sid"
new_focused_window_id="$focused_window_id"

if [[ $window_count -gt 1 ]]; then
  # === MULTIPLE WINDOWS: MOVE FOCUSED WINDOW ===
  echo "Strategy: Move focused window" >> "$log_file"

  if [[ $is_at_edge -eq 1 ]]; then
    # Create new workspace at edge
    echo "Creating new workspace at edge" >> "$log_file"

    if [[ "$direction" == "next" ]]; then
      # Add workspace at end
      new_sid=$((workspace_ids[-1] + 1))
      if [[ $new_sid -gt 9 ]]; then
        echo "Cannot create workspace > 9, no changes" >> "$log_file"
        # Copy current state as desired state
        for sid in "${workspace_ids[@]}"; do
          desired_state[$sid]="${current_state[$sid]}"
        done
        desired_workspace_ids=("${workspace_ids[@]}")
      else
        # Remove focused window from current, add to new workspace
        for sid in "${workspace_ids[@]}"; do
          if [[ $sid -eq $current_sid ]]; then
            # Remove focused window from current workspace
            local windows=()
            for wid in ${current_state[$sid]}; do
              if [[ $wid != $focused_window_id ]]; then
                windows+=("$wid")
              fi
            done
            desired_state[$sid]="${windows[*]}"
          else
            desired_state[$sid]="${current_state[$sid]}"
          fi
        done
        # Add new workspace with focused window
        desired_state[$new_sid]="$focused_window_id"
        desired_workspace_ids=("${workspace_ids[@]}" "$new_sid")
        new_focused_sid="$new_sid"
      fi
    else
      # Add workspace at beginning (use temp workspace 0, then renumber)
      # Remove focused window from current workspace
      for sid in "${workspace_ids[@]}"; do
        if [[ $sid -eq $current_sid ]]; then
          local windows=()
          for wid in ${current_state[$sid]}; do
            if [[ $wid != $focused_window_id ]]; then
              windows+=("$wid")
            fi
          done
          desired_state[$((sid + 1))]="${windows[*]}"
        else
          desired_state[$((sid + 1))]="${current_state[$sid]}"
        fi
      done
      # Add new workspace 1 with focused window
      desired_state[1]="$focused_window_id"
      # Rebuild workspace ID list
      desired_workspace_ids=()
      for ((i=1; i<=${#workspace_ids[@]}+1; i++)); do
        if [[ -n "${desired_state[$i]}" ]]; then
          desired_workspace_ids+=("$i")
        fi
      done
      new_focused_sid=1
    fi
  else
    # Move to existing adjacent workspace
    target_sid="${workspace_ids[$target_index]}"
    echo "Moving to existing workspace $target_sid" >> "$log_file"

    for sid in "${workspace_ids[@]}"; do
      if [[ $sid -eq $current_sid ]]; then
        # Remove focused window from current
        local windows=()
        for wid in ${current_state[$sid]}; do
          if [[ $wid != $focused_window_id ]]; then
            windows+=("$wid")
          fi
        done
        desired_state[$sid]="${windows[*]}"
      elif [[ $sid -eq $target_sid ]]; then
        # Add focused window to target
        desired_state[$sid]="${current_state[$sid]} $focused_window_id"
      else
        desired_state[$sid]="${current_state[$sid]}"
      fi
    done
    desired_workspace_ids=("${workspace_ids[@]}")
    new_focused_sid="$target_sid"
  fi

else
  # === SINGLE WINDOW: RIPPLE ===
  echo "Strategy: Ripple" >> "$log_file"

  if [[ $is_at_edge -eq 1 ]]; then
    # No action at edge with single window
    echo "At edge with single window - no action" >> "$log_file"
    for sid in "${workspace_ids[@]}"; do
      desired_state[$sid]="${current_state[$sid]}"
    done
    desired_workspace_ids=("${workspace_ids[@]}")
  else
    # Ripple: shift workspaces in direction
    if [[ "$direction" == "next" ]]; then
      # Ripple right: workspaces to the right shift left
      echo "Ripple right" >> "$log_file"

      for i in "${!workspace_ids[@]}"; do
        sid="${workspace_ids[$i]}"
        if [[ $i -lt $current_index ]]; then
          # Workspaces before current: unchanged
          desired_state[$sid]="${current_state[$sid]}"
        elif [[ $i -eq $current_index ]]; then
          # Current workspace: gets windows from next workspace
          next_sid="${workspace_ids[$((i + 1))]}"
          desired_state[$sid]="${current_state[$sid]} ${current_state[$next_sid]}"
        elif [[ $i -gt $current_index ]] && [[ $i -lt $((${#workspace_ids[@]} - 1)) ]]; then
          # Workspaces after current (except last): get windows from next
          next_sid="${workspace_ids[$((i + 1))]}"
          desired_state[$sid]="${current_state[$next_sid]}"
        fi
        # Last workspace is omitted (will be empty, removed)
      done

      # New workspace list (last one removed)
      desired_workspace_ids=("${workspace_ids[@]:0:${#workspace_ids[@]}-1}")

    else
      # Ripple left: workspaces to the left shift right (to make room)
      # Example: s1w1 s2w2 s3wf s4w3 -> s1w1 s2w2,wf s3w3 (s1 removed after renumber)
      # Data flow: s1→s2, s2→s3(current), s1 removed
      echo "Ripple left" >> "$log_file"

      for i in "${!workspace_ids[@]}"; do
        sid="${workspace_ids[$i]}"
        if [[ $i -gt $current_index ]]; then
          # Workspaces after current: unchanged
          desired_state[$sid]="${current_state[$sid]}"
        elif [[ $i -eq $current_index ]]; then
          # Current workspace: gets windows from previous workspace PLUS keeps its own
          prev_sid="${workspace_ids[$((i - 1))]}"
          desired_state[$sid]="${current_state[$prev_sid]} ${current_state[$sid]}"
        elif [[ $i -lt $current_index ]] && [[ $i -gt 0 ]]; then
          # Workspaces before current (except first): shift right (get previous workspace's content)
          prev_sid="${workspace_ids[$((i - 1))]}"
          desired_state[$sid]="${current_state[$prev_sid]}"
        fi
        # First workspace (i=0) is omitted (will be removed)
      done

      # New workspace list (first one removed)
      desired_workspace_ids=("${workspace_ids[@]:1}")
    fi

    # Renumber to be contiguous starting from 1
    declare -A renumbered_state
    new_num=1
    for sid in "${desired_workspace_ids[@]}"; do
      renumbered_state[$new_num]="${desired_state[$sid]}"
      if [[ $sid -eq $current_sid ]]; then
        new_focused_sid=$new_num
      fi
      new_num=$((new_num + 1))
    done
    desired_state=()
    for key in "${!renumbered_state[@]}"; do
      desired_state[$key]="${renumbered_state[$key]}"
    done
    desired_workspace_ids=()
    for ((i=1; i<$new_num; i++)); do
      desired_workspace_ids+=("$i")
    done
  fi
fi

echo "Desired state:" >> "$log_file"
for sid in "${desired_workspace_ids[@]}"; do
  echo "  Workspace $sid: ${desired_state[$sid]}" >> "$log_file"
done
echo "New focused workspace: $new_focused_sid" >> "$log_file"

# === STEP 3: APPLY CHANGES ===

echo "Applying changes..." >> "$log_file"

# Apply to aerospace
for sid in "${desired_workspace_ids[@]}"; do
  for window_id in ${desired_state[$sid]}; do
    if [[ -n "$window_id" ]]; then
      # Check if window needs to move
      current_ws=""
      for check_sid in "${workspace_ids[@]}"; do
        if echo "${current_state[$check_sid]}" | grep -qw "$window_id"; then
          current_ws="$check_sid"
          break
        fi
      done

      if [[ "$current_ws" != "$sid" ]]; then
        echo "Moving window $window_id: $current_ws -> $sid" >> "$log_file"
        aerospace move-node-to-workspace "$sid" --window-id "$window_id" </dev/null 2>> "$log_file"
      fi
    fi
  done
done

# Focus the new workspace and window
if [[ "$new_focused_sid" != "$current_sid" ]]; then
  echo "Switching to workspace $new_focused_sid" >> "$log_file"
  aerospace workspace "$new_focused_sid" </dev/null 2>> "$log_file"
fi

if [[ "$new_focused_window_id" != "$focused_window_id" ]] || [[ "$new_focused_sid" != "$current_sid" ]]; then
  echo "Focusing window $new_focused_window_id" >> "$log_file"
  aerospace focus --window-id "$new_focused_window_id" </dev/null 2>> "$log_file"
fi

# Apply to sketchybar
# Remove workspaces that no longer exist
for sid in "${workspace_ids[@]}"; do
  exists=false
  for desired_sid in "${desired_workspace_ids[@]}"; do
    if [[ $sid -eq $desired_sid ]]; then
      exists=true
      break
    fi
  done

  if [[ $exists == false ]]; then
    echo "Removing sketchybar workspace $sid" >> "$log_file"

    # Remove all window items
    local window_items=($(sketchybar --query bar 2>/dev/null | jq -r --arg sid "$sid" '.items[]? // empty | select(test("^window\\." + $sid + "\\."))'))
    for item in "${window_items[@]}"; do
      sketchy_remove_item "$item"
    done

    # Remove workspace dividers
    sketchy_remove_item "workspace.start.$sid"
    sketchy_remove_item "workspace.end.$sid"
    sketchy_remove_item "workspace.$sid"
  fi
done

echo "Done" >> "$log_file"
