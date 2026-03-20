#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

location="right"

props=(
  icon.padding_left=0
  icon.padding_right=0
  icon.font="$FONT:11"
  icon.color=$SAPPHIRE
  script="$PLUGIN_DIR/aerospace_controls.sh"
)

# spacer
sketchy_add_item layout.spacer.right $location \
  --set layout.spacer.right icon.width=5

# auto-focus
sketchy_add_item layout.auto_focus $location \
  --set layout.auto_focus icon="$ICON_MOUSE_PTR" "${props[@]}" \
  --subscribe layout.auto_focus mouse.clicked

# enable/disable
sketchy_add_item layout.enable $location \
  --set layout.enable icon="$ICON_BUTTON" "${props[@]}" \
  --subscribe layout.enable mouse.clicked

# flatten workspace tree
sketchy_add_item layout.flatten $location \
  --set layout.flatten icon="$ICON_FLATTEN" "${props[@]}" \
  --subscribe layout.flatten mouse.clicked

# join windows right
sketchy_add_item layout.join_right $location \
  --set layout.join_right icon="$ICON_JOIN_RIGHT" "${props[@]}" icon.font="$ICOMOON:16" \
  --subscribe layout.join_right mouse.clicked

# join windows left
sketchy_add_item layout.join_left $location \
  --set layout.join_left icon="$ICON_JOIN_LEFT" "${props[@]}" icon.font="$ICOMOON:16" \
  --subscribe layout.join_left mouse.clicked

# floating / tiling
sketchy_add_item layout.float $location \
  --set layout.float icon="$ICON_FLOAT" "${props[@]}" \
  --subscribe layout.float mouse.clicked

# tiles layout
sketchy_add_item layout.tiles $location \
  --set layout.tiles icon="$ICON_TILE" "${props[@]}" \
  --subscribe layout.tiles mouse.clicked

# stack layout
sketchy_add_item layout.stack $location \
  --set layout.stack icon=$ICON_STACK "${props[@]}" \
  --subscribe layout.stack mouse.clicked

# spacer
sketchy_add_item layout.spacer.left $location \
  --set layout.spacer.left icon.width=80

sketchybar --add bracket aerospace_controls '/layout\..*/' \
           --set aerospace_controls background.color=$WORKSPACE_ODD
                    