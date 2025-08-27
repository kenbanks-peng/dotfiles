set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/brew.just" --list | zsh -c "$JUSTGREP"

#############  BREW + MISE  ##############

# outdated
[no-exit-message]
[script]
o:
  print
  print "{{BrightCyan}}BREW: mac apps, binaries"
  print -- "------------------------{{BrightBlue}}"
  brew outdated --greedy --verbose
  print
  print "{{BrightCyan}}MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------{{BrightBlue}}"
  mise outdated --bump --silent
  print
  print "{{BrightCyan}}RUSTUP: rust"
  print -- "------------------------------------{{BrightBlue}}"
  rustup check
  # uv tool upgrade --all
  # cargo install-update -a
  # -bun -g update
  # -gup update

# update
[no-exit-message]
up: _update versions

[no-exit-message]
[script]
_update:
  print
  print "{{BrightCyan}}BREW: mac apps, binaries"
  print -- "------------------------{{BrightBlue}}"
  brew upgrade --greedy
  brew cleanup
  print
  print "{{BrightCyan}}MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------{{BrightBlue}}"
  mise self-update --silent --yes
  mise upgrade --bump --silent
  print
  print "{{BrightCyan}}RUSTUP: rust"
  print -- "------------------------------------{{BrightBlue}}"
  rustup update

# brew versions
[no-exit-message]
[script]
versions:
  {
    print "BREW CASKS"
    print -- "----------"
    brew list --versions --cask || print "No casks found"
    print
    print "BREW FORMULAS"
    print -- "-------------"
    brew list --versions --formula || print "No formulas found"
    print
    print "MISE PACKAGES"
    print -- "-------------"
    mise list 2>/dev/null || print "No global mise packages found"
    print
    print "RUSTUP/CARGO"
    print -- "------------"
    rustup show || print "No rustup found"
    # cargo version || print "No cargo found"
    # cargo install --list 2>/dev/null || print "No global cargo/rust packages found"
    # print
    # print "UV TOOLS"
    # print -- "--------"
    # uv tool list
    # print
    # print "GO TOOLS"
    # print -- "--------"
    # gup list 2>/dev/null || print "No global go packages found"
    # print
    # print "BUN"
    # print -- "---"
    # bun pm ls -g 2>/dev/null || print "No global bun packages found"
  } > "$DOTFILES/versions.txt"
 
  git -C "$DOTFILES" add versions.txt &>/dev/null
  git -C "$DOTFILES" diff --staged --quiet || (git -C "$DOTFILES" commit -m "update versions" && git -C "$DOTFILES" push) &>/dev/null
  
  print
  print "{{BrightMagenta}}updated versions.txt{{BrightBlue}}"


#############  BREW ONLY  ##############

# brew versions
[no-exit-message]
@bv *args:
  print "brew list --versions {{args}}"
  print
  print "{{BrightMagenta}}CASK APPS"
  print -- "---------{{BrightBlue}}"
  brew list --versions --cask {{args}} || print "{{BrightRed}}No cask apps found{{BrightCyan}}"
  print
  print "{{BrightMagenta}}FORMULA APPS"
  print -- "------------{{BrightCyan}}"
  brew list --versions --formula {{args}} || print "{{BrightRed}}No formula apps found{{BrightCyan}}"

# brew list / leaves
[no-exit-message]
[script]
bl *$args:
  a=(${=args})
  len=${#a[@]}
  a1=${a[1]}

  if [ $len = 1 ] && [ "$a1" = "leaves" ]; then
    print "brew leaves"
    print
    print "{{BrightMagenta}}USER-INSTALLED LEAF FORMULAS"
    print -- "----------------------------{{BrightCyan}}"
    brew leaves --installed-on-request
  elif [ $len = 1 ] && [ "$a1" = "apps" ]; then
    print "brew list casks"
    print
    print "{{BrightMagenta}}CASK APPS"
    print -- "---------{{BrightCyan}}"
    brew list --cask 
  else
    print "brew list {{args}}"
    print
    brew list --formula {{args}}
  fi

# brew outdated (greedy)
[no-exit-message]
@bo:
  print "brew outdated (greedy)"
  print
  brew outdated --greedy --verbose

# brew search
[no-exit-message]
@bs *args:
  print "brew search" {{args}}
  print
  brew search {{args}}

# brew remove (w/ autoremove, cleanup)
[no-exit-message]
@br *args:
  print "brew remove /w autoremove and cleanup"
  print
  brew remove {{ args }}
  brew autoremove
  brew cleanup
  just --justfile "$JUST/brew.just" versions

# brew tree (casks and formulas)
[no-exit-message]
[script]
bt *args:
  print "brew tree {{args}}"
  print
  print "{{BrightMagenta}}FORMULAS"
  print -- "--------{{BrightCyan}}"
  if [ -n "{{args}}" ]; then
    brew deps --tree --formula {{args}}
  else
    brew leaves | xargs brew deps --tree --formula
  fi


# brew packages that depend on
[no-exit-message]
@bdo *args:
  print "brew packages that depend on" {{args}}
  print
  brew uses --installed {{args}}

# brew zap
[no-exit-message]
bz:
  brew cleanup --prune=all
  rm -rf "$HOME/Library/Application Support/Caches"
  mkdir "$HOME/Library/Application Support/Caches"
  rm -rf "$HOME/.cache"
  mkdir "$HOME/.cache"
  go clean -modcache

# brew fonts 
[no-exit-message]
[script]
bf *$args:
  a=(${=args})
  len=${#a[@]}
  a1=${a[1]}

  if [ $len = 1 ] && [ "$a1" = "installed" ]; then
    print "brew fonts installed"
    print
    brew list --cask | rg "font-"
  else
    print "brew fonts available"
    print
    brew search --cask "font" | rg "font-" | rg -v -f <(brew list --cask | rg "font-")
  fi

#############  MISE ONLY  ##############

# mise list by category
[no-exit-message]
[script]
ml *$args:
  a=(${=args})
  len=${#a[@]}
  a1=${a[1]}

  mise_output=$(mise list)
  purple="\033[95m"
  white="\033[97m"
  title="${purple}Tool                                       Version           Source                    Requested${white}"

  if [ $len = 1 ]; then
    # Map common aliases to actual prefixes (case-insensitive)
    case "${a1:l}" in
      rust) a1="cargo" ;;
      python) a1="pipx" ;;
      js|node) a1="npm" ;;
    esac
    
    echo -e "$title"
    echo "$mise_output" | grep "^$a1:"
  else
    echo -e "$title"
    echo "$mise_output" | grep -v ":"
    
    # Get unique tool prefixes from mise output
    tools=$(echo "$mise_output" | grep ":" | cut -d: -f1 | sort -u)
    
    for tool in ${=tools}; do
      echo
      echo -e "${purple}$(echo "$tool" | tr '[:lower:]' '[:upper:]')${white}"
      echo "$mise_output" | grep "^$tool:"
    done
  fi