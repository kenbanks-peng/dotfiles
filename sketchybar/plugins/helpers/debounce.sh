#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/helpers/util.sh"
source "$CONFIG_DIR/env.sh"

# Get current timestamp in format SSMMM (seconds + milliseconds)
get_timestamp() {
  # Get seconds and nanoseconds
  local seconds=$(date +"%S")
  local nanoseconds=$(date +"%N")
  # Convert nanoseconds to milliseconds (first 3 digits)
  local milliseconds=${nanoseconds:0:3}
  # Convert to numbers without leading zeros
  seconds=$((10#$seconds))
  milliseconds=$((10#$milliseconds))
  # Format with leading zeros
  printf "%02d%03d" "$seconds" "$milliseconds"
}

# Convert timestamp to number without leading zeros
timestamp_to_number() {
  local timestamp="$1"
  echo "$((10#$timestamp))"
}
