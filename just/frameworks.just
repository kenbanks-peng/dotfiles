set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/framworks.just" --list | zsh -c "$JUSTGREP"

#############  FRAMEWORKS  ##############

# python project
@python_init:
  uv init --build-backend uv

# python package for pypi
@python_package package:
  uv init --build-backend uv --package {{package}}

