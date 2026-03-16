# Configuration Schema

Unified config format (v2.6.0+). Legacy single-source configs are auto-converted.

## Top-Level Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (kebab-case) |
| `description` | Yes | Human-readable description |
| `sources` | Yes | Array of source configs (min 1) |
| `merge_mode` | No | `rule-based` (default) or `claude-enhanced` |

## Documentation Source

```json
{
  "type": "documentation",
  "base_url": "https://docs.example.com/",
  "extract_api": false,
  "max_pages": 200,
  "rate_limit": 0.5,
  "seed_urls": ["https://docs.example.com/guide/"],
  "selectors": {
    "main_content": "article",
    "title": "h1",
    "code_blocks": "pre code"
  },
  "url_patterns": {
    "include": ["/docs/", "/api/"],
    "exclude": ["/blog/", "/changelog/"]
  },
  "categories": {
    "getting_started": ["intro", "setup", "install"],
    "api": ["api", "reference", "function"]
  }
}
```

| Field | Description |
|-------|-------------|
| `base_url` | Root URL to scrape |
| `extract_api` | Extract API reference sections separately |
| `max_pages` | Page limit (unlimited by default since v2.6.0) |
| `rate_limit` | Delay between requests (seconds) |
| `seed_urls` | Specific start URLs (bypasses auto-discovery) |
| `selectors` | CSS selectors for content extraction |
| `url_patterns` | Include/exclude URL path patterns |
| `categories` | Keyword-based page categorization |

## GitHub Source

```json
{
  "type": "github",
  "repo": "facebook/react",
  "enable_codebase_analysis": true,
  "code_analysis_depth": "surface",
  "fetch_issues": true,
  "max_issues": 100,
  "include_changelog": true,
  "include_releases": false,
  "file_patterns": ["**/*.py", "**/*.js"]
}
```

| Field | Description |
|-------|-------------|
| `repo` | Repository (owner/name) |
| `enable_codebase_analysis` | Enable C3.x AST parsing |
| `code_analysis_depth` | `surface` (fast), `deep`, `full` |
| `fetch_issues` | Include GitHub issues |
| `max_issues` | Issue limit (100 recommended) |
| `include_changelog` | Extract CHANGELOG.md |
| `include_releases` | Include GitHub releases |
| `file_patterns` | Glob patterns for file analysis |

## PDF Source

```json
{
  "type": "pdf",
  "pdf_path": "docs/manual.pdf",
  "ocr": false,
  "password": null,
  "extract_tables": false,
  "parallel": false
}
```

| Field | Description |
|-------|-------------|
| `pdf_path` | Path to PDF file |
| `ocr` | Enable OCR for scanned PDFs |
| `password` | Decryption password |
| `extract_tables` | Extract tables as structured data |
| `parallel` | Parallel processing (auto for >5 pages) |

## Full Example

```json
{
  "name": "react",
  "description": "Complete React knowledge from docs and codebase",
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
      "enable_codebase_analysis": true,
      "code_analysis_depth": "surface",
      "max_issues": 100
    },
    {
      "type": "pdf",
      "pdf_path": "docs/manual.pdf",
      "extract_tables": true
    }
  ]
}
```
