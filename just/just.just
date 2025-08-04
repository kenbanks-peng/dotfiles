# for justfiles, by default each command runs in a separate shell
# use shebangs when multiple commands must run in same shell
# if arg can be filename with spaces, use "{{args}}"
# no need to deactivate venvs since shell will end after command

set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST"/just.just --list | zsh -c "$JUSTGREP"

# editors
mod edit

# homebrew + mise + rustup
mod brew

# utilities
mod util

# tui apps
mod tui

# linux file util
mod unix

# json util
mod json

# disk util
mod disk

# http / curl
mod http

# sql
mod sql

# go
mod go

# dev
mod dev

# pdf
mod pdf

# web server
mod ws

# scripts
mod scripts

# args test
mod args

# quarto
mod quarto

# vide coding
mod vibe