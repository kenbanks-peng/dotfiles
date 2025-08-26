set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/ai.just" --list | zsh -c "$JUSTGREP"

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
[no-exit-message]
ccstatus:
  bunx ccstatusline@latest

# cc spec workflow
[no-exit-message]
ccsw:
  claude-code-spec-workflow

# abacus codellm cli
[no-exit-message]
llm:
  codellm-cli

