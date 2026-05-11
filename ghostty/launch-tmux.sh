#!/bin/sh
# Picks a tmux session based on terminal width so the ghostty quick terminal
# (narrower, centered) gets its own session independent from the main window.
TMUX_BIN=/opt/homebrew/bin/tmux

# Ghostty may exec this before SIGWINCH lands with the actual window size.
# Poll briefly for a stable, plausible width.
cols=0
i=0
while [ "$i" -lt 10 ]; do
  cols=$(stty size 2>/dev/null | awk '{print $2}')
  cols=${cols:-0}
  [ "$cols" -gt 100 ] && break
  sleep 0.05
  i=$((i + 1))
done

if [ "$cols" -lt 150 ]; then
  SESSION=quick
else
  SESSION=main
fi

"$TMUX_BIN" attach -t "$SESSION" 2>/dev/null || "$TMUX_BIN" new-session -s "$SESSION"
