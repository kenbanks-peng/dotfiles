set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/quatro.just" --list | zsh -c "$JUSTGREP"

############  QUATRO  ############

# quatro
qmd *args:
  quarto render --to revealjs --output-dir /Users/ken/Documents/Presentations {{args}}

