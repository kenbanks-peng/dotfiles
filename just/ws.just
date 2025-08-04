set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/ws.just" --list | zsh -c "$JUSTGREP"

#####################   WEBSERVER   #####################


# start caddy server
[no-exit-message]
[no-cd]
ws-go:
  caddy start

# stop caddy server
[no-exit-message]
[no-cd]
ws-stop:
  caddy stop
