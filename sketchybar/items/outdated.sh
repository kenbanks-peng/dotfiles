#!/usr/bin/env bash

source "$PLUGIN_DIR/helpers/sketchy.sh"

location="right"

sketchybar --add event update_outdated

props=(
  script="$PLUGIN_DIR/outdated.sh"
  update_freq="$((10 * 60))" # once every 10 minutes
  icon.drawing=off
  icon="$ICON_LEGO"
  label.drawing=on
  icon.padding_left=0
  icon.padding_right=0
  label.padding_left=0
  label.padding_right=2
  label.width=16
  label.align=center
  background.padding_left=0
  background.padding_right=0
)
sketchy_add_item outdated "$location" \
  --set outdated "${props[@]}" \
  --subscribe outdated update_outdated mouse.clicked
