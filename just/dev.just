set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/dev.just" --list | zsh -c "$JUSTGREP"

############  DEV TOOLS  ############

# wails inint
[no-cd]
wi project:
  wails init -t svelte-ts -n {{project}}

# wails dev
[no-cd]
wd:
  wails dev

# wails build
[no-cd]
wb:
  wails build

# tailwind watch
[no-cd]
tw:
  bunx tailwindcss -i ./src/global.css -o ./src/style.css --watch

# shadcn ui init
[no-cd]
uii:
  bunx --bun shadcn@latest init

# shadcn ui add <component>
[no-cd]
uia component:
  bunx --bun shadcn@latest add {{component}}

# bun install
[no-cd]
i *libs:
  bun install {{libs}}

# git origin
gr:
  git remote -v

# count lines of code
cloc:
  tokei

# needs to be hooked into git
# git delta viewer
gdelta *args:
  delta {{args}}

# biome lint
[no-cd]
@lint:
  print
  print "{{BrightMagenta}}BIOME LINT"
  print -- "----------------------------{{BrightCyan}}"
  biome check --write

# guthub cli
@hb *args:
  hub {{args}}

# launch services
@srv *args:
  -lunchy {{args}}

# git-bug
@bug *args:
  git-bug {{args}}

# log tui
log *args:
  nerdlog {{args}}

# database tui
db *args:
  dblab {{args}}

# database tui
db2 *args:
  gobang {{args}}

# create linux vm
linux *args:
  limactl {{args}}

# turso
@turso *args:
  tursodb {{args}}