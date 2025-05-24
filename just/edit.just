set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/edit.just" --list | zsh -c "$JUSTGREP"

#####################   EDITORS   #####################

# Common editor function
_editor command *args:
  #!/usr/bin/env zsh
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}{{command}} {{args}}"
    print
    {{command}} {{args}}
  else
    print "{{BrightMagenta}}{{command}} ."
    print
    {{command}} .
  fi

# void editor
e *args: (_editor "void" args)

# cursor editor
c *args: (_editor "cursor" args)

# nvim tui
n *args: (_editor "nvim" args)

# micro tui
mic *args: (_editor "micro" args)

# zed editor
z *args: (_editor "zed" args)

# git tui
g *args:
  lazygit {{args}}

# git tui
gt *args:
  gitui {{args}}

# markdown tui
m *args:
  glow {{args}}
