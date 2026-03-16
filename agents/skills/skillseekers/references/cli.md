# Skillseekersweb - Cli

**Pages:** 10

---

## package - Package Skills | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/package

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Package skills for deployment to multiple LLM platforms.

Use for: Claude Code, Claude Desktop, claude.ai

Use for: Google AI Studio, Gemini API

Use for: ChatGPT, OpenAI Assistants API

Use for: Any LLM, offline docs, self-hosting

Make sure you scraped first:

Each platform requires specific format:

Use --target parameter correctly.

**Examples:**

Example 1 (go):
```go
skill-seekers package INPUT_DIR [OPTIONS]
```

Example 2 (go):
```go
# Package for Claude (default)
skill-seekers package output/react/

# Package for specific platform
skill-seekers package output/react/ --target gemini
skill-seekers package output/react/ --target openai
skill-seekers package output/react/ --target markdown

# Package for all platforms
skill-seekers package output/react/ --target claude
skill-seekers package output/react/ --target gemini
skill-seekers package output/react/ --target openai
skill-seekers package output/react/ --target markdown
```

Example 3 (go):
```go
skill-seekers package output/react/
# Creates: output/react.zip
```

Example 4 (go):
```go
skill-seekers package output/react/ --target gemini
# Creates: output/react-gemini.tar.gz
```

---

## upload - Upload Skills | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/upload

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Upload packaged skills to LLM platforms.

Add to shell profile:

Set the appropriate environment variable:

Make sure you packaged first:

If API upload fails, use manual upload:

Each platform requires specific format:

After upload, verify your skill:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers upload PACKAGE_FILE [OPTIONS]
```

Example 2 (lua):
```lua
# Upload to Claude (default)
skill-seekers upload output/react.zip

# Upload to specific platform
skill-seekers upload output/react-gemini.tar.gz --target gemini
skill-seekers upload output/react-openai.zip --target openai

# With explicit target
export ANTHROPIC_API_KEY=sk-ant-...
skill-seekers upload output/react.zip --target claude
```

Example 3 (lua):
```lua
# Set API key (for automatic upload)
export ANTHROPIC_API_KEY=sk-ant-...

# Get key from: https://console.anthropic.com/
```

Example 4 (lua):
```lua
# Install Gemini support
pip install skill-seekers[gemini]

# Set API key
export GOOGLE_API_KEY=AIzaSy...

# Get key from: https://aistudio.google.com/
```

---

## pdf - PDF Extraction | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/pdf

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Extract content from PDF files and convert to AI skills.

For large PDFs, enable parallel processing:

Extract complex tables from PDFs:

Some PDFs use images for tables. Enable OCR:

For very large PDFs, reduce workers:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers pdf [OPTIONS]
```

Example 2 (markdown):
```markdown
# Basic PDF extraction
skill-seekers pdf --pdf docs/manual.pdf --name myskill

# Scanned PDFs with OCR
skill-seekers pdf --pdf docs/scanned.pdf --name myskill --ocr

# Password-protected PDFs
skill-seekers pdf --pdf docs/encrypted.pdf --name myskill --password mypassword

# Advanced features
skill-seekers pdf --pdf docs/manual.pdf --name myskill \
    --extract-tables \
    --parallel \
    --workers 8
```

Example 3 (markdown):
```markdown
# Install OCR dependencies
pip install pytesseract Pillow

# Install Tesseract OCR engine
# macOS
brew install tesseract

# Linux
sudo apt install tesseract-ocr

# Windows
# Download from: https://github.com/UB-Mannheim/tesseract/wiki
```

Example 4 (unknown):
```unknown
skill-seekers pdf --pdf scanned_manual.pdf --name myskill --ocr
```

---

## CLI Overview | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/overview

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Skill Seekers provides a comprehensive command-line interface for creating, enhancing, and deploying AI skills across multiple platforms.

Extract content from various sources:

Transform and package skills:

Most commands support these options:

New in v2.7.0: Interactive configuration wizard and job resumption.

Auto-resume features:

Configuration (v2.7.0):

**Examples:**

Example 1 (go):
```go
# 1. Scrape documentation
skill-seekers scrape --config configs/react.json

# 2. Enhance with AI
skill-seekers enhance output/react/

# 3. Package for platform
skill-seekers package output/react/ --target claude

# 4. Upload to platform
skill-seekers upload output/react.zip
```

Example 2 (go):
```go
# Scrape once
skill-seekers scrape --config configs/react.json

# Package for all platforms
skill-seekers package output/react/ --target claude
skill-seekers package output/react/ --target gemini
skill-seekers package output/react/ --target openai
skill-seekers package output/react/ --target markdown

# Upload to platforms
skill-seekers upload output/react.zip --target claude
skill-seekers upload output/react-gemini.tar.gz --target gemini
skill-seekers upload output/react-openai.zip --target openai
```

Example 3 (markdown):
```markdown
# Interactive wizard for multi-profile token management
skill-seekers config --github

# Set up multiple profiles (personal, work, etc.)
# Configure rate limit strategies (prompt, wait, switch, fail)
# Test connections and view rate limits
```

Example 4 (markdown):
```markdown
# Set up API keys for AI enhancement
skill-seekers config --api-keys

# Supported: Claude (Anthropic), Google Gemini, OpenAI ChatGPT
# Browser integration opens API key creation pages
# Secure storage with 600 permissions
```

---

## github - Repository Scraping | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/github

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Scrape GitHub repositories and analyze code with deep AST parsing.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers github [OPTIONS]
```

Example 2 (sass):
```sass
# Basic repository scraping
skill-seekers github --repo facebook/react

# Using a config file
skill-seekers github --config configs/react_github.json

# With authentication (higher rate limits)
export GITHUB_TOKEN=ghp_your_token_here
skill-seekers github --repo facebook/react

# Include issues and changelog
skill-seekers github --repo django/django \
    --include-issues \
    --max-issues 100 \
    --include-changelog \
    --include-releases
```

Example 3 (sass):
```sass
# Set GitHub token for higher rate limits
export GITHUB_TOKEN=ghp_your_token_here
```

Example 4 (unknown):
```unknown
skill-seekers github --repo facebook/react --code-analysis-depth surface
```

---

## scrape - Documentation Scraping | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/scrape

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Scrape documentation websites and convert them into AI skills.

Skill Seekers includes 24+ ready-to-use configurations:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape [OPTIONS]
```

Example 2 (elixir):
```elixir
# Use preset config (easiest)
skill-seekers scrape --config configs/react.json

# Quick scrape without config
skill-seekers scrape --url https://react.dev --name react

# Interactive mode
skill-seekers scrape --interactive

# With async mode (3x faster)
skill-seekers scrape --config configs/godot.json --async --workers 8
```

Example 3 (lua):
```lua
# Game Engines
skill-seekers scrape --config configs/godot.json
skill-seekers scrape --config configs/unity.json

# Web Frameworks
skill-seekers scrape --config configs/react.json
skill-seekers scrape --config configs/vue.json
skill-seekers scrape --config configs/django.json
skill-seekers scrape --config configs/fastapi.json

# And 18+ more...
```

Example 4 (lua):
```lua
output/
├── {name}_data/              # Cached scraped data
│   ├── pages/
│   │   ├── page_0.json
│   │   └── ...
│   └── summary.json
│
└── {name}/                   # Built skill
    ├── SKILL.md             # Main skill file
    ├── references/          # Categorized docs
    │   ├── index.md
    │   ├── getting_started.md
    │   ├── api.md
    │   └── ...
    ├── scripts/
    └── assets/
```

---

## unified - Multi-Source Scraping | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/unified

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Combine multiple sources (docs + GitHub + PDF) into one unified skill with conflict detection.

The Problem: Documentation and code often drift apart. Docs might be outdated, missing features, or documenting removed features.

The Solution: Unified scraping combines multiple sources and automatically detects conflicts.

New in v2.6.0 - GitHub repos are split into three streams:

Unified scraping automatically detects 4 types of conflicts:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers unified [OPTIONS]
```

Example 2 (elixir):
```elixir
# Use existing unified configs
skill-seekers unified --config configs/react_unified.json
skill-seekers unified --config configs/django_unified.json
skill-seekers unified --config configs/fastapi_unified.json

# Analyze GitHub repo with three-stream architecture
skill-seekers unified \
    --repo-url https://github.com/facebook/react \
    --depth c3x \
    --fetch-github-metadata
```

Example 3 (unknown):
```unknown
skill-seekers unified \
    --repo-url https://github.com/fastapi/fastapi \
    --depth c3x \
    --fetch-github-metadata \
    --output-dir output/fastapi
```

Example 4 (json):
```json
{
  "name": "myframework",
  "description": "Complete framework knowledge from docs + code",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://docs.myframework.com/",
      "extract_api": true,
      "max_pages": 200
    },
    {
      "type": "github",
      "repo": "owner/myframework",
      "include_code": true,
      "code_analysis_depth": "deep"
    },
    {
      "type": "pdf",
      "pdf_path": "docs/manual.pdf",
      "extract_tables": true
    }
  ]
}
```

---

## resume - Resume Interrupted Jobs | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/resume

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Resume interrupted scraping jobs from saved checkpoints and manage job history.

Skill Seekers automatically saves progress for resumable operations:

Auto-saved operations:

Shows additional details:

If a GitHub scraping job hit rate limits:

Configured in skill-seekers config:

Warning: This deletes ALL resumable jobs, including recent ones.

Problem: Internet disconnected during documentation scraping

Result: Resumes from page 450, skips already-scraped pages

Problem: GitHub API rate limit exceeded during repository analysis

Result: Continues analysis from last checkpoint

Problem: Computer crashed during unified scraping

Result: Resumes from last auto-save (default: 60 seconds)

Problem: Accidentally canceled long-running job

Result: Picks up where it left off

While running, resumed jobs show progress:

Configure resume behavior in skill-seekers config:

These operations cannot be resumed:

These operations resume with limitations:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers resume [OPTIONS] [JOB_ID]
```

Example 2 (markdown):
```markdown
# List all resumable jobs
skill-seekers resume --list

# Resume specific job by ID
skill-seekers resume abc123def456

# Clean up old job files
skill-seekers resume --clean

# View job details
skill-seekers resume --list --verbose
```

Example 3 (unknown):
```unknown
~/.local/share/skill-seekers/progress/<job-id>.json
```

Example 4 (json):
```json
{
  "job_id": "abc123def456",
  "command": "skill-seekers github --repo facebook/react",
  "started_at": "2026-01-18T10:30:00Z",
  "last_updated": "2026-01-18T10:45:00Z",
  "progress": {
    "phase": "Code Analysis",
    "files_processed": 1234,
    "files_total": 2000,
    "percent_complete": 61.7
  },
  "checkpoints": {
    "scraping_complete": true,
    "analysis_phase_1": true,
    "analysis_phase_2": false
  },
  "metadata": {
    "repo": "facebook/react",
    "output_dir": "output/react"
  }
}
```

---

## enhance - AI Enhancement | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/enhance

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

AI-enhance skills to improve quality and add comprehensive examples.

React uses a virtual representation of the DOM to optimize rendering performance…

Enhancement creates backups:

Costs vary based on skill size and quality level

Make sure Claude Code is running:

Or use local mode (usually faster):

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers enhance INPUT_DIR [OPTIONS]
```

Example 2 (lua):
```lua
# Local enhancement (free, uses Claude Code)
skill-seekers enhance output/react/

# API enhancement (requires API key)
export ANTHROPIC_API_KEY=sk-ant-...
skill-seekers enhance output/react/ --api

# With specific provider
skill-seekers enhance output/react/ --provider anthropic --mode api
skill-seekers enhance output/react/ --provider google --mode api
skill-seekers enhance output/react/ --provider openai --mode api
```

Example 3 (unknown):
```unknown
skill-seekers enhance output/react/
```

Example 4 (lua):
```lua
export ANTHROPIC_API_KEY=sk-ant-...
skill-seekers enhance output/react/ --mode api
```

---

## config - Configuration Management | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/cli/config

**Contents:**
- Documentation
  - About
  - Getting Started
  - Tutorials
  - Manual
    - Scraping
    - Enhancement
    - MCP
    - Platforms
    - Advanced

Interactive wizard for managing Skill Seekers configuration including GitHub tokens, API keys, and system settings.

The main configuration menu provides 7 options:

Manage multiple GitHub profiles for flexible token management:

Rate Limit Strategies:

Set up API keys for AI enhancement:

Configure rate limit behavior:

Configure resumable job preferences:

Display all current settings:

Verify all configured tokens and API keys:

Remove old resumable job files:

Removes progress files older than configured cleanup age (default: 7 days).

Permissions: 600 (read/write for owner only)

If not in config file, Skill Seekers checks these environment variables:

Skill Seekers accepts these GitHub token formats:

Without token: 60 requests/hour With token: 5000 requests/hour

The configuration wizard shows an upfront warning if no token is configured.

When a profile hits rate limits:

On first installation, Skill Seekers shows a welcome message with setup options:

Stored at: ~/.config/skill-seekers/.setup_shown

The interactive menu provides real-time connection testing for each service.

For automated pipelines, use environment variables instead of interactive config:

Non-interactive mode:

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers config [OPTIONS]
```

Example 2 (markdown):
```markdown
# Launch interactive configuration menu
skill-seekers config

# Direct to GitHub token setup
skill-seekers config --github

# Set up API keys
skill-seekers config --api-keys

# View current configuration
skill-seekers config --show

# Test all connections
skill-seekers config --test
```

Example 3 (unknown):
```unknown
skill-seekers config --github
```

Example 4 (unknown):
```unknown
skill-seekers config --api-keys
```

---
