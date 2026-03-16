# Skillseekersweb - Reference

**Pages:** 9

---

## Claude AI Integration Technical Reference | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/claude-integration

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

Complete technical guide for creating, packaging, and deploying skills to Claude AI.

Skill Seekers is designed as the official skill creation toolkit for Claude AI. This guide covers the technical architecture, file formats, API integration, and development workflows.

Version: v2.6.0 (Three-Stream GitHub Architecture - Phases 1-5 Complete!)

Claude AI skills use a markdown file with YAML frontmatter:

Result: skill-name.zip (Claude AI format)

Note: Official Skills API is in development. Manual upload recommended for now.

Future API (planned):

18 tools for skill development:

Restart Claude Desktop to activate MCP tools.

Documentation Scraping:

Skill Management: 5. package_skill - Package skill for platform 6. upload_skill - Upload to Claude/Gemini/OpenAI 7. enhance_skill - AI enhancement 8. validate_skill - Validate skill structure

Codebase Analysis (C3.x): 9. analyze_codebase - Full codebase analysis 10. extract_patterns - Design pattern detection 11. extract_test_examples - Test example extraction 12. build_how_to_guides - Generate tutorials

Git Config Sources: 13. add_git_source - Add git-based config 14. list_git_sources - List sources 15. remove_git_source - Remove source 16. fetch_git_sources - Fetch updates

Utilities: 17. list_presets - Show available presets 18. get_preset - Get preset config

Example conversation:

For large projects with extensive codebases and documentation.

See also: Three-Stream GitHub Architecture

Before uploading to Claude:

Run before packaging:

1. Custom Instructions

2. Sub-Skills (Router Pattern)

Claude AI supports hierarchical skills with intelligent routing.

3. Conversation Context

Skills can access conversation history and maintain context across turns.

Optional metadata file for package info:

Auto-generated during packaging.

Create custom package layouts:

See also: Large Documentation Handling

Claude AI matches skills to conversations based on:

Optimize for discovery:

Cause: Documentation changed since skill creation

Cause: Skill too large for Claude context window

See also: Skill Architecture Guide

Status: ✅ Production Ready (v2.6.0)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (yaml):
```yaml
---
name: skill-name
description: When to use this skill (1-2 sentences)
tags:
  - tag1
  - tag2
custom_instructions: |
  Optional: Specific instructions for Claude when using this skill
---

# Skill Name

Comprehensive documentation for the skill...

## Quick Reference

Key APIs, commands, or concepts...

## Examples

Practical code examples...

## References

Links to official documentation...
```

Example 2 (unknown):
```unknown
skill-name.zip
├── SKILL.md                    # Main skill file
├── references/                 # Supporting documentation
│   ├── api/
│   │   └── api-reference.md
│   ├── guides/
│   │   └── getting-started.md
│   └── examples/
│       └── code-examples.md
├── scripts/                    # Optional helper scripts
│   └── setup.sh
└── assets/                     # Optional images/diagrams
    └── architecture.png
```

Example 3 (go):
```go
skill-seekers package output/skill-name/ --target claude
```

Example 4 (go):
```go
project-router.zip
├── SKILL.md                    # Router skill
├── sub-skills/
│   ├── project-code/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── project-docs/
│   │   ├── SKILL.md
│   │   └── references/
│   └── project-github/
│       ├── SKILL.md
│       └── references/
└── metadata.json               # Package metadata
```

---

## Large Documentation Handling | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/large-documentation

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

Strategies for scraping and managing documentation sites with 10,000+ pages.

Large documentation sites (10K+ pages) present unique challenges:

Best for: Documentation with clear categorical organization

How it works: Scrape each category into separate sub-skill, create router

Example: Kubernetes Docs

Config example (k8s-concepts.json):

Best for: Unorganized docs or uniform structure

How it works: Auto-split when token budget exceeded

Best for: Pre-planned organization

Speed up scraping with concurrent workers:

Optimal worker count:

Single-process async for moderate speedup:

Resume interrupted scrapes:

Detect and skip already-scraped pages:

Kubernetes Router (4 sub-skills):

Extract only essential content:

Reduce token count by 30-50% by excluding non-essential content.

Skip low-value pages:

Update only changed pages:

Remove duplicate content:

Challenge: Comprehensive docs across 5 major sections

Solution: Category-based split

Challenge: Large, monolithic documentation

Solution: Automatic size-based split

Challenge: Massive internal wiki with poor organization

Solution: Hybrid approach

Factors affecting speed:

Stage 1: Quick scan (get structure)

Stage 2: Analyze and plan split

Stage 3: Full scrape with split

Define custom routing rules:

Symptoms: Process killed, MemoryError

Enable streaming mode:

Split into smaller sub-skills:

Symptoms: Taking 5+ hours for 10K pages

Use parallel workers:

Skip low-value content:

Symptoms: Upload fails, “Token limit exceeded”

Split into router + sub-skills:

Optimize content extraction:

✅ Before scraping, analyze documentation structure:

✅ Clearer organization, better routing ❌ Avoid arbitrary size-based splits if categories exist

✅ Scrape small sample (100 pages) to validate config:

✅ Enable verbose logging:

✅ Always use --checkpoint for large scrapes ✅ Enables resume if interrupted

Status: ✅ Production Ready (v2.0.0+)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (go):
```go
# 1. Split by category
skill-seekers scrape --config configs/k8s-concepts.json --output output/k8s-concepts/
skill-seekers scrape --config configs/k8s-tasks.json --output output/k8s-tasks/
skill-seekers scrape --config configs/k8s-api.json --output output/k8s-api/

# 2. Create router
skill-seekers router \
  output/k8s-concepts/ \
  output/k8s-tasks/ \
  output/k8s-api/ \
  --output output/k8s-router/ \
  --name kubernetes-complete

# 3. Package
skill-seekers package output/k8s-router/ --include-subskills
```

Example 2 (json):
```json
{
  "name": "kubernetes-concepts",
  "base_url": "https://kubernetes.io/docs/concepts/",
  "url_patterns": {
    "include": ["concepts"],
    "exclude": []
  },
  "max_pages": 500
}
```

Example 3 (markdown):
```markdown
# Automatic splitting at 50K tokens per skill
skill-seekers scrape --config configs/large-docs.json \
  --auto-split \
  --max-tokens 50000 \
  --output output/large-docs/

# Creates:
# output/large-docs-part1/
# output/large-docs-part2/
# output/large-docs-part3/
# output/large-docs-router/  (automatically generated)
```

Example 4 (json):
```json
{
  "name": "django-complete",
  "router_mode": true,
  "sub_skills": [
    {
      "name": "django-tutorial",
      "base_url": "https://docs.djangoproject.com/en/stable/intro/",
      "max_pages": 200
    },
    {
      "name": "django-api",
      "base_url": "https://docs.djangoproject.com/en/stable/ref/",
      "max_pages": 1000
    },
    {
      "name": "django-topics",
      "base_url": "https://docs.djangoproject.com/en/stable/topics/",
      "max_pages": 500
    }
  ]
}
```

---

## Configuration Schema Reference | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/config-schema

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

Complete reference for the Skill Seekers unified configuration format introduced in v2.6.0.

The unified config format allows you to combine multiple sources (documentation, GitHub, PDFs) into a single AI skill with intelligent content merging.

Schema Version: v2.6.0 Format: JSON Backward Compatible: Yes (legacy configs still supported)

Required - Unique identifier for the config.

Required - Human-readable description of what the skill covers.

Required - Array of source configurations (at least 1 required).

Optional - Content merging strategy when using multiple sources.

Extract content from documentation websites.

Default: false - Whether to extract API reference sections separately.

Specific URLs to start scraping from (bypasses automatic discovery).

CSS selectors for extracting content.

Control which URLs to include/exclude.

Categorize pages for better organization and merging.

Delay between requests in seconds (prevents rate limiting).

Optional - Maximum pages to scrape. Defaults to unlimited if not specified.

Note: Since v2.6.0, unlimited scraping is the default. Only specify max_pages if you need to limit pages for testing or rate-limit concerns.

Extract code, issues, and repository metadata from GitHub.

Default: false - Enable C3.x codebase analysis with AST parsing.

Depth of code analysis when C3.x is enabled.

Default: false - Include GitHub issues in the skill.

Maximum number of issues to fetch (requires fetch_issues: true).

Default: false - Extract CHANGELOG.md if it exists.

Default: false - Include GitHub releases.

Glob patterns for files to analyze (requires codebase analysis).

AI enhancement mode for C3.x analysis.

Extract content from PDF documents.

Default: false - Enable OCR for scanned PDFs.

Password for encrypted PDFs.

Default: false - Extract tables as structured data.

Default: false - Process pages in parallel for faster extraction.

Visit skillseekersweb.com/configs and scroll to the “Validate Your Config” section:

Skill Seekers v2.6.0+ still supports legacy configs (single-source format).

Automatically converts to:

If you have legacy configs (pre-v2.6.0), you can:

Schema Version: v2.6.0 Last Updated: January 2026 Backward Compatible: Yes (legacy configs supported)

**Examples:**

Example 1 (json):
```json
{
  "name": "react"
}
```

Example 2 (json):
```json
{
  "description": "Complete React knowledge combining official documentation and React codebase. Use when building React applications or understanding React internals."
}
```

Example 3 (json):
```json
{
  "sources": [
    { "type": "documentation", "base_url": "..." },
    { "type": "github", "repo": "..." }
  ]
}
```

Example 4 (json):
```json
{
  "merge_mode": "rule-based"
}
```

---

## Git-Based Config Sources | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/git-config-sources

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

Use private or team git repositories to store and share scraping configurations.

Git-based config sources allow you to:

Version: v2.2.0+ (Git config sources feature)

configs/frontend/react.json:

Setup (once per team):

Team Members (each person):

When someone updates configs:

Contribute new config:

Repository structure:

Example conversation:

Git sources are cloned to:

Error: Failed to clone repository Authentication failed for ‘https://github.com/org/configs.git’

Status: ✅ Production Ready (v2.2.0+)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (sass):
```sass
# Add git repository as config source
skill-seekers add-git-source \
  https://github.com/your-org/scraping-configs.git \
  --name company-configs \
  --branch main

# With authentication (private repo)
skill-seekers add-git-source \
  https://github.com/your-org/private-configs.git \
  --name private-configs \
  --token ghp_yourPersonalAccessToken
```

Example 2 (tsx):
```tsx
# Reference config by source name + path
skill-seekers scrape \
  --config git:company-configs:configs/react.json

# Or use shorthand (auto-detects)
skill-seekers scrape --config company-configs:react.json
```

Example 3 (markdown):
```markdown
# List all configured sources
skill-seekers list-git-sources

# Fetch latest updates
skill-seekers fetch-git-sources

# Remove a source
skill-seekers remove-git-source company-configs
```

Example 4 (lua):
```lua
# GitHub personal access token
skill-seekers add-git-source \
  https://github.com/your-org/configs.git \
  --name my-configs \
  --token ghp_abc123... \
  --branch main

# GitLab personal access token
skill-seekers add-git-source \
  https://gitlab.com/your-org/configs.git \
  --name gitlab-configs \
  --token glpat-abc123... \
  --branch main

# Bitbucket app password
skill-seekers add-git-source \
  https://bitbucket.org/your-org/configs.git \
  --name bitbucket-configs \
  --token ATBB...abc123 \
  --branch main
```

---

## llms.txt Automatic Detection | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/llms-txt-support

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

Skill Seekers automatically detects llms.txt files for 10x faster scraping with AI-optimized content.

llms.txt is an emerging standard for providing AI-optimized documentation in a single file. When a website offers llms.txt, Skill Seekers automatically detects and prioritizes it over traditional web scraping.

Skill Seekers checks for llms.txt variants in this order:

Detection happens automatically - no configuration needed!

Description of the function…

Explicitly use llms.txt even if web scraping is preferred:

Force traditional web scraping:

Use llms.txt (automatic detection) when:

Force web scraping when:

Framework Documentation:

The llms.txt format is a community-driven standard for AI-optimized documentation:

Learn more: llms.txt specification (if site exists)

For documentation site owners:

Next.js Documentation:

Supabase Documentation:

Contact site maintainers to update llms.txt

Use web scraping (automatic fallback)

Request llms.txt from site owner

Symptoms: Skill missing expected sections

Supplement with web scraping:

Use web scraping only:

✅ Skill Seekers intelligently detects and uses llms.txt when beneficial

✅ After using llms.txt, spot-check the generated skill:

✅ If llms.txt is > 60 days old, consider web scraping:

✅ Use llms.txt as base, add GitHub issues/changelog:

Status: ✅ Production Ready (v2.5.0+)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (markdown):
```markdown
# Standard scraping command
skill-seekers scrape https://example.com/ --output output/example/

# Behind the scenes:
# 1. Check https://example.com/llms-full.txt ✅ Found!
# 2. Download llms-full.txt (2 seconds)
# 3. Parse and convert to skill format
# 4. Done! (vs. 5 minutes to scrape 200 pages)
```

Example 2 (markdown):
```markdown
# Example.com Documentation

> AI-optimized documentation for Example.com

# Getting Started

## Installation

```bash
npm install example
```

Example 3 (javascript):
```javascript
const result = doSomething('value');
```

Example 4 (markdown):
```markdown
**Key Features:**
- Plain markdown format
- Hierarchical structure
- Code examples included
- Comprehensive and complete

---

## Detection and Usage

### Automatic Detection (Default)

**No configuration needed:**

```bash
# Automatically uses llms.txt if available
skill-seekers scrape https://docs.example.com/ --output output/example/
```

---

## Feature Support Matrix & Platform Comparison | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/feature-matrix

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

Complete comparison of Skill Seekers features across all supported platforms.

Skill Seekers supports 4 target platforms with different formats, APIs, and capabilities:

All platforms support:

Platform-specific support:

All platforms support C3.x codebase analysis features:

26 MCP tools for Claude Desktop integration:

See also: MCP Setup Guide

Note: Gemini and OpenAI don’t have native sub-skill routing, so the router flattens into a single comprehensive skill.

✅ LOCAL Enhancement Mode - FREE with Claude Code Max ✅ Sub-Skill Routing - Native hierarchical skill support ✅ Custom Instructions - Behavior customization in YAML frontmatter ✅ MCP Integration - 18 tools for Claude Desktop

✅ Grounding Support - Automatic source attribution ✅ Long Context Window - Up to 1M tokens ✅ Low Cost Enhancement - $0.01-0.05 per skill (Gemini 2.0 Flash)

✅ Vector Store + file_search - Semantic search built-in ✅ Function Calling - Extend with custom tools ✅ Streaming Responses - Real-time answer generation

✅ Universal Compatibility - Works with any LLM ✅ No Platform Lock-In - Pure markdown format ✅ Version Control Friendly - Easy to diff and track changes

24 built-in presets work across all platforms:

Status: ✅ Complete (v2.6.0)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (go):
```go
skill-seekers package output/skill/ --target [claude|gemini|openai|markdown]
```

Example 2 (lua):
```lua
# Claude (API mode)
export ANTHROPIC_API_KEY=sk-ant-...
skill-seekers enhance output/skill/ --enhance

# Claude (LOCAL mode - FREE!)
skill-seekers enhance output/skill/ --enhance-local

# Gemini (API mode)
export GOOGLE_API_KEY=AIza...
skill-seekers enhance output/skill/ --target gemini

# OpenAI (API mode)
export OPENAI_API_KEY=sk-proj-...
skill-seekers enhance output/skill/ --target openai
```

Example 3 (lua):
```lua
# Gemini (programmatic)
skill-seekers upload skill-gemini.tar.gz --target gemini --api-key AIza...

# OpenAI (programmatic)
skill-seekers upload skill-openai.zip --target openai --api-key sk-proj-...

# Claude (manual for now)
# Upload skill.zip at claude.ai/skills
```

Example 4 (markdown):
```markdown
# Works for all platforms
skill-seekers-codebase path/to/repo/ \
  --output output/codebase/ \
  --extract-patterns \
  --extract-test-examples \
  --build-how-to-guides \
  --ai-mode auto
```

---

## Skill Architecture Guide - Layering and Splitting | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/skill-architecture

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

Complete guide for architecting complex multi-skill systems using the router/dispatcher pattern.

Claude recommends keeping skill files under 500 lines for optimal performance. This guideline exists because:

As applications grow complex, developers often create skills that:

Skill layering involves:

Result: Build sophisticated applications while maintaining 500-line guideline per skill.

You should split when:

You can keep monolithic when:

A router skill (also called dispatcher or hub skill) is a lightweight master skill that:

Problem: E-commerce skill is 2000+ lines covering catalog, cart, checkout, orders, and admin.

Solution: Split into focused sub-skills with router.

1. ecommerce.md (Router - 150 lines)

2. product_catalog.md (350 lines)

3. shopping_cart.md (280 lines)

Problem: Code assistant handles debugging, refactoring, documentation, testing - 1800+ lines.

Solution: Specialized sub-skills with smart routing.

Problem: ETL pipeline skill covers extraction, transformation, loading, validation, monitoring.

Solution: Pipeline stages as sub-skills.

Each sub-skill should have ONE clear purpose.

❌ Bad: user_management.md handles auth, profiles, permissions, notifications ✅ Good:

Make routing keywords explicit and unambiguous.

❌ Bad: Vague keywords like “data”, “user”, “process” ✅ Good: Specific keywords like “login”, “authenticate”, “extract”, “transform”

Keep router lightweight - just routing logic.

❌ Bad: Router contains actual implementation code ✅ Good: Router only contains:

Group by responsibility, not by code structure.

❌ Bad: Split by file type (controllers, models, views) ✅ Good: Split by feature (user_auth, product_catalog, order_processing)

Don’t create sub-skills for trivial distinctions.

❌ Bad: Separate skills for “add_user” and “update_user” ✅ Good: Single “user_management” skill covering all CRUD

Explicitly state when sub-skills work together.

Use same SKILL.md structure across all sub-skills.

Symptoms: Wrong sub-skill activated or no routing happening

More specific keywords:

Add routing examples:

Check sub-skill descriptions:

Symptoms: Sub-skill exceeds 500 lines

Move reference material:

Symptoms: Router itself is large (> 300 lines)

Simplify routing logic:

Reduce number of sub-skills:

For very large systems:

When to use: Systems with 10+ sub-skills or multiple logical subsystems

Router considers conversation context:

Status: ✅ Complete (v2.0.0+)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (yaml):
```yaml
User Query: "How do I book a flight to Paris?"
     ↓
Router Skill: Analyzes keywords → "flight", "book"
     ↓
Activates: flight_booking sub-skill
     ↓
Response: Flight booking guidance (only this skill loaded)
```

Example 2 (markdown):
```markdown
# Travel Planner (Router)

## When to Use This Skill

Use for travel planning, booking, and itinerary management.

This is a router skill that directs your questions to specialized sub-skills.

## Sub-Skills Available

### flight_booking
For booking flights, searching airlines, comparing prices, seat selection.
**Keywords:** flight, airline, booking, ticket, departure, arrival

### hotel_reservation
For hotel search, room booking, amenities, check-in/check-out.
**Keywords:** hotel, accommodation, room, reservation, stay

### itinerary_generation
For creating travel plans, scheduling activities, route optimization.
**Keywords:** itinerary, schedule, plan, activities, route

## Routing Logic

Based on your question keywords:
- Flight-related → Activate `flight_booking`
- Hotel-related → Activate `hotel_reservation`
- Planning-related → Activate `itinerary_generation`
- Multiple topics → Activate relevant combination

## Usage Examples

**"Find me a flight to Paris"** → flight_booking
**"Book hotel in Tokyo"** → hotel_reservation
**"Create 5-day Rome itinerary"** → itinerary_generation
**"Plan Paris trip with flights and hotel"** → flight_booking + hotel_reservation + itinerary_generation
```

Example 3 (markdown):
```markdown
# E-Commerce Platform (Router)

## Sub-Skills
- product_catalog - Browse, search, filter products
- shopping_cart - Add/remove items, quantities
- checkout_payment - Process orders, payments
- order_management - Track orders, returns
- admin_tools - Inventory, analytics

## Routing
product/catalog/search → product_catalog
cart/basket/add/remove → shopping_cart
checkout/payment/billing → checkout_payment
order/track/return → order_management
admin/inventory/analytics → admin_tools
```

Example 4 (lua):
```lua
# Product Catalog

## When to Use
Product browsing, searching, filtering, recommendations.

## Quick Reference
- Search products: `search(query, filters)`
- Get details: `getProduct(id)`
- Filter: `filter(category, price, brand)`
...
```

---

## AI Skill Standards & Best Practices | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/ai-skill-standards

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

Version: 1.0 Last Updated: 2026-01-11 Scope: Cross-platform AI skills for Claude, Gemini, OpenAI, and generic LLMs

An AI skill is a focused knowledge package that enhances an AI agent’s capabilities in a specific domain. Skills include:

Modern AI skills follow three core principles:

These standards apply to all platforms (Claude, Gemini, OpenAI, generic).

Format: Gerund form (verb + -ing)

Why: Clearly describes the activity or capability the skill provides.

Format: Third person, actionable, includes BOTH “what” and “when”

Why: Injected into system prompts; inconsistent POV causes discovery problems.

Why: Token efficiency is critical—unused context wastes capacity.

Example Transformation:

Required Sections (in order):

File Structure (Open Agent Skills Standard):

YAML Frontmatter (required for all platforms):

Official Standard: Agent Skills Best Practices

Official Standard: Grounding Best Practices

Grounding Enhancements:

Note: Grounding costs $14 per 1,000 queries (as of Jan 5, 2026).

Official Standard: Key Guidelines for Custom GPTs

Use Case: Documentation sites, internal wikis, non-LLM tools

Format: Standard markdown with minimal metadata

Best Practice: Focus on human readability over token economy

Modern AI skills leverage advanced RAG (Retrieval-Augmented Generation) patterns for optimal knowledge delivery.

Pattern: Multi-query, context-aware retrieval with agent orchestration

Implementation in Skills:

Why: Agent can navigate structure to find exactly what’s needed.

Pattern: Knowledge graph structures for complex reasoning

Use Case: Large codebases, interconnected concepts, architectural analysis

Benefits: Multi-hop reasoning, relationship exploration, complex queries

Pattern: Specialized agents for different knowledge domains

Use Case: Enterprise workflows, compliance requirements, multi-domain expertise

Pattern: Self-evaluation and refinement before finalizing responses

Benefits: Higher quality outputs, fewer errors, better adherence to standards

Pattern: Semantic search over embeddings for concept-based retrieval

Use Case: Large documentation sets, conceptual queries, similarity search

Use this rubric to assess AI skill quality on a 10-point scale.

Problem: Including everything about a topic instead of focusing on actionable knowledge.

Fix: Focus on what the user needs to do, not history or background.

Problem: Using “I” or “you” in metadata (breaks Claude discovery).

Fix: Always use third person in description field.

Problem: Redundant explanations, verbose phrasing, or filler content.

Fix: Use bullet points, remove filler, focus on distinctions.

Problem: Code examples that don’t compile or run.

Fix: Test all code examples, ensure they compile/run.

Problem: Description explains what but not when.

Fix: Always include “Use when…” or “Use for…” clause.

Problem: All references in one file or directory, no organization.

Fix: Organize by category, enable agent navigation.

Problem: Including deprecated APIs or old best practices.

Fix: Regularly update skills, include version info.

Model Context Protocol (MCP): Standardizes how agents access tools and data

Multi-Modal Skills: Beyond text (images, audio, video)

Skill Composition: Skills that reference other skills

Real-Time Grounding: Skills + live data sources

Federated Skill Repositories: Decentralized skill discovery

Document Maintenance:

**Examples:**

Example 1 (yaml):
```yaml
name: building-react-applications  # kebab-case, gerund form
description: Building modern React applications with hooks, routing, and state management
```

Example 2 (elixir):
```elixir
[What it does]. Use when [specific triggers/scenarios].
```

Example 3 (json):
```json
## Quick Reference
*30-second overview with most common patterns*

[Core content - 3,000-4,500 tokens]

## Extended Reference
*See references/api.md for complete API documentation*
```

Example 4 (sql):
```sql
React is a popular JavaScript library for building user interfaces.
It was created by Facebook and is now maintained by Meta and the
open-source community. React uses a component-based architecture
where you build encapsulated components that manage their own state.
```

---

## Three-Stream GitHub Architecture (C3.x Router) | Skill Seekers Docs

**URL:** https://skillseekersweb.com/docs/reference/c3x-router-architecture

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

Complete guide to the Three-Stream GitHub Architecture pattern for handling large codebases and documentation.

The Three-Stream GitHub Architecture (also called C3.x Router Architecture) is a pattern for creating comprehensive AI skills from large projects with extensive documentation and codebases. Instead of scraping just the documentation or just the codebase, it combines three independent streams of knowledge into a unified skill with intelligent routing.

Version: v2.6.0 (Phases 1-5 Complete!)

Key Innovation: Each stream scrapes independently, then a router skill intelligently directs Claude to the right sub-skill based on the user’s question.

Purpose: Extract code structure, patterns, and implementation details from the GitHub repository

Output: output/project-code/SKILL.md + references

Purpose: Extract official documentation from the project website

Output: output/project-docs/SKILL.md + references

Purpose: Extract community knowledge, issues, discussions, and changelog from GitHub

Output: output/project-github/SKILL.md + references

After creating the three stream skills, generate a router skill that intelligently directs queries to the right sub-skill.

What the router does:

The generated router skill has this structure:

Result: project-complete.zip containing:

Each stream focuses on one knowledge domain:

Update any stream without affecting others:

Router analyzes user intent and routes to the right knowledge source(s).

Combines official docs + code reality + community insights for complete knowledge.

Only loads relevant sub-skill(s) for each question, not all knowledge at once.

Challenge: Official docs + 1M+ lines of code + 10K+ issues

Challenge: Private codebase + Confluence docs + JIRA issues

Challenge: Small codebase + great docs + active community

Create router_config.json to customize routing behavior:

For complex questions, route to multiple sub-skills:

Router can express confidence and route accordingly:

If question doesn’t match any sub-skill clearly:

Godot Engine Example (Three-Stream Architecture):

Cause: Sub-skill descriptions too similar or routing keywords overlap

Cause: User question doesn’t match any routing patterns

Cause: Router loading multiple sub-skills unnecessarily

Each sub-skill should have a distinct purpose:

Use clear, descriptive sub-skill names:

Choose keywords that clearly distinguish each sub-skill:

Update streams independently as needed:

Status: ✅ Production Ready (v2.6.0 - Three-Stream Architecture Complete!)

Found an issue or have suggestions? Open an issue

**Examples:**

Example 1 (unknown):
```unknown
skill-seekers-codebase path/to/repo/ \
  --output output/project-code/ \
  --extract-patterns \
  --extract-test-examples \
  --build-how-to-guides
```

Example 2 (unknown):
```unknown
skill-seekers scrape --config configs/project-docs.json
```

Example 3 (unknown):
```unknown
skill-seekers github owner/repo \
  --output output/project-github/ \
  --include-issues \
  --max-issues 200 \
  --include-changelog \
  --include-releases
```

Example 4 (sql):
```sql
# Generate router from existing skills
skill-seekers router \
  output/project-code/ \
  output/project-docs/ \
  output/project-github/ \
  --output output/project-router/ \
  --name "project-complete"
```

---
