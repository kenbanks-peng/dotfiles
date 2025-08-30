set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/dev.just" --list | zsh -c "$JUSTGREP"

############  DEV TOOLS  ############

# wails inint
[no-exit-message]
[no-cd]
wi project:
  wails init -t svelte-ts -n {{project}}

# wails dev
[no-exit-message]
[no-cd]
wd:
  wails dev

# wails build
[no-exit-message]
[no-cd]
wb:
  wails build

# tailwind watch
[no-exit-message]
[no-cd]
tw:
  bunx tailwindcss -i ./src/global.css -o ./src/style.css --watch

# shadcn ui init
[no-exit-message]
[no-cd]
uii:
  bunx --bun shadcn@latest init

# shadcn ui add <component>
[no-exit-message]
[no-cd]
uia component:
  bunx --bun shadcn@latest add {{component}}

# bun install
[no-exit-message]
[no-cd]
i *libs:
  bun install {{libs}}

# count lines of code
[no-exit-message]
cloc:
  tokei

# biome lint
[no-exit-message]
[no-cd]
@lint:
  print
  print "{{BrightMagenta}}BIOME LINT"
  print -- "----------------------------{{BrightCyan}}"
  biome check --write

# launch services
[no-exit-message]
@srv *args:
  -lunchy {{args}}

# log tui
[no-exit-message]
log *args:
  nerdlog {{args}}

# database tui
[no-exit-message]
db *args:
  dblab {{args}}

# database tui
[no-exit-message]
db2 *args:
  gobang {{args}}

# create linux vm
[no-exit-message]
linux *args:
  limactl {{args}}

# turso
[no-exit-message]
@turso *args:
  tursodb {{args}}