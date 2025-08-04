set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/scripts.just" --list | zsh -c "$JUSTGREP"

#############  SHELL  ##############

# list shells
[no-exit-message]
@list:
  echo "shells:"
  echo "  bash(linix), zsh(macos), powershell(windows), ksh(unix), sh(og), dash(minimal)"
  echo "  ysh(modern), nu(modern), fish(modern)"

# edit scripts in cursor
[no-exit-message]
@scripts:
  "$EDITOR $SCRIPTS"

#####################   PYTHON   #####################

# create symbolic link
[no-exit-message]
@symlink:
  python "$PYTHON/symlink/symlink.py"

# pass source to be symlinked and 2 destinations
[no-exit-message]
@switch *args:
  python "$PYTHON/switch/switch.py" {{ args }}

# json cv to pdf
[no-exit-message]
[script]
cv *args:
  source "$PYTHON/cv/.venv/bin/activate"
  uv run cv {{ args }}


#####################    NODE    #####################

# mycolor <color>
[no-exit-message]
@mycolor arg:
  zx "$NODE"/color/color.mjs -c "{{ arg }}"

# color utils
[no-exit-message]
color *args:
  pastel color "{{args}}"
