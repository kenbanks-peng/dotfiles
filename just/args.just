set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/args.just" --list | zsh -c "$JUSTGREP"

############  ARGS TEST  ############

# *$args as $
[script]
test *$args:
  set -- ${=args}
  len=$#

  echo "arg1: $1"
  echo "arg2: $2" 
  echo "arg3: $3"
  echo "total args: $len"

# *$args to array
[script]
test2 *$args:
  a=(${=args})
  echo "args: {{args}}"
  echo "args: $args"
  echo "len: ${#a[@]}"
  echo "a1: ${a[1]}"
  echo "a2: ${a[2]}"

