set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/framworks.just" --list | zsh -c "$JUSTGREP"

#############  FRAMEWORKS  ##############

# python
@python_init:
  uv init --build-backend uv



