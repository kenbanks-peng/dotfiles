set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/sql.just" --list | zsh -c "$JUSTGREP"

############  SQL  ############

# sqlite3 db
[no-exit-message]
sqlite *args:
  sqlite3 {{args}}

# libsql
[no-exit-message]
sql *args:
  sqld {{args}}
