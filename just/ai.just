set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/vibe.just" --list | zsh -c "$JUSTGREP"

############  AGENTIC VIBE CODING  ############

# claude code
[no-exit-message]
cc:
    claude

# claude code config
[no-exit-message]
ccc:
    ccexp

# claude code init workflow
[no-exit-message]
cciw:
    bunx @pimzino/claude-code-spec-workflow@latest

# claude squad 
[no-exit-message]
cs *args:
  claude-squad {{args}}

# search code
[no-exit-message]
goat *args:
  seagoat {{args}}

# cc status line
ccstatus:
  bunx ccstatusline@latest
