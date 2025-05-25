set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/scripts.just" --list | zsh -c "$JUSTGREP"

#############  SHELL  ##############

# list shells
@list:
  echo "shells:"
  echo "  bash(linix), zsh(macos), powershell(windows), ksh(unix), sh(og), dash(minimal)"
  echo "  ysh(modern), nu(modern), fish(modern)"

# edit scripts in cursor
@scripts:
  cursor "$SCRIPTS"

#####################   PYTHON   #####################

# create symbolic link
@symlink:
  python "$PYTHON/symlink/symlink.py"

# pass source to be symlinked and 2 destinations
@switch *args:
  python "$PYTHON/switch/switch.py" {{ args }}

# json cv to pdf
cv *args:
  #!/usr/bin/env zsh
  source "$PYTHON/cv/.venv/bin/activate"
  uv run cv {{ args }}


#####################    NODE    #####################

# mycolor <color>
@mycolor arg:
  zx "$NODE"/color/color.mjs -c "{{ arg }}"

# color utils
color *args:
  pastel color "{{args}}"
