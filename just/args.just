set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/args.just" --list | zsh -c "$JUSTGREP"

############  ARGS TEST  ############

test *$args:
  #! /usr/bin/env zsh

  # using *$args format:
  a=(${=args})
  echo "args: {{args}}"
  echo "args: $args"
  echo "len: ${#a[@]}"
  echo "a1: ${a[1]}"
  echo "a2: ${a[2]}"
  