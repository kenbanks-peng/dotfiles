#!/usr/bin/env bash

export NASA_API_KEY="$NASA_API_KEY"

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

export CACHE_DIR="$HOME/.cache/sketchybar"

# create the cache directory if needed
mkdir -p "$CACHE_DIR"

# env variables
export PLUGIN_DIR="$CONFIG_DIR/plugins"
export ITEM_DIR="$CONFIG_DIR/items"
export LOG_FILE="aerospace.log"

export ICON_FONT="sketchybar-app-font:Regular"
export ICON_FONTSIZE=14
export FONT="SF Pro:Semibold"
export FONTSIZE=12
export NERD="Symbols Nerd Font:Regular"
export ICOMOON="Icomoon:Regular"

export BAR_HEIGHT=40
export ITEM_HEIGHT=24
export APP_WIDTH=16
export WORKSPACE_DIVIDER_WIDTH=4