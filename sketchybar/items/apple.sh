#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"
source "$PLUGIN_DIR/helpers/sketchy.sh"

props=(
	icon="$ICON_APPLE_LOGO"
	icon.font="$ICON_FONT:18"
	icon.color="$SKY"
	padding_left=10
	background.corner_radius=0
  background.color="$GROUP"
	script="$PLUGIN_DIR/apple.sh"
)

sketchy_add_item apple.logo right \
	--set apple.logo "${props[@]}" \
	--subscribe apple.logo mouse.clicked
