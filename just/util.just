set unstable
set script-interpreter := ['zsh']
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
[no-exit-message]
@secure:
  . "$ZSH_SCRIPTS/secure.zsh"

# shell linter
[no-exit-message]
sc *args:
  shellcheck {{args}}

# multiplex github accounts
[no-exit-message]
@github:
  cp ~/.config/gh/hosts.yml.$1 ~/.config/gh/hosts.yml
  gh auth status

# bundleid "Visual Studio Code"
[no-exit-message]
@bundleid arg:
  osascript -e 'id of app "{{arg}}"'
  # mdls -name kMDItemCFBundleIdentifier "{{arg}}"

# melody language to regex
[no-exit-message]
mel *args:
  melody {{args}}

# code refactoring
[no-exit-message]
ast *args:
  ast-grep {{args}}

# local task mgr
[no-exit-message]
tsk *args:
  task {{args}}

# rainbow text
[no-exit-message]
lc *args:
  lolcat {{args}}

# hyperfine 'sleep 0.3' - OK
# bm 'sleep 0.3' -- ERROR
# benchmarks
[no-exit-message]
bm *args:
  hyperfine {{args}}

# generate regex
[no-exit-message]
regex *args:
  greg {{args}}

# 1-line weather
[no-exit-message]
@w:
  curl "wttr.in/London+ON?format=%c%t(%f)+%p+%m\n"

# weather report
[no-exit-message]
@wr:
  curl "wttr.in/London+ON?0"

# weather forcast
[no-exit-message]
@wf:
  curl "wttr.in/London+ON"

# TBD: batgrep, batman, batpipe, batwatch, batdiff, prettybat

# ascii doc
[no-exit-message]
ad *args:
  asciidoctor {{args}}

# machine stats
[no-exit-message]
ff:
  fastfetch

# code/git stats
[no-exit-message]
of:
  onefetch

# font manager
[no-exit-message]
font *args:
  fnt {{args}}

# show img
[no-exit-message]
show *args:
  imgcat {{args}}

# table
[no-exit-message]
@tbl *args:
  column -t {{args}}

# watch a directory/file for changes
[no-exit-message]
watch *args:
  watchexec {{args}}

# cheatsheet
[no-exit-message]
cs *args:
  cheat {{args}}

# scan
[no-exit-message]
scan *args:
  rustscan {{args}}

# fzf alternative
[no-exit-message]
fz *args:
  -sk {{args}}

# echo 9 13 5 17 1 | spark
[no-exit-message]
s *args:
  spark {{args}}

# csv
[no-exit-message]
@csv2 *args:
  qsv {{args}}

# csv
[no-exit-message]
@csv *args:
  csvtk {{args}}


