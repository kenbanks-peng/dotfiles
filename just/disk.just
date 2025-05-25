set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/disk.just" --list | zsh -c "$JUSTGREP"

#####################   DISK   #####################

# disk usage
disk:
  duf /

# disk usage tui
disk1:
  ncdu

# disk usage
disk2:
  dust

# disk usage
disk3:
  dua i

