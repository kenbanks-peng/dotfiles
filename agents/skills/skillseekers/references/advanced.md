# Advanced Features

## Workflow Presets (v3.1.0)

Enhancement workflows control how AI improves your skill.

```bash
skill-seekers workflows list                    # List presets
skill-seekers workflows show <name>             # View details
skill-seekers create <src> --enhance-workflow <name>  # Use during create
skill-seekers create <src> --enhance-workflow minimal --enhance-workflow api-documentation  # Chain
```

Bundled presets: `default`, `minimal`, `security-focus`, `architecture-comprehensive`, `api-documentation`.

### Custom Workflows

```yaml
name: "custom-security"
description: "Custom security analysis"
stages:
  - name: "Vulnerability Scan"
    prompt: "Analyze the code for security vulnerabilities..."
    model: "claude-sonnet-4"
    temperature: 0.2
```

```bash
skill-seekers workflows add my-workflow.yaml
```

## Large Documentation (10K+ pages)

```bash
# Estimate first
skill-seekers estimate --config configs/large.json

# Category-based split
skill-seekers scrape --config configs/k8s-concepts.json --output output/k8s-concepts/
skill-seekers scrape --config configs/k8s-tasks.json --output output/k8s-tasks/
skill-seekers scrape --config configs/k8s-api.json --output output/k8s-api/

# Create router from sub-skills
skill-seekers router output/k8s-concepts/ output/k8s-tasks/ output/k8s-api/ \
  --output output/k8s-router/ --name kubernetes-complete

# Or auto-split
skill-seekers scrape --config configs/large.json --auto-split --max-tokens 50000
```

Worker guidelines: `--workers 4` for <1K pages, `8` for 1K-10K, `16` for 10K+.

Use `--checkpoint` for large scrapes to enable resume on interruption.

## MCP Server

Natural language interaction with Skill Seekers via Claude Code.

```bash
# Auto setup
git clone https://github.com/yusufkaraaslan/Skill_Seekers.git && cd Skill_Seekers
./setup_mcp.sh
```

### Manual Setup

Add to Claude MCP config (`~/Library/Application Support/Claude/mcp.json` on macOS):

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

Test: `python -m skill_seekers.mcp.server_fastmcp` (stdio) or `--http --port 3000` (HTTP).

MCP tools: `scrape_docs`, `scrape_github`, `scrape_pdf`, `analyze_codebase`, `enhance_skill`, `package_skill`, `upload_skill`, `generate_config`, `list_configs`, `validate_config`, `estimate_pages`.

## Git Config Sources (v2.2.0)

Share scraping configs via git repositories.

```bash
# Add source
skill-seekers add-git-source https://github.com/org/configs.git --name company --branch main

# Private repo
skill-seekers add-git-source https://github.com/org/private.git --name private --token ghp_...

# Use
skill-seekers scrape --config company:react.json

# Manage
skill-seekers list-git-sources
skill-seekers fetch-git-sources
skill-seekers remove-git-source company
```

Cloned to `~/.skill-seekers/git-sources/`.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `command not found` | Ensure pip bin is in PATH. Try `python -m skill_seekers` |
| `ModuleNotFoundError` | `pip install requests bs4 mcp` |
| Empty scrape results | Check CSS selectors. Use `scrape --interactive` to test |
| MCP tools missing | Restart Claude Code. Use absolute paths in config |
| GitHub rate limited | Set `GITHUB_TOKEN` (60 → 5000 req/hr). Use `config --github` for multi-profile |
