set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/quatro.just" --list | zsh -c "$JUSTGREP"

############  QUATRO  ############

# quatro
qmd file:
  quarto render {{file}} --to revealjs --output-dir "$HOME/Documents/Presentations" 

