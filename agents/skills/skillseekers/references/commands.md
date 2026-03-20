# Command Reference

## create

Unified command (v3.0+) — auto-detects source type and runs the full pipeline.

```bash
skill-seekers create <source> --target <platform> [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `--target` | Platform: `claude`, `gemini`, `openai`, `markdown`, `langchain`, `cursor` |
| `--max-pages N` | Limit pages scraped |
| `--enhance-workflow <name>` | Apply workflow preset (repeatable) |

## scrape

Scrape documentation websites.

```bash
skill-seekers scrape --url <url> --name <name>       # Quick mode
skill-seekers scrape --config configs/<name>.json     # Preset config
skill-seekers scrape --interactive                    # Interactive mode
skill-seekers scrape --config <file> --async --workers 8  # Fast async
```

| Option | Description |
|--------|-------------|
| `--url` | URL to scrape |
| `--name` | Output name |
| `--config` | Preset or custom config file |
| `--async` | Enable async scraping (~3x faster) |
| `--workers N` | Parallel workers (default: 4) |
| `--interactive` | Interactive CSS selector testing |
| `--prefer-llms-txt` | Force llms.txt usage (10x faster when available) |
| `--no-llms-txt` | Skip llms.txt, force web scraping |
| `--incremental` | Only scrape changed pages |
| `--checkpoint` | Enable resume on interruption |
| `--auto-split` | Split large docs automatically |
| `--max-tokens N` | Max tokens per split |

24+ preset configs: react, vue, django, fastapi, godot, unity, and more. List with `skill-seekers list-configs`.

Auto-detects `llms-full.txt` > `llms.txt` > standard scraping.

### Output Structure

```
output/
├── {name}_data/          # Cached scraped data
│   ├── pages/
│   └── summary.json
└── {name}/               # Built skill
    ├── SKILL.md
    ├── references/
    ├── scripts/
    └── assets/
```

## github

Analyze a GitHub repository.

```bash
skill-seekers github --repo <owner/repo> [OPTIONS]
skill-seekers github --config configs/<name>_github.json
```

| Option | Description |
|--------|-------------|
| `--repo` | Repository (owner/name) |
| `--include-issues` | Include GitHub issues |
| `--max-issues N` | Max issues (100 recommended, >200 rarely adds value) |
| `--include-changelog` | Extract CHANGELOG.md |
| `--include-releases` | Include releases |
| `--code-analysis-depth` | `surface` (fast), `deep`, `full` |

Set `GITHUB_TOKEN` for 5000 req/hr (vs 60 unauthenticated). Accepted formats: `ghp_*`, `github_pat_*`, `gho_*`.

## pdf

Extract content from PDF files.

```bash
skill-seekers pdf --input <file> --output <dir> [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `--ocr` | Enable OCR for scanned PDFs |
| `--password <pw>` | Decrypt protected PDF |
| `--extract-tables` | Extract tables as structured data |
| `--parallel` | Parallel processing (auto for >5 pages) |
| `--workers N` | Number of workers |

OCR requires: `pip install pytesseract Pillow` + Tesseract (`brew install tesseract` / `apt install tesseract-ocr`).

## unified

Combine docs + GitHub + PDF into one skill with conflict detection.

```bash
skill-seekers unified --config <file>
skill-seekers unified --config <file> --output-dir <dir>
```

Detects 4 conflict types: undocumented API (medium), deprecated API (high), signature mismatch (medium-high), description conflict (low). Conflicts written to `references/conflicts.md` in the output skill.

Merge modes: `rule-based` (default, fast) or `claude-enhanced` (AI-powered).

## enhance

AI enhancement of scraped skills.

```bash
skill-seekers enhance <dir>                          # Local (free, Claude Code)
skill-seekers enhance <dir> --mode api               # API (needs ANTHROPIC_API_KEY)
skill-seekers enhance <dir> --provider google --mode api  # Gemini
skill-seekers enhance <dir> --background             # Non-blocking
skill-seekers enhance <dir> --daemon                 # Survives terminal close
skill-seekers enhance <dir> --timeout 1200           # Custom timeout (default: 600s)
skill-seekers enhance-status <dir> --watch           # Check progress
```

| Mode | Cost | Model |
|------|------|-------|
| Local (default) | Free | Claude Code (Max subscription) |
| API - anthropic | Paid | Claude Sonnet 4 |
| API - google | Paid | Gemini 2.0 Flash |
| API - openai | Paid | GPT-4o |

Creates backups before modifying. Force mode ON by default (no confirmations).

## package

Package a skill for a target platform.

```bash
skill-seekers package <dir> --target <platform>
skill-seekers package <dir> --target claude --include-subskills
```

Output formats: Claude → `.zip`, Gemini → `.tar.gz`, OpenAI → `.zip`, Markdown → directory.

## upload

Upload packaged skill to a platform.

```bash
skill-seekers upload <file> --target <platform>
```

Requires platform API key: `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`, or `OPENAI_API_KEY`.

## config

Interactive configuration management.

```bash
skill-seekers config              # Main menu
skill-seekers config --github     # GitHub token setup (multi-profile)
skill-seekers config --api-keys   # API key management
skill-seekers config --show       # View current config
skill-seekers config --test       # Test all connections
```

Config stored at `~/.config/skill-seekers/config.json` (permissions: 600).

Rate limit strategies for GitHub: `prompt` | `wait` | `switch` (profile) | `fail`.

Env var fallbacks: `GITHUB_TOKEN`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`, `OPENAI_API_KEY`.

## resume

Resume interrupted scrape/github/unified jobs. Auto-saves progress.

```bash
skill-seekers resume --list              # List resumable jobs
skill-seekers resume --list --verbose    # With details
skill-seekers resume <job-id>            # Resume specific job
skill-seekers resume --clean             # Clean old progress files
```

Progress stored at `~/.local/share/skill-seekers/progress/<job-id>.json`.

Not resumable: `enhance`, `package`, `upload`. Partial resume: `unified` (enhancement stage only).
