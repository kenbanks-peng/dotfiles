set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/mise.just" --list | zsh -c "$JUSTGREP"

#############  MISE  ##############

# mise
[script]
ml *$args:
  a=(${=args})
  len=${#a[@]}
  a1=${a[1]}
  
  if [ $len = 1 ]; then
    if [ $a1 = "rust" ]; then
      mise list | rg "^cargo:"
    elif [ $a1 = "node" ]; then
      mise list | rg "^npm:"
    elif [ $a1 = "js" ]; then
      mise list | rg "^npm:"
    elif [ $a1 = "python" ]; then
      mise list | rg "^pipx:"
    else
      mise list | rg "^$a1:"
    fi
  else
    mise list {{args}}
  fi
 