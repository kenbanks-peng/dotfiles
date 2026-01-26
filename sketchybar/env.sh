#!/usr/bin/env bash

export NASA_API_KEY="$NASA_API_KEY"

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/icons/icons.sh"

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
export BACKGROUND_HEIGHT=30
export APP_WIDTH=16
export WORKSPACE_DIVIDER_WIDTH=4

# =============================================================================
# Centralized Style Properties - avoid duplication across scripts
# =============================================================================

# Workspace divider style (used in items/aerospace_spaces.sh and sync_workspaces)
# Usage: sketchybar --set "$item" "${WORKSPACE_DIVIDER_PROPS[@]}"
get_workspace_divider_props() {
  echo "background.padding_left=0"
  echo "background.padding_right=0"
  echo "background.height=$BACKGROUND_HEIGHT"
  echo "background.color=$BAR"
  echo "background.corner_radius=0"
  echo "width=$WORKSPACE_DIVIDER_WIDTH"
  echo "icon.drawing=off"
  echo "label.drawing=off"
  echo "y_offset=0"
}

# Window item style (used in aerospace_new_window_id, aerospace_add_apps_in_spaceid, etc)
# Usage: sketchybar --set "$item" "${WINDOW_ITEM_PROPS[@]}"
get_window_item_props() {
  echo "background.corner_radius=0"
  echo "icon.font=$ICON_FONT:$ICON_FONTSIZE"
  echo "icon.width=$APP_WIDTH"
}
