set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/json.just" --list | zsh -c "$JUSTGREP"

############  JSON UTIL  ############

# jq json processing
[no-exit-message]
jq1 *args:
  jq {{args}}

# jq.node json processing
[no-exit-message]
jq2 *args:
  jqn {{args}}

# yq: jq-like for yaml, json, xml, properties, csv and tsv
[no-exit-message]
yaml *args:
  yq {{args}}

# CLI output to json
[no-exit-message]
toj *args:
  jc {{args}}

# jid: json interactive digger
[no-exit-message]
jd *args:
  jid {{args}}

# fx json viewer
[no-exit-message]
jv *args:
  fx {{args}}

# jnv json navigator
[no-exit-message]
jnav *args:
  jnv {{args}}


