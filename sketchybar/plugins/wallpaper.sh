#!/usr/bin/env bash

source "$CONFIG_DIR/env.sh"
WALLPAPPER_CACHE="$CACHE_DIR/wallpaper"

set_cache(){
  local state=$1
  echo "$state" > "$WALLPAPPER_CACHE"
}

get_cache(){
  cat "$WALLPAPPER_CACHE"
}

set_wallpaper_solid(){
  SOLID_WALLPAPER="$CONFIG_DIR/wallpapers/wallpaper_solid.jpg"
  wallpaper set "$SOLID_WALLPAPER"
  set_cache "solid"
}

set_wallpaper_nasa(){
  local force=$1
 
  # Check if today's wallpaper already exists
  TODAY=$(date +"%Y-%m-%d")
  TODAYS_WALLPAPER="$CONFIG_DIR/wallpapers/wallpaper_$TODAY.jpg"

  if [ "$force" = "true" ]; then
    rm -f "$TODAYS_WALLPAPER"
  fi

  # Download the image only if today's wallpaper doesn't exist
  if [ ! -f "$TODAYS_WALLPAPER" ]; then
    url=$(command curl -s "https://api.nasa.gov/planetary/apod?api_key=$NASA_API_KEY" | jq -r .url)
    curl -o "$TODAYS_WALLPAPER" "$url"
  fi

  # Set the wallpaper
  wallpaper set "$TODAYS_WALLPAPER"
  set_cache "nasa"
}

confetti() {
  afplay "$CONFIG_DIR/plugins/helpers/Cheer.wav" &
  open "raycast://extensions/raycast/raycast/confetti" &
}

toggle_wallpaper() {
  if [ $(get_cache) = "solid" ]; then
    set_wallpaper_nasa true
  else
    set_wallpaper_solid
  fi
}

if [ "$SENDER" = "forced" ]; then
  set_cache "nasa"
elif [ "$SENDER" = "routine" ]; then
  set_wallpaper_nasa
elif [ "$BUTTON" = "left" ]; then
  sketchybar --reload
elif [ "$BUTTON" = "right" ]; then
  toggle_wallpaper
  confetti
fi
