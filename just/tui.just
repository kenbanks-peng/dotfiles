set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

# list all recipes
default:
  @just --justfile "$JUST"/tui.just --list | zsh -c "$JUSTGREP"

##################  TUIs  ####################

# ssh client tui
ss:
  sshs

# file transfer (portal) tui
pl:
  portal

# lazydocker
ld:
  lazydocker

# lazysql
lsql *args:
  lazysql {{args}}

# lazyjournal
lj *args:
  lazyjournal {{args}}

# lazyjj
ljj *args:
  lazyjj {{args}}

# shell cheatsheet
cs:
  navi

# terminal mux
tm:
  zellij

# network monitor
sniff:
  sudo sniffnet


