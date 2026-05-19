#!/bin/sh
# Picks a tmux session based on whether Ghostty launched this surface as the
# quick terminal. Default to the main session so a normal Ghostty restart never
# opens the quick session because of transient startup window dimensions.
TMUX_BIN=/opt/homebrew/bin/tmux

if [ "${GHOSTTY_QUICK_TERMINAL:-}" = "1" ]; then
	SESSION=quick
else
	SESSION=main
fi

"$TMUX_BIN" attach -t "$SESSION" 2>/dev/null || "$TMUX_BIN" new-session -s "$SESSION"
