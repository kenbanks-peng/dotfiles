set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/args.just" --list | zsh -c "$JUSTGREP"

############  ARGS TEST  ############

# test
[script]
test *$args:
  # using *$args format:
  a=(${=args})
  echo "args: {{args}}"
  echo "args: $args"
  echo "len: ${#a[@]}"
  echo "a1: ${a[1]}"
  echo "a2: ${a[2]}"
  