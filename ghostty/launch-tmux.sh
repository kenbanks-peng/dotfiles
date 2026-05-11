#!/bin/sh
# Picks a tmux session based on terminal width so the ghostty quick terminal
# (narrower, centered) gets its own session independent from the main window.
TMUX_BIN=/opt/homebrew/bin/tmux

cols=$(stty size 2>/dev/null | awk '{print $2}')
: "${cols:=200}"

if [ "$cols" -lt 150 ]; then
  SESSION=quick
else
  SESSION=main
fi

"$TMUX_BIN" attach -t "$SESSION" 2>/dev/null || "$TMUX_BIN" new-session -s "$SESSION"
