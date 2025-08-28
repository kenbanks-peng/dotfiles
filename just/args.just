set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/args.just" --list | zsh -c "$JUSTGREP"

############  ARGS TEST  ############

# test with *$args (variadic string)
[script]
test *$args:
  # using *$args format:
  a=(${=args})
  echo "args: {{args}}"
  echo "args: $args"
  echo "len: ${#a[@]}"
  echo "a1: ${a[1]}"
  echo "a2: ${a[2]}"

# test with +args (one or more args as string) - fixed version
test2 +args:
  #!/usr/bin/env zsh
  # Pass the Just args variable to shell
  args="{{args}}"
  # Convert to array:
  a=(${=args})
  echo "args string: {{args}}"
  echo "args variable: $args"
  echo "arg count: ${#a[@]}"
  echo "arg1: ${a[1]}"
  echo "arg2: ${a[2]}"
  echo "arg3: ${a[3]}"

# test with named parameters - pass them to shell
test3 arg1 arg2 arg3="default":
  #!/usr/bin/env zsh
  # Pass the Just variables as shell arguments:
  set -- "{{arg1}}" "{{arg2}}" "{{arg3}}"
  echo "arg1: {{arg1}}"
  echo "arg2: {{arg2}}"
  echo "arg3: {{arg3}}"
  echo "arg1 in shell: $1"
  echo "arg2 in shell: $2"
  echo "arg3 in shell: $3"

# Alternative: using individual arguments (no variadic)
test4 arg1 arg2 arg3:
  #!/usr/bin/env zsh
  echo "Direct access: {{arg1}} {{arg2}} {{arg3}}"
  # Or if you need them as shell positional params:
  set -- "{{arg1}}" "{{arg2}}" "{{arg3}}"
  echo "Shell params: $1 $2 $3"