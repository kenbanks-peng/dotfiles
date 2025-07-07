set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/edit.just" --list | zsh -c "$JUSTGREP"

#####################   EDITORS   #####################

# Common editor function
[private]
[script]
editor command *args:
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}{{command}} {{args}}"
    print
    {{command}} {{args}}
  else
    print "{{BrightMagenta}}{{command}} ."
    print
    {{command}} .
  fi

# vscode editor
e *args: (editor "cursor" args)

# nvim editor
n *args: 
  nvim {{args}}

# zed editor
z *args: (editor "zed" args)

# micro editor
mic *args: (editor "micro" args)

# lazygit tui
g *args:
  lazygit {{args}}

# gitui tui
gt *args:
  gitui {{args}}

# markdown tui
md *args:
  glow {{args}}
