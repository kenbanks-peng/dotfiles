#!/bin/sh
# Called from a tmux session-closed hook. Any large client now attached to
# the "quick" session got there because its previous session was destroyed
# (detach-on-destroy=off). Move it to another real session, or detach.
#
# session-closed fires before tmux has re-attached orphaned clients, so we
# poll briefly for them to land on quick.
clients=""
i=0
while [ "$i" -lt 20 ]; do
  clients=$(tmux list-clients -t quick -F '#{client_name} #{client_width}' 2>/dev/null)
  [ -n "$clients" ] && break
  sleep 0.05
  i=$((i + 1))
done

echo "$clients" | while read -r client width; do
  [ -z "$client" ] && continue
  [ "${width:-0}" -lt 150 ] && continue
  others=$(tmux list-sessions 2>/dev/null | awk -F: '{print $1}' | grep -vx quick)
  if [ -n "$others" ]; then
    target=$(echo "$others" | head -n1)
    tmux switch-client -c "$client" -t "$target"
  else
    tmux detach-client -t "$client"
  fi
done
