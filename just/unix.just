set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/unix.just" --list | zsh -c "$JUSTGREP"

############  UNIX UTIL  ############

# working directory
[no-exit-message]
@d *args:
  pwd {{args}}

# new copy
[no-exit-message]
cp *args:
  ditto {{args}}

# sed alternative for find/replace withing files
[no-exit-message]
sed2 *args:
  sd {{args}}

# sed alternative with fzf
[no-exit-message]
sed3 *args:
  sad {{args}}

# new grep for find within glob pattern
[no-exit-message]
@grepp *args:
  print "rg (ripgrep)"
  print
  rg {{args}}

# new man
[no-exit-message]
@man *args:
  print "tldr (tealdeer)"
  tldr {{ args }}


# Common pls function with SIP protection
[private]
[no-exit-message]
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
[no-exit-message]
[script]
l *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    just --justfile "$JUST/unix.just" pls_with_sip --det=git --header=false --suffix=false --sort=cat --sort=name {{args}}
  else
    just --justfile "$JUST/unix.just" pls_with_sip --header=false --suffix=false --sort=cat --sort=name {{args}}
  fi
  
# pls list hide hidden files
[no-exit-message]
[script]
ll *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    pls --det=git --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=dir {{args}}
    pls --det=git --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
  else
    pls --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=dir {{args}}
    pls --header=false --exclude='^\.' --suffix=false --sym=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
  fi

# list long
[no-exit-message]
[script]
lll *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    just --justfile "$JUST/unix.just" pls_with_sip --det=git --det=perm --det=user --det=size --det=mtime --det=typ --header=false {{args}}
  else
    just --justfile "$JUST/unix.just" pls_with_sip --det=perm --det=user --det=size --det=mtime --det=typ --header=false {{args}}
  fi

# new cat
[no-exit-message]
@cat *args:
  bat {{args}}

# new ps
[no-exit-message]
process *args:
  procs {{args}}

# top tui
[no-exit-message]
top:
  btop

# top tui
[no-exit-message]
top2:
  glances

# resource monitor
[no-exit-message]
mon:
  macmon

# more readable path. duplicates in red.
[no-exit-message]
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
[no-exit-message]
@clean:
  print "recursively remove .DS_store"
  sudo fd --unrestricted '^\.DS_Store$' --type file --exec-batch rm

# new find
[no-exit-message]
find *args:
  fd -uuu {{args}}

# new tail
[no-exit-message]
tail *args:
  tspin "{{args}}"

# new cut
[no-exit-message]
chz *args:
  choose {{args}}

# new ping
[no-exit-message]
ping *args:
  gping {{args}}

# symlink
[no-exit-message]
[script]
symlink original:
  # Convert to absolute paths
  original_abs=$(realpath "{{original}}")
  filename=$(basename "$original_abs")
  dir=$(dirname "$original_abs")
  
  if [[ "$filename" == *.* ]]; then
    name="${filename%.*}"
    ext="${filename##*.}"
    symlink_name="${name}-symlink.${ext}"
  else
    symlink_name="${filename}-symlink"
  fi
  
  symlink_path="${dir}/${symlink_name}"
   
  # Create the symlink using absolute paths
  ln -s "$original_abs" "$symlink_path"
  echo "$symlink_name -> $filename"