set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/disk.just" --list | zsh -c "$JUSTGREP"

#####################   DISK   #####################

# disk usage
[no-exit-message]
disk:
  duf /

# disk usage tui
[no-exit-message]
disk1:
  ncdu

# disk usage
[no-exit-message]
disk2:
  dust

# disk usage
[no-exit-message]
disk3:
  dua i

