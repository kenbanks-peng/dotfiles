---
model: claude-sonnet-4-5-20250929
description: List all git worktrees with their configuration and status
allowed-tools: Bash, Read, Glob, Grep
---

# Purpose

List all git worktrees in the `trees/` directory with comprehensive information including branch names, directories, environment variables, dependencies, and build status.

## Variables

```
PROJECT_CWD: . (current working directory - the main project root)
WORKTREE_BASE_DIR: trees/
```

## Instructions

- List all worktrees managed by git
- For each worktree in trees/, gather configuration details
- Read environment files if present
- Check for installed dependencies
- Check for build artifacts
- Display comprehensive information in a clear, organized format
- Provide quick action commands for each worktree

## Workflow

### 1. List Git Worktrees

- Run: `git worktree list`
- Parse output to identify all worktrees
- Filter for worktrees in PROJECT_CWD/trees/ directory
- Extract:
  - Worktree path
  - Branch name
  - Commit hash (if available)

### 2. Gather Configuration for Each Worktree

For each worktree found in trees/:

**Extract Branch/Directory Info:**
- Worktree directory: `trees/<branch-name>`
- Branch name from git worktree list
- Working directory path

**Read Root Configuration:**
- Check if `<worktree>/.env` exists
- Note presence/absence (don't display sensitive values)

### 3. Check Dependencies

For each worktree, check for common dependency indicators:
- If package.json exists, check if `<worktree>/node_modules` exists
- If go.mod exists, check if go modules are downloaded (`go list -m all` succeeds)
- If requirements.txt exists, check if venv or virtualenv exists
- If Gemfile exists, check if `<worktree>/vendor` or gems are installed
- If Cargo.toml exists, check if `<worktree>/target` exists
- Note if dependencies are installed or missing

### 4. Check Build Artifacts

For each worktree:
- If justfile exists, look for common build directories (build/, dist/, target/, bin/)
- If Makefile exists, look for build artifacts based on common patterns
- Check for language-specific build outputs:
  - Go: build/, bin/, compiled binaries
  - Node: dist/, build/
  - Python: dist/, build/, *.egg-info
  - Rust: target/
  - Ruby: pkg/
- Note if build artifacts exist

### 5. Calculate Statistics

- Total number of worktrees
- Number with dependencies installed
- Number with build artifacts present

### 6. Report

Follow the Report section format below.

## Report

After gathering all information, provide a comprehensive report in the following format:

```
📊 Git Worktrees Overview

═══════════════════════════════════════════════════════════════

📈 Summary:
   Total Worktrees: <count>
   With Dependencies: <count>
   With Build Artifacts: <count>

═══════════════════════════════════════════════════════════════

🌳 Main Repository (Default)
   📁 Location: <project-root>
   🌿 Branch: <current-branch>
   ⚙️  Config: <✓ .env exists | ❌ No .env>

───────────────────────────────────────────────────────────────

🌳 Worktree: <branch-name>
   📁 Location: trees/<branch-name>
   🌿 Branch: <branch-name>
   📝 Commit: <commit-hash-short>

   ⚙️  Configuration:
   └─ Environment: <✓ .env exists | ❌ No .env>

   📦 Dependencies:
   └─ Status: <✓ Installed | ❌ Not installed | ℹ️  Not applicable>
   └─ Type: <npm/go/pip/bundler/cargo/composer if detected>

   🔨 Build Artifacts:
   └─ Status: <✓ Found | ❌ Not found>
   └─ Location: <path to build artifacts if found>

   Actions:
   ├─ Navigate: cd trees/<branch-name>
   ├─ Build: [show project-specific build command if justfile/Makefile exists]
   └─ Remove: /remove_worktree <branch-name>

───────────────────────────────────────────────────────────────

[Repeat for each worktree]

═══════════════════════════════════════════════════════════════

💡 Quick Commands:

Create new worktree:
└─ /create_worktree <branch-name>

Remove worktree:
└─ /remove_worktree <branch-name>

Navigate to worktree:
└─ cd trees/<branch-name>

View this list again:
└─ /list_worktrees

═══════════════════════════════════════════════════════════════
```

If no worktrees exist in trees/:

```
📊 Git Worktrees Overview

═══════════════════════════════════════════════════════════════

🌳 Main Repository (Default)
   📁 Location: <project-root>
   🌿 Branch: <current-branch>

═══════════════════════════════════════════════════════════════

ℹ️  No worktrees found in trees/ directory

💡 Create your first worktree:
   /create_worktree <branch-name>

   This will:
   • Create isolated git worktree
   • Install dependencies
   • Build the project
   • Set up environment configuration

═══════════════════════════════════════════════════════════════
```

If worktrees have configuration issues:

```
⚠️  Configuration Warnings:

• trees/<branch-name>: Missing .env file
  └─ Fix: Copy from main repo or recreate with /create_worktree <branch-name>

• trees/<branch-name>: Dependencies not installed
  └─ Fix: cd trees/<branch-name> && [run appropriate dependency install command]

• trees/<branch-name>: Build artifacts not found
  └─ Fix: cd trees/<branch-name> && [run appropriate build command]
```

## Notes

- Main repository is always shown first
- Worktrees are sorted alphabetically by branch name
- Dependency and build status is checked at the time of listing
- Orphaned worktrees (in git but not in trees/) are noted
- All commands are copy-paste ready
- Environment files are detected but values are not displayed (may contain secrets)
