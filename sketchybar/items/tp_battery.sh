#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

location="right"

props=(
  script="$PLUGIN_DIR/tp_battery.sh"
  update_freq=120
  icon="$ICON_TRACKPAD"
  icon.color="$SAPPHIRE"
  icon.font="$FONT:$((ICON_FONTSIZE-2))"
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

sketchy_add_item tp_battery "$location" \
  --set tp_battery "${props[@]}"
