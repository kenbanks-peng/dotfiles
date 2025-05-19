set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/util.just" --list | zsh -c "$JUSTGREP"

#####################   SHELL   #####################

#
# security procedure:
#   key-gen
#   cat file | key-enc <publickey>
#   cat encrypted
#   cat encrypted | key-dec secret.key -> decrypted
#
# optional --armor formatting, -p passwords
#

# age wrapper
@secure:
  . "$ZSH_SCRIPTS/secure.zsh"

# shell linter
sc *args:
  shellcheck {{args}}

# multiplex github accounts
@github:
  cp ~/.config/gh/hosts.yml.$1 ~/.config/gh/hosts.yml
  gh auth status

# bundleid "Visual Studio Code"
@bundleid arg:
  osascript -e 'id of app "{{arg}}"'
  # mdls -name kMDItemCFBundleIdentifier "{{arg}}"

# melody language to regex
mel *args:
  melody {{args}}

# code refactoring
ast *args:
  ast-grep {{args}}

# local task mgr
tsk *args:
  task {{args}}

# rainbow text
lc *args:
  lolcat {{args}}

# hyperfine 'sleep 0.3' - OK
# bm 'sleep 0.3' -- ERROR
# benchmarks
bm *args:
  hyperfine {{args}}

# generate regex
regex *args:
  greg {{args}}

# 1-line weather
@w:
  curl "wttr.in/London+ON?format=%c%t(%f)+%p+%m\n"

# weather report
@wr:
  curl "wttr.in/London+ON?0"

# weather forcast
@wf:
  curl "wttr.in/London+ON"

# TBD: batgrep, batman, batpipe, batwatch, batdiff, prettybat

# ascii doc
ad *args:
  asciidoctor {{args}}

# machine stats
ff:
  fastfetch

# code/git stats
of:
  onefetch

# font manager
font *args:
  fnt {{args}}

# show img
show *args:
  imgcat {{args}}

# table
@tbl *args:
  column -t {{args}}

# watch a directory/file for changes
watch *args:
  watchexec {{args}}

# cheatsheet
cs *args:
  cheat {{args}}

# scan
scan *args:
  rustscan {{args}}

# fzf alternative
fz *args:
  -sk {{args}}