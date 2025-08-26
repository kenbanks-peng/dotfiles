set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/edit.just" --list | zsh -c "$JUSTGREP"

#####################   EDITORS   #####################

# Common editor function
[private]
[no-exit-message]
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

# vscode editor - kiro / cursor / code  
[no-exit-message]
e *args: (editor "codellm" args)

# nvim editor
[no-exit-message]
n *args: 
  nvim {{args}}

# zed editor
[no-exit-message]
z *args: (editor "zed" args)

# micro editor
[no-exit-message]
mic *args: (editor "micro" args)

# lazygit tui
[no-exit-message]
g *args:
  lazygit {{args}}

# gitui tui
[no-exit-message]
gt *args:
  gitui {{args}}

# markdown tui
[no-exit-message]
md *args:
  glow {{args}}
