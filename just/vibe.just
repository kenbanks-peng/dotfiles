set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/vibe.just" --list | zsh -c "$JUSTGREP"

############  AGENTIC VIBE CODING  ############

# claude code
cc:
    claude

# claude code config
ccc:
    ccexp
