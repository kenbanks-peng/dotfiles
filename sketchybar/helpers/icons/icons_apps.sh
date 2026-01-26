#!/usr/bin/env bash

# Custom overrides - checked first before falling back to generated icon_map.sh
function app_icons() {
    case "$1" in

    # overrides from SF symbols app or sketchybar-app-font
    "Streaks")
        icon_result=":lm_studio:"
        ;;
    "Disk Utility")
        icon_result=":logicpro:"
        ;;
    "Microsoft Outlook")
        icon_result="􀍕"
        ;;
    "BoltAI")
        icon_result="􀋥"
        ;;
    "Kiro" | "Cursor" | "CodeLLM")
        icon_result=":code:"
        ;;
    "WezTerm" | "Rio")
        icon_result="􀩼"
        ;;
    "Obsidian")
        icon_result="􀉞"
        ;;
    "Elephas")
        icon_result="󰟆"
        ;;
    "Claudia")
        icon_result=":claude:"
        ;;
    "Structured")
        icon_result=":tick_tick:"
        ;;
    "Bible Study")
        icon_result=":raspberry_pi:"
        ;;
    *)
        # Not found in overrides - fall back to generated icon_map.sh
        return 1
        ;;
    esac
}

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try custom overrides first
app_icons "$1"
if [[ $? -ne 0 ]]; then
    # Fall back to generated icon_map.sh
    source "$SCRIPT_DIR/../icon_map.sh"
    __icon_map "$1"
fi

echo "${icon_result}"
