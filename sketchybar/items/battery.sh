#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

location="right"

props=(
  script="$PLUGIN_DIR/battery.sh"
  update_freq=120
  icon="$ICON_LAPTOP"
  icon.color="$SAPPHIRE"
  icon.font="$FONT:$((ICON_FONTSIZE-2))"
  icon.padding_left=0
  icon.padding_right=0
  label.drawing=on
  label.color="$SAPPHIRE"
  label.padding_left=0
  label.padding_right=0
  label.width=16
  label.align=center
  background.padding_left=0
  background.padding_right=0
  drawing=off
)

sketchy_add_item battery "$location" \
  --set battery "${props[@]}" \
  --subscribe battery system_woke power_source_change mouse.clicked

sep_props=(
  icon="$ICON_PIPE"
  icon.color="$SURFACE1"
  icon.font="$NERD:18"
  icon.padding_left=6
  icon.padding_right=6
  label.drawing=off
  background.padding_left=0
  background.padding_right=0
  drawing=off
)

sketchy_add_item sep_battery "$location" \
  --set sep_battery "${sep_props[@]}"
