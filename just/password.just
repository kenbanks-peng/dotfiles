set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/password.just" --list | zsh -c "$JUSTGREP"

############  PASSWORD-STORE  ############

# password add
[no-exit-message]
@passadd *args:
  pass insert {{args}}

# password generate github/personal
[no-exit-message]
@passgen *args:
  pass generate {{args}}

# password list
[no-exit-message]
@passlist *args:
  pass ls {{args}}

# password find
[no-exit-message]
@passfind *args:
  pass find {{args}}

# password grep
[no-exit-message]
@passgrep *args:
  pass grep {{args}}

# password copy
@passcopy *args:
  pass show -c {{args}}

# password del
@passdel *args:
  pass rm {{args}}

# password git revert HEAD
@passgit *args:
  pass git {{args}}