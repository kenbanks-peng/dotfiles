set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/pkgmgr.just" --list | zsh -c "$JUSTGREP"

#############  PACKAGE MANAGERS  ##############

# outdated
@o:
  print
  print "BREW: mac apps, binaries"
  print -- "------------------------"
  brew outdated --greedy
  print
  print "MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------"
  mise --silent --yes self-update
  mise outdated --bump
  print
  print "UV: python tools"
  print -- "----------------"
  uv tool upgrade --all
  print
  print "RUST/CARGO: rust packages"
  print -- "-------------------------"
  rustup check
  cargo install-update -a
  print
  print "BUN: node js packages"
  print -- "---------------------"
  -bun -g update

# versions
[script]
v:
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
    mise list
    print
    print "UV TOOLS"
    print -- "--------"
    uv tool list
    print
    print "GO TOOLS"
    print -- "--------"
    ls $GOBIN
    print
    print "RUSTUP/CARGO"
    print -- "------------"
    rustup show
    cargo version
    cargo install --list
    print
    print "BUN"
    print -- "---"
    bun pm ls -g 2>/dev/null || print "No global bun packages found"
  } > "$DOTFILES/versions.txt"
 
  git -C "$DOTFILES" add versions.txt &>/dev/null
  git -C "$DOTFILES" diff --staged --quiet || (git -C "$DOTFILES" commit -m "update versions" && git -C "$DOTFILES" push) &>/dev/null
  
