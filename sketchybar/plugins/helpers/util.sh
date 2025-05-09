#!/usr/bin/env bash


log() {
  echo "$1" >> "$CACHE_DIR/$LOG_FILE"
}

# check for whole word match in array
item_in_array() {
  local item="$1"
  shift
  if printf '%s\n' "$@" | rg -q "^$item$"; then
    return 0
  else
    return 1
  fi
}

remove_first_item() {
  local item_to_delete="$1"
  shift
  local list=("$@")
  local new_list=()
  local removed=false

  for item in "${list[@]}"; do
    if [[ "$item" == "$item_to_delete" && "$removed" == false ]]; then
      removed=true
      continue
    fi
    new_list+=("$item")
  done

  echo "${new_list[@]}"
}


unmatched_items() {
  # delimit by space or newline
  local IFS=$' \n'
  source=($1)
  target=($2)

  for key in "${source[@]}"; do
    for i in "${target[@]}"; do
      if [[ "$i" =~ ^window.*\.$key\.* ]]; then
        target=($(remove_first_item "$i" "${target[@]}"))
        break
      fi
    done
  done

  # Filter out empty strings and .default entries
  for i in "${target[@]}"; do
    if [[ -n "$i" && ! "$i" =~ \.default$ ]]; then
      result+=("$i")
    fi
  done

  echo "${result[@]}"
}


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

# Calculate time difference in milliseconds between two timestamps
diff_time() {
  local current_time="$1"
  local last_time="$2"
  
  # Split into seconds and milliseconds
  local current_seconds=${current_time:0:2}
  local current_ms=${current_time:2:3}
  local last_seconds=${last_time:0:2}
  local last_ms=${last_time:2:3}
  
  # Convert to total milliseconds
  current_seconds=$((10#$current_seconds))
  current_ms=$((10#$current_ms))
  last_seconds=$((10#$last_seconds))
  last_ms=$((10#$last_ms))
  
  local current_total_ms=$((current_seconds * 1000 + current_ms))
  local last_total_ms=$((last_seconds * 1000 + last_ms))
  
  # Handle wrap around
  if [ $current_total_ms -lt $last_total_ms ]; then
    # Add 60 seconds worth of milliseconds
    current_total_ms=$((current_total_ms + 60000))
  fi
  
  echo $((current_total_ms - last_total_ms))
}
