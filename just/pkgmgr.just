set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/pkgmgr.just" --list | zsh -c "$JUSTGREP"

#############  PACKAGE MANAGERS  ##############

# outdated
[script]
o:
  print
  print "{{BrightCyan}}BREW: mac apps, binaries"
  print -- "------------------------{{BrightBlue}}"
  brew outdated --greedy
  print
  print "{{BrightCyan}}MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------{{BrightBlue}}"
  mise self-update --silent --yes
  mise outdated --bump --silent
  # print
  # print
  # print "{{BrightCyan}}UV: python tools"
  # print -- "----------------{{BrightBlue}}"
  # uv tool upgrade --all
  # print
  # print
  # print "{{BrightCyan}}RUST/CARGO: rust packages"
  # print -- "-------------------------{{BrightBlue}}"
  # rustup check
  # cargo install-update -a
  # print
  # print
  # print "{{BrightCyan}}BUN: node js packages"
  # print -- "---------------------{{BrightBlue}}"
  # -bun -g update
  # print
  # print
  # print "{{BrightCyan}}Go: go packages"
  # print -- "----------------{{BrightBlue}}"
  # -gup update
  # print
 

# update
u: _update _versions

[script]
_update:
  print
  print "{{BrightCyan}}BREW: mac apps, binaries"
  print -- "------------------------{{BrightBlue}}"
  brew upgrade --greedy
  print
  print "{{BrightCyan}}MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------{{BrightBlue}}"
  mise self-update --silent --yes
  mise upgrade --bump --silent

[script]
_versions:
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
    print "UV TOOLS"
    print -- "--------"
    uv tool list
    print
    print "GO TOOLS"
    print -- "--------"
    gup list 2>/dev/null || print "No global go packages found"
    print
    print "RUSTUP/CARGO"
    print -- "------------"
    rustup show
    cargo version
    cargo install --list 2>/dev/null || print "No global cargo/rust packages found"
    print
    print "BUN"
    print -- "---"
    bun pm ls -g 2>/dev/null || print "No global bun packages found"
  } > "$DOTFILES/versions.txt"
 
  git -C "$DOTFILES" add versions.txt &>/dev/null
  git -C "$DOTFILES" diff --staged --quiet || (git -C "$DOTFILES" commit -m "update versions" && git -C "$DOTFILES" push) &>/dev/null
  
  print "{{BrightMagenta}}updated versions.txt{{BrightBlue}}"


