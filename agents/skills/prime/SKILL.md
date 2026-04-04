---
name: prime
description: Prime the conversation with project context by listing tracked files and displaying AGENTS.md if present
---

# Prime

Gather project context at the start of a conversation.

## Instructions

1. Run `git ls-files` to list all tracked files in the repository.
2. Run `cat AGENTS.md 2>/dev/null || true` to display its contents if the file exists, or silently skip if it does not.
