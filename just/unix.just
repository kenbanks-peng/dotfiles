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


# pls list show hidden files
[script]
ls *args:
  # Check if -al or -la is present
  has_al=false
  for arg in {{args}}; do
    if [[ "$arg" == "-al" || "$arg" == "-la" ]]; then
      has_al=true
      break
    fi
  done
  
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    if [[ "$has_al" == "true" ]]; then
      pls --det=git --det=perm --det=user --det=size --det=mtime --det=typ --header=false
    else
      pls --det=git --header=false --only='^\.' --suffix=false --sort=cat --sort=name --typ=dir {{args}}
      pls --det=git --header=false --only='^\.' --suffix=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
      pls --det=git --header=false --exclude='^\.' --suffix=false --sort=cat --typ=dir --sort=name {{args}}
      pls --det=git --header=false --exclude='^\.' --suffix=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
    fi
  else
    if [[ "$has_al" == "true" ]]; then
      pls --det=perm --det=user --det=size --det=mtime --det=typ --header=false
    else
      pls --header=false --only='^\.' --suffix=false --sort=cat --sort=name --typ=dir {{args}}
      pls --header=false --only='^\.' --suffix=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
      pls --header=false --exclude='^\.' --suffix=false --sort=cat --typ=dir --sort=name {{args}}
      pls --header=false --exclude='^\.' --suffix=false --sort=cat --sort=name --typ=file --typ=symlink --typ=fifo --typ=socket --typ=char-device --typ=block-device {{args}}
    fi
  fi
  

# list long
[script]
ll *args:
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    pls --det=git --det=perm --det=user --det=size --det=mtime --det=typ --header=false {{args}}
  else
    pls --det=perm --det=user --det=size --det=mtime --det=typ --header=false {{args}}
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
