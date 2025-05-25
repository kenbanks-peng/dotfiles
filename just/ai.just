set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/ai.just" --list | zsh -c "$JUSTGREP"

#############  AI  ##############

# how to do something
@how *args:
  how2 {{args}}

# aichat
@ai *args:
  aichat {{args}}

