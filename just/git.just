set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/git.just" --list | zsh -c "$JUSTGREP"

############  GIT  ############

# git origin
[no-exit-message]
gr:
  git remote -v

# git status
[no-exit-message]
gs:
  git fetch; git status

# needs to be hooked into git
# git delta viewer
[no-exit-message]
gdelta *args:
  delta {{args}}

# guthub cli
[no-exit-message]
@hb *args:
  hub {{args}}

# git-bug
[no-exit-message]
@bug *args:
  git-bug {{args}}
