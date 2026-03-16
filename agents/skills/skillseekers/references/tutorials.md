# Skillseekersweb - Tutorials

**Pages:** 9

---

## Tutorial: Scraping Documentation | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/tutorials/scraping-docs

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

Learn how to scrape any documentation website and create an AI skill in this hands-on tutorial.

Time: 15 minutes | Level: Beginner | Result: Working React docs skill

For this tutorial, we’ll scrape React documentation. Skill Seekers includes 24 preset configs for popular frameworks.

View available presets:

Before scraping, estimate how many pages will be processed:

Run the scraper with the React preset:

Check what was created:

Transform the skill from basic (3/10) to comprehensive (9/10) using AI:

Option A: Local Enhancement (FREE with Claude Max)

This opens Claude Code in a new terminal and enhances the skill using your Claude Max subscription (no API costs!).

Option B: API Enhancement (Fast)

Package for your preferred platform:

Automatic Upload (Recommended):

Try these prompts in Claude:

Result: Claude responds with accurate, context-aware answers based on official React documentation!

Solution: Check your config selectors:

Interactive mode shows extracted content and lets you test selectors.

You just created your first AI skill! 🎉

Time investment: 15 minutes Result: Professional-quality AI skill ready to use!

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers list-configs
```

Example 2 (lua):
```lua
Available configs:
- react.json        (React documentation)
- vue.json          (Vue.js documentation)
- django.json       (Django framework)
- godot.json        (Godot game engine)
- fastapi.json      (FastAPI framework)
... and 19 more
```

Example 3 (unknown):
```unknown
skill-seekers estimate --config configs/react.json
```

Example 4 (json):
```json
📊 Estimation Results:
Base URL: https://react.dev/learn
Estimated pages: ~180 pages
Estimated time: 3-5 minutes
Categories detected: 4
```

---

## Multi-Agent Setup | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/guides/multi-agent

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

Configure Skill Seekers with Claude, Copilot, Codex, and custom agents.

**Examples:**

Example 1 (markdown):
```markdown
# Already installed with MCP
skill-seekers enhance output/react/ --agent claude
```

Example 2 (elixir):
```elixir
# Install Copilot CLI
gh extension install github/copilot

# Use with Skill Seekers
skill-seekers enhance output/react/ --agent copilot
```

Example 3 (lua):
```lua
# Set API key
export OPENAI_API_KEY=sk-...

# Use Codex
skill-seekers enhance output/react/ --agent codex
```

Example 4 (swift):
```swift
# Any CLI tool
skill-seekers enhance output/react/ \
  --agent custom \
  --agent-cmd "my-ai-tool {prompt_file}"
```

---

## Tutorial: Analyzing GitHub Repositories | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/tutorials/analyzing-github

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

Learn how to analyze GitHub repositories and generate comprehensive codebase documentation with C3.x analysis.

Time: 20 minutes | Level: Intermediate | Result: Complete codebase skill with patterns, examples, and architecture

See: GitHub Analysis Manual for complete details.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers github \
  --repository facebook/react \
  --output output/react-repo/
```

Example 2 (markdown):
```markdown
# Clone repo locally first
git clone https://github.com/facebook/react.git /tmp/react

# Analyze with C3.x features
skill-seekers github \
  --repository facebook/react \
  --local-repo-path /tmp/react \
  --output output/react-complete/
```

Example 3 (unknown):
```unknown
output/react-complete/
├── SKILL.md
├── ARCHITECTURE.md              # NEW: Comprehensive overview
├── references/
│   ├── api_reference.md
│   ├── dependencies.md
│   └── codebase_analysis/
│       ├── patterns/            # Design patterns detected
│       ├── examples/            # Test examples extracted
│       ├── guides/              # How-to tutorials generated
│       └── configuration/       # Config files analyzed
```

---

## How to Submit a Config | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/guides/submit-config

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

Learn how to validate and submit your custom configuration files to the official Skill Seekers config repository.

The Skill Seekers community welcomes configuration contributions for any framework, library, or documentation site. Your configs help other developers quickly create AI skills for their tools.

Create a config file using the unified format:

Before submitting, test your config locally:

Visit skillseekersweb.com/configs and scroll to the validator:

The validator checks:

Once validated, there are two submission methods:

If automatic submission doesn’t work:

Automated Checks (5 minutes)

Manual Review (24-48 hours)

Your config will be approved if it:

✅ Validates without errors ✅ Scrapes successfully ✅ Extracts meaningful content ✅ Follows naming conventions ✅ Doesn’t duplicate existing configs ✅ Has accurate selectors ✅ Respects rate limits

Common Rejection Reasons: ❌ Invalid JSON syntax ❌ Missing required fields ❌ Incorrect selectors (no content extracted) ❌ Duplicate of existing config ❌ Rate limit too aggressive ❌ Broken or inaccessible URLs

Configs are organized into categories in the gallery:

React, Vue, Angular, Svelte, Astro, etc.

Django, FastAPI, Express, Laravel, Rails, etc.

Godot, Unity, Unreal, etc.

Kubernetes, Docker, Ansible, Terraform, etc.

Git, VS Code, Claude Code, etc.

React Native, Flutter, Ionic, etc.

TensorFlow, PyTorch, Pandas, etc.

Jest, Pytest, Cypress, Playwright, etc.

Where does your config fit? Mention the category in your submission for faster processing.

When submitting configs with multiple sources:

Explain in submission:

For private documentation or internal tools:

We’ll approve the structure even if we can’t test the scraping.

For sites with 500+ pages:

Browse 27+ preset configs for inspiration:

Contributors are recognized in:

Top contributors get:

Before submitting, ensure:

Questions? Open a GitHub Discussion or Issue.

**Examples:**

Example 1 (json):
```json
{
  "name": "your-framework",
  "description": "Complete framework knowledge combining docs and codebase.",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://docs.yourframework.com",
      "selectors": {
        "main_content": "article",
        "title": "h1",
        "code_blocks": "pre code"
      },
      "rate_limit": 0.5,
      "max_pages": 200
    }
  ]
}
```

Example 2 (markdown):
```markdown
# Validate the config structure
skill-seekers validate configs/your-framework.json

# Test scraping
skill-seekers scrape configs/your-framework.json

# Check the output
ls output/your-framework/
```

Example 3 (json):
```json
{
  "name": "advanced-framework",
  "description": "Complete knowledge from docs, GitHub, and PDF manual.",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://docs.framework.com"
    },
    {
      "type": "github",
      "repo": "company/framework",
      "enable_codebase_analysis": true,
      "code_analysis_depth": "deep"
    },
    {
      "type": "pdf",
      "path": "https://framework.com/manual.pdf"
    }
  ]
}
```

Example 4 (json):
```json
{
  "max_pages": 500,
  "rate_limit": 1.0,
  "url_patterns": {
    "include": ["/getting-started/", "/api/", "/guides/"],
    "exclude": ["/blog/", "/changelog/", "/community/"]
  }
}
```

---

## Tutorial: Multi-Source Skills | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/tutorials/multi-source-skills

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

Learn how to combine multiple sources (docs + GitHub + PDFs) into one comprehensive skill.

Time: 25 minutes | Level: Advanced | Result: Unified skill with complete knowledge

Problem: Documentation alone doesn’t show real usage. Code alone doesn’t explain concepts. PDFs have specs but no examples.

Solution: Combine all sources into one skill!

Skill Seekers automatically detects and resolves duplicate content:

Result: Complete Django knowledge - concepts, examples, patterns, and specifications - all in one skill!

See: Unified Scraping Manual for advanced techniques.

**Examples:**

Example 1 (json):
```json
{
  "name": "django-complete",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://docs.djangoproject.com/en/stable/",
      "max_pages": 500,
      "priority": 1
    },
    {
      "type": "github",
      "repository": "django/django",
      "local_repo_path": "/path/to/django",
      "include_issues": true,
      "priority": 2
    },
    {
      "type": "pdf",
      "directory": "/path/to/django-books/",
      "priority": 3
    }
  ],
  "conflict_resolution": "priority"
}
```

Example 2 (unknown):
```unknown
skill-seekers unified \
  --config configs/django-complete.json \
  --output output/django-unified/
```

Example 3 (json):
```json
⚠️ Conflict Detection Report:
- 23 duplicate pages found
- 18 resolved by priority
- 5 merged (complementary content)
✅ Final skill: 892 unique pages
```

Example 4 (go):
```go
# Enhance
skill-seekers enhance output/django-unified/

# Package
skill-seekers package output/django-unified/ --target claude
```

---

## Troubleshooting Guide | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/guides/troubleshooting

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

Common issues and solutions when using Skill Seeker.

Check if Python is installed:

Use python instead of python3:

Install dependencies:

Use —user flag if permission denied:

Check pip is working:

Use sudo (not recommended):

Use virtual environment (best practice):

Check you’re in the Skill_Seekers directory:

Change to the correct directory:

Create missing config:

Check configuration file:

Verify paths are ABSOLUTE (not placeholders):

❌ Bad: $REPO_PATH or /path/to/Skill_Seekers ✅ Good: /Users/john/Projects/Skill_Seekers

Test server manually:

RESTART Claude Code completely:

Problem: Config has $REPO_PATH or /Users/username/ instead of real paths

Check working directory:

Test CLI tools directly:

Check network connection:

Use smaller max_pages for testing:

Increase rate_limit in config:

Problem: Pages scraped but content is empty

Check selector in config:

Verify website is accessible:

Try different selectors:

Issue: Can’t run ./setup_mcp.sh

Issue: Homebrew not installed

Issue: pip3 not found

Issue: Permission errors

Issue: Python not in PATH

Issue: Line ending errors

Use these to check your setup:

If none of these solutions work:

Check existing issues: https://github.com/yusufkaraaslan/Skill_Seekers/issues

Open a new issue with:

Include this debug info:

Still stuck? Open an issue: https://github.com/yusufkaraaslan/Skill_Seekers/issues/new

**Examples:**

Example 1 (yaml):
```yaml
python3: command not found
```

Example 2 (unknown):
```unknown
which python3
python --version  # Try without the 3
```

Example 3 (unknown):
```unknown
python cli/doc_scraper.py --help
```

Example 4 (julia):
```julia
ModuleNotFoundError: No module named 'requests'
ModuleNotFoundError: No module named 'bs4'
ModuleNotFoundError: No module named 'mcp'
```

---

## Tutorial: Extracting PDFs | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/tutorials/extracting-pdfs

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

Learn how to extract technical documentation from PDFs and create searchable AI skills.

Time: 10 minutes | Level: Beginner | Result: PDF-based skill

See: PDF Scraping Manual for complete guide.

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers pdf \
  --input /path/to/manual.pdf \
  --output output/manual/
```

Example 2 (markdown):
```markdown
# Install Tesseract first
# Ubuntu: sudo apt-get install tesseract-ocr
# macOS: brew install tesseract

skill-seekers pdf \
  --input /path/to/scanned.pdf \
  --output output/scanned/ \
  --ocr
```

Example 3 (unknown):
```unknown
skill-seekers pdf \
  --input /path/to/encrypted.pdf \
  --output output/encrypted/ \
  --password "your-password"
```

Example 4 (unknown):
```unknown
skill-seekers pdf \
  --input /path/to/spec.pdf \
  --output output/spec/ \
  --extract-tables
```

---

## Tutorial: Creating Custom Configs | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/tutorials/creating-configs

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

Learn how to create custom configuration files for documentation websites not covered by presets.

Time: 15-30 minutes | Level: Intermediate | Result: Working custom config

While Skill Seekers includes 24 preset configs for popular frameworks, you’ll often need to scrape documentation for:

Benefits of custom configs:

The easiest way to create a config is using interactive mode:

Step-by-step process:

The scraper will suggest CSS selectors. Test and refine:

Common selectors by documentation platform:

Review a sample page:

✅ Content looks good!

🔗 URL Patterns (regex):

💾 Save configuration:

Config name: my-framework Save to: configs/my-framework.json

Before full scraping, estimate the scope:

Scrape a small subset to verify:

Incorrect URL patterns

Too restrictive exclude patterns

Content selector not matching

Use more specific selectors:

Here’s a real-world example for an internal framework:

Need help? Open an issue: https://github.com/yusufkaraaslan/Skill_Seekers/issues

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers scrape --interactive
```

Example 2 (unknown):
```unknown
📍 Enter the documentation base URL:
→ https://docs.my-framework.com/
```

Example 3 (json):
```json
🎯 Testing selectors on https://docs.my-framework.com/guide/intro

Suggested content selector: "article.main-content"
✅ Found: Main article content
✅ Length: 2,450 characters
✅ Code blocks: 3 detected

Is this correct? (y/n/custom)
→ y
```

Example 4 (lua):
```lua
📄 Preview extracted content:

Title: Getting Started
Content preview:
━━━━━━━━━━━━━━━━━━━━
# Getting Started

MyFramework is a powerful tool for...

## Installation

```bash
npm install my-framework
```

---

## Migration Guide | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/guides/migration

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

Migrate from v2.x to v3.0.0.

v3.0.0 is backward compatible for basic usage. All v2.x configs and commands work unchanged.

None! v3.0.0 only adds features.

**Examples:**

Example 1 (unknown):
```unknown
pip install --upgrade skill-seekers
```

Example 2 (markdown):
```markdown
skill-seekers --version
# Should show 3.0.0
```

Example 3 (markdown):
```markdown
# Your v2.x configs still work
skill-seekers scrape --config configs/react.json
```

Example 4 (markdown):
```markdown
# New in v3.0.0
skill-seekers analyze --directory ./my-project --format langchain
```

---
