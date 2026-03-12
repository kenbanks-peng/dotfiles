#!/usr/bin/env bash

# Creates a pipe separator item
# Usage: SEPARATOR_NAME=sep_1 source $ITEM_DIR/separator.sh

source "$PLUGIN_DIR/helpers/sketchy.sh"

location="right"

props=(
  icon="$ICON_PIPE"
  icon.color="$OVERLAY0"
  icon.font="$NERD:18"
  icon.padding_left=10
  icon.padding_right=10
  label.drawing=off
  background.padding_left=0
  background.padding_right=0
)

sketchy_add_item "$SEPARATOR_NAME" "$location" \
  --set "$SEPARATOR_NAME" "${props[@]}"
