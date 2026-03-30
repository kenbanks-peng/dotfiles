#!/usr/bin/env bash

sesh connect "$(
  sesh list --icons | fzf-tmux -p 50%,30% \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
    --header '                  ^x kill session   ^f find   (see ^t and ^p)' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-x:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)'
)"
