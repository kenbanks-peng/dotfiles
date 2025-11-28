#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"
source "$PLUGIN_DIR/helpers/aerospace.sh"

# Reset the logs
: > "$CACHE_DIR/$LOG_FILE"

location="left"

sketchybar --add event aerospace_workspace_change
sketchybar --add event yabai_window_created
sketchybar --add event yabai_window_destroyed
sketchybar --add event yabai_window_minimized
sketchybar --add event yabai_window_deminimized

sketchy_add_item aerospace_spaces_spacer "$location" \
  --set aerospace_spaces_spacer background.padding_left=10

props=(
  icon.drawing=off
  label.drawing=off
  background.drawing=off
  width=0
)
  sketchy_add_item space_listener "$location" \
  --set space_listener "${props[@]}" \
  script="$PLUGIN_DIR/aerospace_spaces.sh" \
  --subscribe space_listener \
  aerospace_workspace_change \
  yabai_window_created \
  yabai_window_destroyed \
  yabai_window_minimized \
  yabai_window_deminimized


# add workspace.start and workspace.end dividers 
# as anchor points for the workspaces
props=(
  background.padding_left=0
  background.padding_right=0
  background.height=$BAR_HEIGHT
  background.color=$BAR
  icon.width=2
  icon.padding_left=0
  icon.padding_right=0
)
workspaces=($(aerospace_workspaces))
for sid in "${workspaces[@]}"; do
  start="workspace.start.$sid"
  end="workspace.end.$sid"
  
  sketchy_add_item "$start" "$location" \
    --set "$start" "${props[@]}"

  sketchy_add_item "$end" "$location" \
    --set "$end" "${props[@]}"

  sketchy_add_workspace "$sid"
done
