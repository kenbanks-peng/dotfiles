set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/unix.just" --list | zsh -c "$JUSTGREP"

############  UNIX UTIL  ############

# working directory
@d *args:
  pwd {{args}}

# new copy
cp *args:
  ditto {{args}}

# sed alternative for find/replace withing files
sed2 *args:
  sd {{args}}

# sed alternative with fzf
sed3 *args:
  sad {{args}}

# new grep for find within glob pattern
@gr *args:
  print "rg (ripgrep)"
  print
  rg {{args}}

# new man
@man *args:
  print "tldr (tealdeer)"
  tldr {{ args }}



# pls list hide hidden files
[script]
l *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    pls --det=git --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=dir {{args}}
    pls --det=git --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
  else
    pls --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=dir {{args}}
    pls --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
  fi


# Common pls function with SIP protection
[private]
[no-cd]
[script]
pls_with_sip *pls_args:
  # Create temp directory and config
  temp_dir=$(mktemp -d)
  temp_config="$temp_dir/pls.yml"
  trap "rm -rf $temp_dir" EXIT
  
  # Copy base config and add SIP patterns
  cp "$PLS_CONFIG" "$temp_config"
  
  # Build SIP-specific patterns for current directory files
  sip_patterns=""
  
  # Set nullglob to handle cases where no files match the pattern
  setopt nullglob
  
  # Check visible files
  for item in *; do
    if [[ -e "$item" ]]; then
      if \ls -lO "$item" 2>/dev/null | grep -q "restricted"; then
        # Escape special regex characters in filename
        escaped_item=$(printf '%s\n' "$item" | sed 's/[[\.*^$()+?{|]/\\&/g')
        sip_patterns+="  - pattern: ^${escaped_item}\$"$'\n'"    icons:"$'\n'"      - lock"$'\n'"    style: red"$'\n'
      fi
    fi
  done
  
  # Check hidden files
  for item in .*; do
    if [[ "$item" != "." && "$item" != ".." && -e "$item" ]]; then
      if \ls -lO "$item" 2>/dev/null | grep -q "restricted"; then
        # Escape special regex characters in filename
        escaped_item=$(printf '%s\n' "$item" | sed 's/[[\.*^$()+?{|]/\\&/g')
        sip_patterns+="  - pattern: ^${escaped_item}\$"$'\n'"    icons:"$'\n'"      - lock"$'\n'"    style: red"$'\n'
      fi
    fi
  done
  
  # Restore default glob behavior
  unsetopt nullglob
  
  # Add SIP patterns to config if any found
  if [[ -n "$sip_patterns" ]]; then
    echo "" >> "$temp_config"
    echo "  # SIP protected files" >> "$temp_config"
    echo "$sip_patterns" >> "$temp_config"
  fi
  
  # Run pls with custom config
  PLS_CONFIG="$temp_config" pls {{pls_args}}

# pls list show hidden files

[script]
ls *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    just --justfile "$JUST/unix.just" pls_with_sip --det=git --header=false --suffix=false --sort=cat --sort=name {{args}}
  else
    just --justfile "$JUST/unix.just" pls_with_sip --header=false --suffix=false --sort=cat --sort=name {{args}}
  fi
  

# list long
[script]
ll *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    just --justfile "$JUST/unix.just" pls_with_sip --det=git --det=perm --det=user --det=size --det=mtime --det=typ --header=false {{args}}
  else
    just --justfile "$JUST/unix.just" pls_with_sip --det=perm --det=user --det=size --det=mtime --det=typ --header=false {{args}}
  fi

# list w/ git-symbols
#
# blocks means show the block
#
# git symbols
# -----------
# - : default
# . : unmodified
# N : new in index
# ? : new in work directory
# D : deleted
# M : modified
# R : renamed
# I : ignored
# T : type change
# C : conflict
#
[script]
lg *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    lsd --almost-all --blocks name --blocks git {{args}}
  else
    lsd --almost-all --blocks name {{args}}
  fi


# list tree
[script]
lt *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    lsd --almost-all --tree --no-symlink --depth 2 -al --blocks name --blocks git {{args}}
  else
    lsd --almost-all --tree --no-symlink --depth 2 -al --blocks name {{args}}
  fi

# new cat
@cat *args:
  bat {{args}}

# new ps
process *args:
  procs {{args}}

# top tui
top:
  btop

# top tui
top2:
  glances

# resource monitor
mon:
  macmon

# more readable path. duplicates in red.
[script]
path:
  print $PATH | tr ':' '\n' | awk '{
    count[$0]++
    paths[NR] = $0
  }
  END {
      for (i = 1; i <= NR; i++) {
          if (count[paths[i]] > 1) {
              printf "\033[31m%s\033[0m\n", paths[i]
          } else {
              print paths[i]
          }
      }
  }'

# remove .DS_store
@clean:
  print "recursively remove .DS_store"
  sudo fd --unrestricted '^\.DS_Store$' --type file --exec-batch rm

# new find
find *args:
  fd -uuu {{args}}

# new tail
tail *args:
  tspin "{{args}}"

# new cut
chz *args:
  choose {{args}}

# new ping
ping *args:
  gping {{args}}
