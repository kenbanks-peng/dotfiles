#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

location="right"

props=(
  script="$PLUGIN_DIR/cpu.sh"
  update_freq=2
  icon="$ICON_CPU"
  icon.color="$SAPPHIRE"
  icon.font="$FONT:$((ICON_FONTSIZE-4))"
  icon.padding_left=0
  icon.padding_right=0
  label.drawing=on
  label.color="$SAPPHIRE"
  label.padding_left=2
  label.padding_right=0
  label.width=36
  label.align=center
  background.padding_left=0
  background.padding_right=0
)

sketchy_add_item cpu "$location" \
  --set cpu "${props[@]}" \
  --subscribe cpu mouse.clicked
