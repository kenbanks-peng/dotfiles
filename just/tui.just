set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

# list all recipes
default:
  @just --justfile "$JUST"/tui.just --list | zsh -c "$JUSTGREP"

##################  TUIs  ####################

# ssh client tui
[no-exit-message]
ss:
  sshs

# file transfer (portal) tui
[no-exit-message]
pl:
  portal

# lazydocker
[no-exit-message]
ld:
  lazydocker

# lazysql
[no-exit-message]
lsql *args:
  lazysql {{args}}

# lazyjournal
[no-exit-message]
lj *args:
  lazyjournal {{args}}

# lazyjj
[no-exit-message]
ljj *args:
  lazyjj {{args}}

# shell cheatsheet
[no-exit-message]
cs:
  navi

# terminal mux
[no-exit-message]
tm:
  zellij

# network monitor
[no-exit-message]
sniff:
  sudo sniffnet

# gpg tui
[no-exit-message]
gpgtui:
  gpg-tui
