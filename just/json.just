set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

default:
  @just --justfile "$JUST/json.just" --list | zsh -c "$JUSTGREP"

############  JSON UTIL  ############

# jq json processing
jq1 *args:
  jq {{args}}

# jq.node json processing
jq2 *args:
  jqn {{args}}

# yq: jq-like for yaml, json, xml, properties, csv and tsv
yaml *args:
  yq {{args}}

# CLI output to json
toj *args:
  jc {{args}}

# jid: json interactive digger
jd *args:
  jid {{args}}

# fx json viewer
jv *args:
  fx {{args}}

# jnv json navigator
jnav *args:
  jnv {{args}}


