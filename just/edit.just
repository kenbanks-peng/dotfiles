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

# cursor editor
e *args: (_editor "cursor" args)

# code editor
c *args: (_editor "code" args)

# nvim editor
n *args: (_editor "nvim" args)

# zed editor
z *args: (_editor "zed" args)

# micro editor
mic *args: (_editor "micro" args)

# lazygit tui
g *args:
  lazygit {{args}}

# gitui tui
gt *args:
  gitui {{args}}

# markdown tui
m *args:
  glow {{args}}
