---
name: skill-seekers
description: Use when creating, enhancing, packaging, or deploying AI skills using the skill-seekers CLI
---

# Skill Seekers CLI

Create AI skills from any knowledge source — docs sites, GitHub repos, PDFs, or local codebases.

## Installation

```bash
pip install skill-seekers              # Claude only
pip install skill-seekers[all]         # All platforms (gemini, openai)
uv pip install skill-seekers[all]      # Or via uv
skill-seekers --version                # Verify (expect 3.1.0+)
```

Requires Python 3.10+. Optional: Claude Code for free local enhancement.

## Quick Start

```bash
# One command from any source
skill-seekers create <source> --target claude

# Sources: URL, GitHub URL, PDF path, or local directory
skill-seekers create https://docs.example.com --target claude
skill-seekers create https://github.com/owner/repo --target claude
skill-seekers create ./manual.pdf --target claude
skill-seekers create ./my-project --target claude
```

Targets: `claude` (default), `gemini`, `openai`, `markdown`, `langchain`, `cursor`

## Pipeline Commands

When `create` isn't enough, run the pipeline manually:

| Step | Command | Purpose |
|------|---------|---------|
| 1 | `scrape` | Scrape docs from URL |
| 2 | `github` | Analyze a GitHub repo |
| 3 | `pdf` | Extract from PDF |
| 4 | `unified` | Combine multiple sources |
| 5 | `enhance` | Improve with AI |
| 6 | `package` | Package for platform |
| 7 | `upload` | Upload to platform |

```bash
# Typical full pipeline
skill-seekers scrape --url https://react.dev --name react
skill-seekers enhance output/react/
skill-seekers package output/react/ --target claude
skill-seekers upload output/react.zip
```

## Utility Commands

| Command | Purpose |
|---------|---------|
| `config` | Interactive setup (tokens, API keys) |
| `resume --list` | List/resume interrupted jobs |
| `list-configs` | List 24+ preset scraping configs |
| `estimate --config <file>` | Estimate page count before scraping |
| `validate <config>` | Validate config file |
| `workflows list` | List enhancement workflow presets |
| `router <dirs...>` | Create router skill from sub-skills |

## Reference Files

- **commands.md** — Full command reference with all flags and options
- **config.md** — Configuration schema for unified, docs, GitHub, and PDF sources
- **advanced.md** — MCP setup, large docs strategies, workflow presets, git config sources
