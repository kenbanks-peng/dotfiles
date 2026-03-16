# Skillseekersweb - Getting-Started

**Pages:** 6

---

## Next Steps | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/getting-started/next-steps

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

You’ve completed the Getting Started series! You now know how to:

This guide helps you choose your next steps based on your goals.

Goal: Create structured AI skills for Claude, Gemini, OpenAI platforms

Time investment: 1 hour to proficiency

Goal: Give Cursor, Windsurf, Cline deep framework and codebase knowledge

Time investment: 1-2 hours to proficiency

Goal: Build production-grade search and retrieval systems

Time investment: 2-3 hours to proficiency

Goal: Understand internals, create custom workflows, contribute

Time investment: 4-5 hours to proficiency

…scrape documentation

→ See: Scraping Tutorial

…analyze a GitHub repo

→ See: GitHub Tutorial

…combine multiple sources

→ See: Multi-Source Tutorial

…use workflow enhancement

→ See: Workflows Guide

Build these to cement your skills:

Personal Knowledge Base

Multi-Source Project Skill

Pick a path above and start building. Remember:

You’re ready. Go build something amazing! 🚀

Last updated: 2026-02-22 | Skill Seekers v3.1.0

**Examples:**

Example 1 (markdown):
```markdown
# Claude skill
skill-seekers create https://docs.example.com --target claude

# OpenAI GPT
skill-seekers create https://docs.example.com --target openai

# Gemini skill
skill-seekers create https://docs.example.com --target gemini
```

Example 2 (markdown):
```markdown
# Create .cursorrules for a framework
skill-seekers create https://react.dev --target cursor

# Analyze your codebase
skill-seekers create ./my-project --target cursor --comprehensive

# With workflow enhancement (v3.1.0)
skill-seekers create https://docs.python.org --target cursor --enhance-workflow api-documentation
```

Example 3 (markdown):
```markdown
# Create RAG-ready documents
skill-seekers create https://docs.example.com --target langchain

# Export to Chroma
skill-seekers create https://docs.example.com --target chroma

# Export to vector DB
skill-seekers create https://docs.example.com --target weaviate
```

Example 4 (yaml):
```yaml
# Create custom workflow
cat > my-workflow.yaml << 'EOF'
name: "security-audit"
stages:
  - name: "Vulnerability Scan"
    prompt: "Scan for security issues..."
EOF

skill-seekers workflows add my-workflow.yaml
skill-seekers create https://github.com/owner/repo --enhance-workflow security-audit
```

---

## Installation | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/getting-started/installation

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

Time: 15-30 minutes total (including all installations)

Result: Working Skill Seekers v3.1.0 installation ready to create AI skills

Before starting, you need:

The easiest way to install Skill Seekers is through PyPI:

uv is a fast Python package manager:

For development or the latest features:

✅ If you see: Python 3.10.x or higher → Skip to Step 2!

Linux (Ubuntu/Debian):

✅ If you see: git version 2.x.x → Skip to Step 3!

Windows: Download from: https://git-scm.com/download/win

Claude Code enables free local AI enhancement (uses your Claude Max subscription):

Why install Claude Code?

Without Claude Code, you can still:

For API-based enhancement or upload, set up your API key:

Make it permanent (optional):

Add the export command to your shell profile (~/.bashrc, ~/.zshrc, or ~/.bash_profile):

Run the built-in check:

Run Skill Seekers without installing Python:

See Docker Deployment for details.

Make sure pip’s bin directory is in your PATH:

Install using pip instead of python:

Claude Code may not be in your PATH. Add it:

**Examples:**

Example 1 (go):
```go
# Install base package
pip install skill-seekers

# Or install with specific LLM platform support
pip install skill-seekers[gemini]  # For Google Gemini
pip install skill-seekers[openai]  # For OpenAI ChatGPT
pip install skill-seekers[all]     # For all platforms
```

Example 2 (markdown):
```markdown
skill-seekers --version
# Should show: skill-seekers 3.1.0 or higher
```

Example 3 (markdown):
```markdown
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Skill Seekers
uv tool install skill-seekers

# Verify
skill-seekers --version
```

Example 4 (unknown):
```unknown
python3 --version
```

---

## Quick Start | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/getting-started/quick-start

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

Get up and running with Skill Seekers in 5 minutes using the new v3.0+ unified create command.

Before starting, ensure you have:

You should see: skill-seekers 3.1.0 or higher

The v3.0+ create command works with any source:

Let’s try a real example with Tailwind CSS:

Transform the skill with AI enhancement using a workflow preset:

Try these prompts in Claude:

Result: Claude responds with accurate, context-aware answers!

For the impatient, here’s everything in one command:

Total time: ~10-15 minutes for a complete, production-ready skill.

Now that you’ve created your first skill:

Use the --selector option with custom CSS selectors, or check if the site provides llms.txt for faster access.

💡 Pro Tip: Check if your target site has an llms.txt file. This provides pre-structured documentation and is 10x faster to process!

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers --version
```

Example 2 (sql):
```sql
# From documentation website
skill-seekers create https://docs.python-requests.org --target claude

# From GitHub repository
skill-seekers create https://github.com/psf/requests --target claude

# From PDF file
skill-seekers create ./manual.pdf --target claude

# From local codebase
skill-seekers create ./my-project --target claude
```

Example 3 (unknown):
```unknown
skill-seekers create https://tailwindcss.com/docs --target claude --max-pages 50
```

Example 4 (swift):
```swift
✅ Skill created: tailwindcss-claude.zip (2.1 MB)
📦 Format: Claude AI (YAML frontmatter)
📄 Pages: 50
🎯 Ready to upload!
```

---

## Overview | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/getting-started/overview

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

Skill Seekers is the AI Skill & RAG Toolkit. It transforms documentation websites, GitHub repositories, PDF files, and local codebases into structured AI skills and RAG-ready knowledge for Claude, Gemini, OpenAI, LangChain, LlamaIndex, Cursor, and any LLM platform.

What is an AI Skill? A curated, structured knowledge package that gives AI systems deep expertise in a specific domain—frameworks, APIs, codebases, or documentation. Instead of generic responses, your AI “knows” the subject matter.

The Problem: 70% of AI skill development is spent on data preprocessing—scraping, cleaning, analyzing code, extracting patterns, and structuring knowledge. We automate all of it.

Instead of manually building skills, Skill Seekers:

Result: Production-ready AI skills in 15-45 minutes instead of days of manual work.

That’s it! You now have AI-ready skills from ANY source.

New workflow system for consistent, reusable enhancement strategies:

Bundled presets: default, minimal, security-focus, architecture-comprehensive, api-documentation

Enhancement Workflows:

Universal Intelligence Platform:

Read the full changelog →

**Examples:**

Example 1 (sql):
```sql
# Install
pip install skill-seekers

# Create skill from any source with one command
skill-seekers create https://react.dev --target claude

# From GitHub repository
skill-seekers create https://github.com/owner/repo --target langchain

# From PDF
skill-seekers create ./manual.pdf --target openai

# From local codebase
skill-seekers create ./my-project --target llamaindex

# With workflow enhancement (v3.1.0)
skill-seekers create https://docs.python.org --target claude --enhance-workflow api-documentation
```

Example 2 (yaml):
```yaml
# Use bundled preset
skill-seekers create <source> --enhance-workflow security-focus

# Chain multiple workflows
skill-seekers create <source> --enhance-workflow minimal --enhance-workflow api-documentation

# Create custom workflow
cat > my-workflow.yaml << 'EOF'
name: "custom-analysis"
stages:
  - name: "Deep Analysis"
    prompt: "Analyze this code for performance patterns..."
    model: "claude-sonnet-4"
EOF
skill-seekers workflows add my-workflow.yaml
```

---

## Create Your First Skill | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/getting-started/first-skill

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

Learn by doing! This tutorial walks you through creating your first AI skill from documentation using the v3.0+ unified create command.

Prerequisites: Skill Seekers installed (Installation Guide)

Time: 5-10 minutes | Result: Working Claude skill ready to upload

We’ll create a skill from Tailwind CSS documentation because it’s:

Final result: A Claude skill that knows Tailwind CSS utilities, components, and best practices.

Make sure Skill Seekers is ready:

You should see something like: skill-seekers 3.1.0

If not installed: See Installation Guide

Run this single command:

Transform from basic (3/10) to comprehensive (9/10) using workflow presets:

Option A: Default Enhancement

Option B: API Documentation Workflow

What enhancement does:

Time: Adds 30-60 seconds

Try these prompts in Claude:

Result: Claude responds with accurate, context-aware answers based on official Tailwind documentation!

Time investment: 5 minutes (10-15 with enhancement)

Result: Production-quality AI skill ready to use!

Now that you know the basics, try:

Skill Seekers includes 24 presets for popular frameworks:

Add code analysis to your skills:

See: GitHub Analysis Tutorial

Turn technical PDFs into searchable skills:

See: Extracting PDFs Tutorial

Combine docs + GitHub + PDFs:

See: Multi-Source Tutorial

Problem: Scraper couldn’t find content

Solution: Use interactive mode to test selectors:

Problem: Workflow name doesn’t exist

Solution: List available workflows:

Your typical workflow:

Questions? Open an issue: https://github.com/yusufkaraaslan/Skill_Seekers/issues

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers --version
```

Example 2 (unknown):
```unknown
skill-seekers create https://tailwindcss.com/docs --target claude --max-pages 50
```

Example 3 (lua):
```lua
🔍 Checking for llms.txt...
📥 Analyzing source type: documentation website
🌐 Fetching https://tailwindcss.com/docs
📄 Scraping documentation...
   ├─ Page 1/50: Installation
   ├─ Page 2/50: Editor Setup
   ├─ Page 3/50: Utility-First Fundamentals
   ...
   └─ Page 50/50: Plugin API

✅ Skill created: tailwindcss-claude.zip (1.8 MB)
📦 Format: Claude AI (YAML frontmatter)
📊 Statistics:
   - Pages: 50
   - Code examples: 127
   - Categories: 8
   - Time: 45 seconds
```

Example 4 (unknown):
```unknown
unzip -l tailwindcss-claude.zip
```

---

## Understanding Skills | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/getting-started/understanding-skills

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

To get the most out of Skill Seekers, it helps to understand what a “skill” actually is and how the system creates one. This guide explains the internals without getting too technical.

A skill is structured knowledge packaged for AI systems. Think of it like this:

Real-world example: A “React” skill contains:

When you ask Claude about React with this skill loaded, it responds with accurate, context-aware answers instead of general training data.

Skill Seekers transforms raw sources into AI-ready skills through a 5-phase pipeline:

What happens: Skill Seekers connects to your source and extracts raw content.

For documentation websites:

What happens: Raw content is analyzed for structure, patterns, and meaning.

C3.x Analysis (for code):

What happens: Analyzed content is structured into a consistent format.

What happens: AI improves the skill’s quality and completeness.

v3.1.0 Workflow Enhancement:

What enhancement adds:

Before enhancement: 3/10 quality (raw extraction) After enhancement: 9/10 quality (AI-curated)

Cost: FREE with Claude Code, or ~$0.15-$0.30 via API

What happens: The skill is converted to platform-specific formats.

Let’s look at what’s inside a skill:

React uses a virtual representation of the DOM…

references/ ├── getting-started/ │ ├── installation.md │ ├── thinking-in-react.md │ └── quick-start.md ├── hooks/ │ ├── useState.md │ ├── useEffect.md │ └── useContext.md └── components/ ├── functional-components.md └── class-components.md

examples/ ├── todo-app.md ├── fetch-data.md ├── form-handling.md └── context-provider.md

Skills include version metadata:

Track versions for your team:

Now that you understand how skills work:

**Examples:**

Example 1 (elixir):
```elixir
Raw Source → Extract → Analyze → Organize → Package → AI Skill
     ↓          ↓         ↓          ↓          ↓         ↓
   HTML/     Content   Patterns   Structured  Platform  Ready
   GitHub    + Meta    + Code     Reference   Format    to Use
   PDF/      Data      Detection  Files                  
   Code
```

Example 2 (unknown):
```unknown
skill-name/
├── SKILL.md              # Main entry point (overview + navigation)
├── references/           # Detailed documentation
│   ├── category-1/
│   │   ├── topic-a.md
│   │   └── topic-b.md
│   └── category-2/
│       └── topic-c.md
└── examples/             # Code examples and patterns
    ├── example-1.md
    └── example-2.md
```

Example 3 (yaml):
```yaml
---
title: "React"
description: "A JavaScript library for building user interfaces"
version: "18.2.0"
sources:
  - "https://react.dev"
created: "2026-01-15"
---

# React Skill

## Quick Reference

### Common Patterns

**Functional Component:**
```jsx
function MyComponent({ prop1, prop2 }) {
  return <div>{prop1}</div>;
}
```

Example 4 (jsx):
```jsx
useEffect(() => {
  // Side effect
  return () => {
    // Cleanup
  };
}, [dependencies]);
```

---
