# Skillseekersweb - Manual

**Pages:** 13

---

## Overview | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/platforms/multi-llm-support

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

Available since v2.5.0

Skill Seekers supports 4 LLM platforms out of the box. Scrape documentation once, deploy everywhere.

Claude AI is the default and most feature-rich platform.

Google Gemini support with tar.gz format.

OpenAI ChatGPT with vector store integration.

Universal markdown export for any platform.

Each platform uses its default enhancement model, but you can customize:

Check which platforms are available:

You can create custom packaging for your own platform:

Register your strategy:

Best choice: Claude AI or Gemini

Why: Long context (2M tokens), lower cost

Best choice: Claude AI

Why: Best code understanding, GitHub integration

Why: Vector store, semantic search built-in

Best choice: Generic Markdown

Why: No API keys, full control, git-friendly

100% backward compatible with existing workflows:

Error: ModuleNotFoundError: No module named 'google.generativeai'

Error: ModuleNotFoundError: No module named 'openai'

Error: Invalid API key format

Solution: Check your API key format:

Set environment variable:

Error: Not a tar.gz file: react.zip

Solution: Use correct —target flag:

Check API key is valid:

Check target matches:

Q: Can I use the same scraped data for all platforms?

A: Yes! The scraping phase is universal. Only packaging and upload are platform-specific.

Q: Do I need separate API keys for each platform?

A: Yes, each platform requires its own API key. Set them as environment variables.

Q: Can I enhance with different models?

A: Yes, each platform uses its own enhancement model:

Q: What if I don’t want to upload automatically?

A: Use the package command without upload. You’ll get the packaged file to upload manually.

Q: Is the markdown export compatible with all LLMs?

A: Yes! The generic markdown export creates universal documentation that works with any LLM or documentation system.

**Examples:**

Example 1 (markdown):
```markdown
# Default installation (Claude support only)
pip install skill-seekers
```

Example 2 (markdown):
```markdown
# Google Gemini support
pip install skill-seekers[gemini]

# OpenAI ChatGPT support
pip install skill-seekers[openai]

# All LLM platforms
pip install skill-seekers[all-llms]

# Development dependencies (includes testing)
pip install skill-seekers[dev]
```

Example 3 (markdown):
```markdown
git clone https://github.com/yusufkaraaslan/Skill_Seekers.git
cd Skill_Seekers

# Editable install with all platforms
pip install -e .[all-llms]
```

Example 4 (markdown):
```markdown
# Claude support is included by default
pip install skill-seekers
```

---

## MCP Setup | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/mcp/setup

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

Set up the Skill Seekers MCP server to use all features through Model Context Protocol with Claude Code and other AI coding agents.

The Skill Seekers MCP server provides 18 tools accessible through the Model Context Protocol, enabling natural language interaction with all Skill Seekers features.

The script automatically:

Note: Paths shown are for macOS. Linux and Windows paths detected automatically.

If you prefer manual setup or the script doesn’t work:

Edit ~/Library/Application Support/Claude/mcp.json:

Edit ~/Library/Application Support/Cursor/mcp_settings.json:

Note: For HTTP-based agents, start the server first:

Best for: Claude Code, VS Code + Cline

Best for: Cursor, Windsurf, IntelliJ IDEA

When running in HTTP mode:

generate_config - Generate config for any documentation site

list_configs - List all available preset configurations

validate_config - Validate config file structure

estimate_pages - Estimate page count before scraping

scrape_docs - Scrape documentation and build skill

scrape_github - Scrape GitHub repositories

scrape_pdf - Extract content from PDF files

package_skill - Package skill for platform

upload_skill - Upload to LLM platform

enhance_skill - AI-enhance SKILL.md

install_skill - Complete install workflow

fetch_config - Fetch configs from sources

submit_config - Submit new configs

add_config_source - Register private git repositories

list_config_sources - List all registered sources

remove_config_source - Remove registered sources

split_config - Split large documentation configs

generate_router - Generate router/hub skills

In Claude Code, tools appear in the tool use panel when relevant. You can also ask:

The setup script detects all installed agents:

Problem: MCP tools don’t show up in Claude Code

Problem: HTTP server fails to start

Problem: Can’t write to config file

Problem: ModuleNotFoundError: No module named 'mcp'

Problem: Setup script doesn’t detect your agent

Update agent configs to use new port:

Run multiple servers on different ports:

**Examples:**

Example 1 (markdown):
```markdown
# Clone repository
git clone https://github.com/yusufkaraaslan/Skill_Seekers.git
cd Skill_Seekers

# Run setup script
./setup_mcp.sh
```

Example 2 (markdown):
```markdown
# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install Skill Seekers with MCP support
pip install -e ".[mcp]"

# Or install MCP dependencies separately
pip install mcp anthropic-mcp fastmcp
```

Example 3 (lua):
```lua
# Test stdio mode (default)
python -m skill_seekers.mcp.server_fastmcp

# Should show:
# MCP Server running in stdio mode
# Connected to client...
# (Press Ctrl+C to exit)

# Test HTTP mode
python -m skill_seekers.mcp.server_fastmcp --http --port 3000

# Should show:
# MCP Server running in HTTP mode on http://localhost:3000
# Health check: http://localhost:3000/health
# SSE endpoint: http://localhost:3000/sse
```

Example 4 (json):
```json
{
  "mcpServers": {
    "skill-seeker": {
      "command": "python",
      "args": ["-m", "skill_seekers.mcp.server_fastmcp"]
    }
  }
}
```

---

## MCP Tools Reference | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/mcp/tools

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

Skill Seekers provides 26 MCP (Model Context Protocol) tools for Claude Code Desktop and other AI agents. These tools enable natural language commands for skill creation, codebase analysis, and knowledge management.

MCP tools allow AI agents to:

All tools work across 5 AI agent platforms: Claude Code, Cursor, Windsurf, VS Code, and IntelliJ.

Tools for creating skills from various sources:

C3.x codebase analysis capabilities:

AI-powered skill improvements:

Platform-specific packaging:

Management and utilities:

Scrape documentation websites into structured skills.

Returns: Path to created skill directory

Analyze GitHub repositories for code patterns and structure.

Returns: Path to created skill directory

Full C3.x analysis suite for local codebases.

Returns: Analysis results with patterns, tests, and guides

AI-enhance skill content for better quality.

Returns: Enhanced skill path

Package skill for Claude AI platform.

Returns: Packaged skill ready for upload

Estimate time and cost before running.

Returns: Time estimate and cost breakdown

**Examples:**

Example 1 (json):
```json
{
  "url": "https://react.dev",
  "max_pages": 100,
  "selectors": { "content": "article" },
  "output_dir": "./output/react"
}
```

Example 2 (json):
```json
{
  "repo": "facebook/react",
  "include_issues": false,
  "include_tests": true,
  "output_dir": "./output/react-github"
}
```

Example 3 (json):
```json
{
  "directory": "./my-project",
  "comprehensive": true,
  "output_format": "claude"
}
```

Example 4 (json):
```json
{
  "skill_path": "./output/react",
  "method": "local",
  "platform": "claude"
}
```

---

## Google Gemini | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/platforms/gemini

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

Complete guide for creating and deploying skills to Google Gemini using Skill Seekers.

Skill Seekers packages documentation into Gemini-compatible formats optimized for:

Result: output/react/ skill directory with references

Time: 20-40 seconds Cost: ~$0.01-0.05 (using Gemini 2.0 Flash) Quality boost: 3/10 → 9/10

Access your uploaded files in Google AI Studio:

No YAML frontmatter - Gemini uses plain markdown for better compatibility.

Gemini uses .tar.gz compression for better Unix compatibility and smaller file sizes.

Files are uploaded to Google’s Files API and made available for grounding in Gemini responses.

The enhancement process can be customized by modifying the adaptor:

If you want to inspect or modify the package:

Gemini automatically grounds responses in your uploaded documentation files, providing:

Gemini 2.0 Flash supports:

Error: API key doesn’t start with AIza

Error: Wrong package format

Structure your SKILL.md clearly:

After upload, test with sample questions:

Gemini 2.0 Flash pricing:

Typical skill enhancement:

File upload: Free (no per-file charges)

Status: ✅ Production Ready (v2.5.0+)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (markdown):
```markdown
# Install with Gemini dependencies
pip install skill-seekers[gemini]

# Verify installation
pip list | grep google-generativeai
```

Example 2 (lua):
```lua
# Set as environment variable (recommended)
export GOOGLE_API_KEY=AIzaSy...

# Or pass directly to commands
skill-seekers upload --target gemini --api-key AIzaSy...
```

Example 3 (elixir):
```elixir
# Use any config (scraping is platform-agnostic)
skill-seekers scrape --config configs/react.json

# Or use a unified config for multi-source
skill-seekers unified --config configs/react_unified.json
```

Example 4 (lua):
```lua
# Enhance SKILL.md using Gemini 2.0 Flash
skill-seekers enhance output/react/ --target gemini

# With API key specified
skill-seekers enhance output/react/ --target gemini --api-key AIzaSy...
```

---

## Three-Stream GitHub Architecture | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/advanced/three-stream-architecture

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

The Three-Stream Architecture is a revolutionary approach to analyzing GitHub repositories that splits them into three distinct streams: Code, Documentation, and Insights. This provides Claude AI with a complete understanding of any framework or library.

Instead of treating a GitHub repository as a single monolithic source, Skill Seekers now intelligently splits it into three separate streams:

Deep C3.x analysis of the actual codebase:

Time: 20-60 minutes (depending on repo size)

Official documentation from the repository:

Community knowledge from GitHub:

Before (single stream):

After (three streams):

The architecture automatically detects when documentation and code disagree:

Skill Seekers creates hybrid content showing BOTH versions with warnings.

From GitHub issues, Claude learns:

Use for: Quick overview, testing, small projects

Use for: Production skills, comprehensive understanding

Combine documentation websites WITH GitHub analysis:

You get 4 data sources:

With three streams, skills become router-based for better organization:

Analyzing https://github.com/jlowin/fastmcp:

Works with local paths too (no GitHub metadata):

The Three-Stream Architecture has:

**Examples:**

Example 1 (unknown):
```unknown
GitHub Repository
  ↓
Three-Stream Fetcher
  ├─ Stream 1: CODE → C3.x Analysis (patterns, examples)
  ├─ Stream 2: DOCS → README/docs/*.md (official docs)
  └─ Stream 3: INSIGHTS → Common problems + solutions
```

Example 2 (lua):
```lua
# Documentation says:
GoogleProvider(app_id="...", app_secret="...")

# But code actually uses:
GoogleProvider(client_id="...", client_secret="...")
```

Example 3 (markdown):
```markdown
# Analyze a GitHub repo with all three streams
skill-seekers unified \
  --repo-url https://github.com/facebook/react \
  --depth c3x \
  --fetch-github-metadata \
  --output-dir output/react
```

Example 4 (json):
```json
{
  "name": "react",
  "description": "React framework with complete GitHub analysis",
  "sources": [
    {
      "type": "codebase",
      "source": "https://github.com/facebook/react",
      "analysis_depth": "c3x",
      "fetch_github_metadata": true,
      "split_docs": true,
      "max_issues": 100
    }
  ]
}
```

---

## C3.x Codebase Analysis | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/codebase-analysis/c3x-codebase-analysis

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

C3.x is Skill Seekers’ deep codebase analysis system that uses Abstract Syntax Tree (AST) parsing to extract comprehensive knowledge from source code. It goes far beyond simple scraping to understand how code actually works.

C3.x stands for Comprehensive Codebase Context Extraction with 7 analysis modules:

C3.x analyzes code through AST parsing for:

Automatically detects common design patterns in your codebase.

From analyzing fastmcp repository:

Extracts working code examples from test files.

From fastmcp repository:

Generates step-by-step tutorials from code patterns.

Analyzes configuration files to understand setup patterns.

Automatically scans for:

Identifies high-level architecture patterns.

Enable only specific modules:

C3.x uses intelligent caching:

After C3.x analysis, you can enhance with AI:

Use basic mode instead:

Time: 1-2 minutes Gets: File structure, imports, entry points (no C3.x)

**Examples:**

Example 1 (json):
```json
{
  "pattern": "Strategy",
  "confidence": 0.95,
  "location": "src/providers/oauth_provider.py",
  "line_number": 42,
  "context": {
    "interface": "OAuthProvider",
    "implementations": [
      "GoogleProvider",
      "AzureProvider",
      "GitHubProvider"
    ],
    "usage_count": 206
  },
  "explanation": "Strategy pattern allows runtime selection of OAuth provider implementation"
}
```

Example 2 (json):
```json
{
  "title": "OAuth with Google Provider",
  "source": "tests/test_oauth.py:23-45",
  "language": "python",
  "code": "def test_google_oauth():\n    provider = GoogleProvider(\n        client_id='test-id',\n        client_secret='test-secret',\n        redirect_uri='http://localhost:8000/callback'\n    )\n    \n    auth_url = provider.get_authorization_url()\n    assert 'accounts.google.com' in auth_url",
  "description": "Configure Google OAuth provider with credentials and generate authorization URL",
  "category": "authentication",
  "complexity": "medium",
  "confidence": 0.92
}
```

Example 3 (markdown):
```markdown
# How to Implement OAuth Authentication

## Overview
This guide shows how to add OAuth authentication using the Strategy pattern.

## Prerequisites
- Provider credentials (client_id, client_secret)
- Redirect URI configured

## Step 1: Create Provider Instance
\`\`\`python
from fastmcp import GoogleProvider

provider = GoogleProvider(
    client_id="your-client-id",
    client_secret="your-secret",
    redirect_uri="http://localhost:8000/callback"
)
\`\`\`

## Step 2: Generate Authorization URL
\`\`\`python
auth_url = provider.get_authorization_url()
# Redirect user to auth_url
\`\`\`

## Step 3: Handle Callback
\`\`\`python
token = provider.exchange_code(request.params['code'])
user_info = provider.get_user_info(token)
\`\`\`

## Common Issues
- **Redirect URI mismatch:** Ensure URI matches exactly in provider console
- **Invalid credentials:** Double-check client_id and client_secret
```

Example 4 (json):
```json
{
  "file": "config/settings.json",
  "format": "json",
  "structure": {
    "database": {
      "host": "localhost",
      "port": 5432,
      "name": "myapp_db"
    },
    "oauth": {
      "providers": ["google", "github"],
      "redirect_uri": "/auth/callback"
    }
  },
  "security_issues": [
    {
      "severity": "high",
      "issue": "Hardcoded database password",
      "line": 5,
      "recommendation": "Use environment variables"
    }
  ],
  "best_practices": [
    {
      "category": "security",
      "suggestion": "Add secrets rotation policy"
    }
  ]
}
```

---

## Unified Multi-Source Scraping | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/scraping/unified-scraping

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

Version: 2.0 (Feature complete as of October 2025)

Unified multi-source scraping allows you to combine knowledge from multiple sources into a single comprehensive Claude skill. Instead of choosing between documentation, GitHub repositories, or PDF manuals, you can now extract and intelligently merge information from all of them.

The Problem: Documentation and code often drift apart over time. Official docs might be outdated, missing features that exist in code, or documenting features that have been removed. Separately scraping docs and code creates two incomplete skills.

The Solution: Unified scraping:

Create a config file with multiple sources:

The unified scraper automatically detects 4 types of conflicts:

Severity: Medium Description: API exists in code but is not documented

Suggestion: Add documentation for this API

Severity: High Description: API is documented but not found in codebase

Suggestion: Update documentation to remove this API, or add it to codebase

Severity: Medium-High Description: API exists in both but signatures differ

Suggestion: Update documentation to match actual signature

Severity: Low Description: Different descriptions/docstrings

Fast, deterministic merging using predefined rules:

AI-powered reconciliation using local Claude Code:

The unified scraper creates this structure:

useEffect(callback: () => void, deps: any[])

useEffect(callback: () => void | (() => void), deps?: readonly any[])

The unified scraper is fully integrated with MCP. The scrape_docs tool automatically detects unified vs legacy configs and routes to the appropriate scraper.

Legacy configs still work! The system automatically detects legacy single-source configs and routes to the original doc_scraper.py.

Rule-based is fast and works well for most cases. Only use Claude-enhanced if you need human oversight.

code_analysis_depth: "surface" is usually sufficient. Deep analysis is expensive and rarely needed.

max_issues: 100 is a good default. More than 200 issues rarely adds value.

Always review references/conflicts.md to understand discrepancies between sources.

Solution: Ensure both sources have API extraction enabled

Solution: Review conflicts manually and adjust merge strategy

v2.0 (October 2025): Unified multi-source scraping feature complete

**Examples:**

Example 1 (json):
```json
{
  "name": "react",
  "description": "Complete React knowledge from docs + codebase",
  "merge_mode": "rule-based",
  "sources": [
    {
      "type": "documentation",
      "base_url": "https://react.dev/",
      "extract_api": true,
      "max_pages": 200
    },
    {
      "type": "github",
      "repo": "facebook/react",
      "include_code": true,
      "code_analysis_depth": "surface",
      "max_issues": 100
    }
  ]
}
```

Example 2 (unknown):
```unknown
skill-seekers unified --config configs/react_unified.json
```

Example 3 (go):
```go
skill-seekers package output/react/
```

Example 4 (json):
```json
{
  "name": "skill-name",
  "description": "When to use this skill",
  "merge_mode": "rule-based|claude-enhanced",
  "sources": [
    {
      "type": "documentation|github|pdf",
      ...source-specific fields...
    }
  ]
}
```

---

## OpenAI ChatGPT | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/platforms/openai

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

Complete guide for creating and deploying skills to OpenAI ChatGPT using Skill Seekers.

Skill Seekers packages documentation into OpenAI-compatible formats optimized for:

Result: output/react/ skill directory with references

Time: 20-40 seconds Cost: ~$0.15-0.30 (using GPT-4o) Quality boost: 3/10 → 9/10

Access your assistant in the OpenAI Platform:

Plain text instructions optimized for Assistant API.

OpenAI uses a two-part system:

The Assistant uses the file_search tool to:

The Assistant uses embeddings to:

Assistants can provide:

Extend your assistant with custom tools:

Include images in your documentation:

Error: API key doesn’t start with sk-

Error: Wrong package format

Symptoms: Assistant doesn’t reference documentation

Test with varied questions:

GPT-4o pricing (as of 2024):

Typical skill enhancement:

Status: ✅ Production Ready (v2.5.0+)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (markdown):
```markdown
# Install with OpenAI dependencies
pip install skill-seekers[openai]

# Verify installation
pip list | grep openai
```

Example 2 (lua):
```lua
# Set as environment variable (recommended)
export OPENAI_API_KEY=sk-proj-...

# Or pass directly to commands
skill-seekers upload --target openai --api-key sk-proj-...
```

Example 3 (elixir):
```elixir
# Use any config (scraping is platform-agnostic)
skill-seekers scrape --config configs/react.json

# Or use a unified config for multi-source
skill-seekers unified --config configs/react_unified.json
```

Example 4 (lua):
```lua
# Enhance SKILL.md using GPT-4o
skill-seekers enhance output/react/ --target openai

# With API key specified
skill-seekers enhance output/react/ --target openai --api-key sk-proj-...
```

---

## AI Enhancement | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/enhancement/ai-enhancement

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

Transform basic SKILL.md files into comprehensive, production-quality documentation using AI enhancement.

The Problem: Auto-generated SKILL.md files are often too generic:

The Solution: Let Claude analyze your reference documentation and create enhanced SKILL.md with:

Uses your Claude Code Max subscription - no API costs!

Time: 30-60 seconds per skill

Uses Anthropic API directly (~$0.15-$0.30 per skill):

Skill Seekers supports 4 enhancement modes for different workflows:

Best for: CI/CD pipelines, automation scripts

Best for: When you want to continue working

Best for: Long-running tasks that must survive parent process exit

Best for: Manual work, debugging

Local Mode (Recommended - No API Key):

Model: Claude Sonnet 4 Format: Maintains YAML frontmatter

Model: Gemini 2.0 Flash Format: Converts to plain markdown (no frontmatter) Output: Updates system_instructions.md

Model: GPT-4o Format: Converts to plain text Output: Updates assistant_instructions.txt

Note: Local mode is FREE and only available for Claude AI.

When using --background or --daemon, a status file is created:

Location: {skill_directory}/.enhancement_status.json

What it does: Skips ALL confirmations, auto-answers “yes” to everything

Default behavior: Force mode is ON by default for maximum automation

Default timeout: 600 seconds (10 minutes)

Adjust based on skill size:

What happens on timeout:

Test Case: steam-economy skill

The enhancement successfully:

Enhancement creates these files:

“claude command not found”

“Enhancement timed out”

“SKILL.md was not updated”

Background task not progressing:

Status file shows error:

“No API key provided”

“No reference files found”

“anthropic package not installed”

Don’t like the result?

Use enhancement when:

Skip enhancement when:

**Examples:**

Example 1 (markdown):
```markdown
# Basic enhancement
skill-seekers enhance output/react/

# With custom timeout
skill-seekers enhance output/react/ --timeout 1200

# Background mode (non-blocking)
skill-seekers enhance output/react/ --background

# Daemon mode (survives terminal close)
skill-seekers enhance output/react/ --daemon
```

Example 2 (lua):
```lua
# Install dependencies
pip install anthropic

# Set API key
export ANTHROPIC_API_KEY=sk-ant-...

# Enhance
skill-seekers enhance output/react/ --mode api
```

Example 3 (markdown):
```markdown
# Runs in foreground, waits for completion
skill-seekers enhance output/react/

# With force mode (no confirmations)
skill-seekers enhance output/react/ --force
```

Example 4 (markdown):
```markdown
# Start in background
skill-seekers enhance output/react/ --background

# Returns immediately with status file created
# Monitor progress:
skill-seekers enhance-status output/react/

# Watch in real-time:
skill-seekers enhance-status output/react/ --watch
```

---

## Design Pattern Detection | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/codebase-analysis/pattern-detection

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

Feature: C3.1 - Detect common design patterns in codebases Version: 2.6.0+ Status: Production Ready ✅

The pattern detection feature automatically identifies common design patterns in your codebase across 9 programming languages. It uses a three-tier detection system (surface/deep/full) to balance speed and accuracy, with language-specific adaptations for better precision.

The --detect-patterns flag integrates with codebase analysis:

Output: output/codebase/patterns/detected_patterns.json

For Claude Code and other MCP clients:

Language-Specific Adaptations:

Tested on 100 real-world Python projects with manually labeled patterns:

False Positives (~13%):

False Negatives (~20%):

Language Limitations:

Pattern detection results will enhance API documentation:

Combine pattern detection with dependency analysis:

Problem: Analysis completes but finds no patterns

Problem: Patterns detected with confidence <0.5

Problem: Analysis takes too long on large codebases

Status: ✅ Production Ready (v2.6.0+) Next: Start using pattern detection to understand and improve your codebase!

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers-patterns --file db.py --depth surface
```

Example 2 (unknown):
```unknown
skill-seekers-patterns --file db.py --depth deep
```

Example 3 (unknown):
```unknown
skill-seekers-patterns --file db.py --depth full
```

Example 4 (markdown):
```markdown
# Single file analysis
skill-seekers-patterns --file src/database.py

# Directory analysis
skill-seekers-patterns --directory src/

# Full analysis with JSON output
skill-seekers-patterns --directory src/ --depth full --json --output patterns/

# Multiple files
skill-seekers-patterns --file src/db.py --file src/api.py
```

---

## How-To Guide Generation (C3.3) | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/codebase-analysis/how-to-guides

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

Transform test workflows into step-by-step educational guides

The How-To Guide Builder automatically generates comprehensive, step-by-step tutorials from workflow examples extracted from test files. It analyzes test code, identifies sequential steps, detects prerequisites, and creates markdown guides with verification points and troubleshooting tips.

Part of C3 Codebase Enhancement Series:

First, extract workflow examples from your test files:

Generate guides from extracted workflow examples:

Enable guide generation during codebase analysis:

Transform basic guides (⭐⭐) into professional tutorials (⭐⭐⭐⭐⭐) with comprehensive AI-powered improvements.

The AI Enhancement system provides 5 automatic improvements that dramatically increase guide quality:

Natural language explanations for each step - not just syntax!

Explanation: Initialize the scraper with the target URL. This configures the HTTP client, sets up request headers, and prepares the URL queue for BFS traversal. The scraper will respect rate limits and follow the URL patterns defined in your configuration.

Use Claude API directly (requires ANTHROPIC_API_KEY):

Use Claude Code CLI (no API key needed):

Generate basic guides without AI:

Uses AI analysis from C3.6 enhancement to intelligently group related workflows.

Best for: Maximum quality, logical topic organization

Groups workflows by test file location.

Best for: Small projects, file-based organization

Groups workflows by test name prefixes.

Best for: Consistent test naming conventions

Groups workflows by difficulty level.

Best for: Educational content, progressive learning paths

Each generated guide includes:

Brief description of what the guide teaches and when to use it.

Full working code combining all steps

Common issues and solutions (when available).

Related guides or advanced topics.

The index provides an overview of all guides:

How-to guides are built from workflow examples extracted by C3.2:

AI analysis enhances grouping and explanations:

Generate tutorials for new team members:

Result: Comprehensive guides showing how to use your APIs/libraries based on real test code.

Extract usage patterns from test suites:

Result: Step-by-step API integration guides derived from actual test workflows.

Create progressive learning paths:

Result: Beginner → Intermediate → Advanced progression of tutorials.

Test Set: Skill_Seekers own test suite

Problem: build_guides_from_examples() returns collection with 0 guides

Check input has workflow examples:

Lower quality threshold:

Problem: Generated guides are incomplete or unclear

Enable AI enhancement:

Use better grouping strategy:

Problem: Workflows grouped incorrectly

C3.3 How-To Guide Generation provides:

✅ Automatic tutorial generation from test workflows ✅ 21 comprehensive tests - all passing ✅ 4 intelligent grouping strategies including AI-based ✅ Multi-language support (Python + 8 others) ✅ Rich markdown output with prerequisites, steps, verification ✅ MCP tool integration for Claude Code ✅ Complexity assessment for progressive learning ✅ Complete integration with C3.2 and C3.6

Status: ✅ Implemented in v2.6.0 Issue: #TBD (C3.3) Related Tasks: C3.1 (Pattern Detection), C3.2 (Test Extraction), C3.4-C3.7 (Future enhancements)

**Examples:**

Example 1 (elixir):
```elixir
# Extract test examples including workflows
skill-seekers-codebase tests/ \
  --extract-test-examples \
  --output output/codebase/

# Or use standalone tool
skill-seekers-extract-test-examples tests/ \
  --output output/codebase/test_examples/
```

Example 2 (sql):
```sql
# Build guides from extracted examples
skill-seekers-how-to-guides \
  output/codebase/test_examples/test_examples.json \
  --output output/codebase/tutorials/

# Choose grouping strategy
skill-seekers-how-to-guides examples.json \
  --group-by ai-tutorial-group   # AI-based (default)
  --group-by file-path            # Group by test file
  --group-by test-name            # Group by test name patterns
  --group-by complexity           # Group by difficulty level
```

Example 3 (markdown):
```markdown
# Automatic pipeline: extract tests → build guides
skill-seekers-codebase tests/ \
  --extract-test-examples \
  --build-how-to-guides \
  --output output/codebase/

# Skip guide generation
skill-seekers-codebase tests/ \
  --skip-how-to-guides
```

Example 4 (markdown):
```markdown
### Step 1
```python
scraper.scrape(url)
```

---

## PDF Documentation | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/scraping/pdf

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

Extract content from PDF documentation and convert to AI skills with advanced features including OCR, table extraction, parallel processing, and MCP integration.

Skill Seekers’ PDF scraper converts PDF documentation into AI skills with:

Uses default settings:

Create configs/manual_pdf.json:

Extract text from scanned PDFs using Optical Character Recognition:

Performance: ~2-5 seconds per page

Handle encrypted PDFs:

Security note: Password is passed via command line (visible in process list). For sensitive documents, use environment variables.

Extract tables from PDFs:

Best with: Well-formatted tables, not complex merged cells

Process pages in parallel for 3x faster extraction:

Note: Only activates for PDFs with > 5 pages

Detects chapter boundaries automatically:

Break large PDFs into manageable chunks:

Intelligently merges code blocks split across pages:

Result: Combined into single code block

If PDF has detectable chapters:

Provide custom categories in config:

The scrape_pdf MCP tool provides PDF scraping through Model Context Protocol:

See: MCP Setup for MCP server configuration

Use --from-json for iteration

Problem: Only “content” or “other” category

Problem: Too many poor code examples

Problem: No images in assets/images/

Problem: OCR fails or gives poor results

Problem: Password not accepted

**Examples:**

Example 1 (sql):
```sql
# Extract from PDF
skill-seekers pdf --input manual.pdf --output output/manual/

# With OCR for scanned PDFs
skill-seekers pdf --input scanned.pdf --output output/scanned/ --ocr

# Password-protected PDF
skill-seekers pdf --input encrypted.pdf --password "your-password"

# Extract tables
skill-seekers pdf --input data.pdf --extract-tables

# Parallel processing (3x faster)
skill-seekers pdf --input large.pdf --parallel --workers 8
```

Example 2 (go):
```go
# 1. Extract from PDF
skill-seekers pdf --input manual.pdf --output output/manual/

# 2. Enhance (optional)
skill-seekers enhance output/manual/

# 3. Package
skill-seekers package output/manual/ --target claude

# 4. Upload
skill-seekers upload manual-claude.zip
```

Example 3 (unknown):
```unknown
skill-seekers pdf \
  --input manual.pdf \
  --output output/manual/ \
  --extract-images \
  --min-quality 6.0
```

Example 4 (json):
```json
{
  "name": "mymanual",
  "description": "My Manual documentation",
  "pdf_path": "docs/manual.pdf",
  "extract_options": {
    "chunk_size": 10,
    "min_quality": 6.0,
    "extract_images": true,
    "min_image_size": 150
  },
  "categories": {
    "getting_started": ["introduction", "setup"],
    "api": ["api", "reference", "function"],
    "tutorial": ["tutorial", "example", "guide"]
  }
}
```

---

## Test Example Extraction (C3.2) | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/manual/codebase-analysis/test-extraction

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

Transform test files into documentation assets by extracting real API usage patterns

The Test Example Extractor analyzes test files to automatically extract meaningful usage examples showing:

Source: tests/test_db.py:15

Use Case: Shows valid initialization parameters

Extracts: Method calls followed by assertions

Use Case: Demonstrates expected behavior

Extracts: Configuration dictionaries (2+ keys)

Use Case: Shows valid configuration examples

Extracts: setUp() methods and pytest fixtures

Use Case: Demonstrates initialization sequences

Extracts: Multi-step integration tests (3+ steps)

Use Case: Shows complete usage patterns

Adjustable Thresholds:

Problem: Documentation often lacks real usage examples

Solution: Extract examples from working tests

Problem: New developers struggle with API usage

Solution: Show how APIs are actually tested

Problem: Creating step-by-step guides is time-consuming

Solution: Use workflow examples as tutorial steps

Problem: Valid configuration is unclear

Solution: Extract config dictionaries from tests

Symptom: total_examples: 0

Symptom: Many trivial or incomplete examples

Symptom: Failed to parse warnings

Status: ✅ Implemented in v2.6.0 Issue: #TBD (C3.2) Related Tasks: C3.1 (Pattern Detection), C3.3-C3.5 (Future enhancements)

**Examples:**

Example 1 (sql):
```sql
# Extract from directory
skill-seekers extract-test-examples tests/ --language python

# Extract from single file
skill-seekers extract-test-examples --file tests/test_scraper.py

# JSON output
skill-seekers extract-test-examples tests/ --json > examples.json

# Markdown output
skill-seekers extract-test-examples tests/ --markdown > examples.md

# Filter by confidence
skill-seekers extract-test-examples tests/ --min-confidence 0.7

# Limit examples per file
skill-seekers extract-test-examples tests/ --max-per-file 5
```

Example 2 (sass):
```sass
# From Claude Code
extract_test_examples(directory="tests/", language="python")

# Single file with JSON output
extract_test_examples(file="tests/test_api.py", json=True)

# High confidence only
extract_test_examples(directory="tests/", min_confidence=0.7)
```

Example 3 (markdown):
```markdown
# Combine with codebase analysis
skill-seekers analyze --directory . --extract-test-examples
```

Example 4 (json):
```json
{
  "total_examples": 42,
  "examples_by_category": {
    "instantiation": 15,
    "method_call": 12,
    "config": 8,
    "setup": 4,
    "workflow": 3
  },
  "examples_by_language": {
    "Python": 42
  },
  "avg_complexity": 0.65,
  "high_value_count": 28,
  "examples": [
    {
      "example_id": "a3f2b1c0",
      "test_name": "test_database_connection",
      "category": "instantiation",
      "code": "db = Database(host=\"localhost\", port=5432)",
      "language": "Python",
      "description": "Instantiate Database: Test database connection",
      "expected_behavior": "self.assertTrue(db.connect())",
      "setup_code": null,
      "file_path": "tests/test_db.py",
      "line_start": 15,
      "line_end": 15,
      "complexity_score": 0.6,
      "confidence": 0.85,
      "tags": ["unittest"],
      "dependencies": ["unittest", "database"]
    }
  ]
}
```

---
