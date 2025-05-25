set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/go.just" --list | zsh -c "$JUSTGREP"

############  GO UTIL  ############

# go tool install
gti *args:
  go install {{args}}

# go tool check
#   possible use: gotools -bin $GOBIN
gtc *args:
  gotools {{args}}

# go tool update
gtu *args:
  gotools -u -q -j 8 {{args}}

# go tool remove
# gr *args:
