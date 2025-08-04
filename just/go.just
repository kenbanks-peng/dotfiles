set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/go.just" --list | zsh -c "$JUSTGREP"

############  GO UTIL  ############

# go tool install
[no-exit-message]
gti *args:
  go install {{args}}

# go tool check
#   possible use: gotools -bin $GOBIN
[no-exit-message]
gtc *args:
  gotools {{args}}

# go tool update
[no-exit-message]
gtu *args:
  gotools -u -q -j 8 {{args}}