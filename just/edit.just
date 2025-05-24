set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/edit.just" --list | zsh -c "$JUSTGREP"

#####################   EDITORS   #####################


# void editor
e *args:
  #!/usr/bin/env zsh
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}code {{args}}"
    print
    void {{args}}
  else
    print "{{BrightMagenta}}code ."
    print
    void .
  fi

# cursor editor
c *args:
  #!/usr/bin/env zsh
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}code {{args}}"
    print
    cursor {{args}}
  else
    print "{{BrightMagenta}}code ."
    print
    cursor .
  fi

# nvim tui
n *args:
  #!/usr/bin/env zsh
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}code {{args}}"
    print
    nvim {{args}}
  else
    print "{{BrightMagenta}}code ."
    print
    nvim .
  fi

# micro tui
mic *args:
  #!/usr/bin/env zsh
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}code {{args}}"
    print
    micro {{args}}
  else
    print "{{BrightMagenta}}code ."
    print
    micro .
  fi

# zed editor
z *args:
  #!/usr/bin/env zsh
  if [ -n "{{args}}" ]; then
    print "{{BrightMagenta}}zed {{args}}"
    print
    zed {{args}}
  else
    print "{{BrightMagenta}}zed ."
    print
    zed .
  fi

# git tui
g *args:
  lazygit {{args}}

# git tui
gt *args:
  gitui {{args}}

# markdown tui
m *args:
  glow {{args}}


