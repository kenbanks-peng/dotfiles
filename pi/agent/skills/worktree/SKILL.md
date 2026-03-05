---
name: worktree
description: Manage parallel feature development using git worktrees via worktrunk (wt). Use when the user wants to create, switch, list, merge, or remove worktrees, run multiple AI agents in parallel on separate branches, or manage a multi-branch workflow. Covers wt switch, wt list, wt merge, wt remove, wt step, wt hook, and wt config.
---

# Worktree Management with Worktrunk

Worktrunk (`wt`) makes git worktrees as easy as branches. Each worktree gets its own working directory so multiple features (or AI agents) can run in parallel without conflicts.

## Quick Reference

### Create a new feature worktree

```bash
wt switch --create feature-name        # Create branch + worktree, cd into it
wt switch -c feature-name              # Short form
wt switch -c fix --base release        # Branch from a specific base
wt switch -c feat -x claude -- 'prompt' # Create + launch agent with prompt
```

### Switch between worktrees

```bash
wt switch feature-name     # Switch to existing worktree
wt switch -                # Previous worktree (like cd -)
wt switch ^                # Default branch (main/master)
wt switch @                # Current worktree
wt switch pr:123           # GitHub PR branch
wt switch                  # Interactive picker (no args)
```

### List all worktrees

```bash
wt list                    # Table with status symbols
wt list --full             # Include CI status, line diffs, LLM summaries
wt list --branches         # Include branches without worktrees
wt list --format=json      # JSON output for scripting
```

**Status symbols quick guide:**
- `+` staged, `!` modified, `?` untracked
- `^` default branch, `↑` ahead, `↓` behind, `↕` diverged
- `⇡` ahead of remote, `⇣` behind remote
- `_` same commit as default (safe to delete), `⊂` integrated

### Merge back to default branch

```bash
wt merge                   # Squash + rebase + merge + cleanup (full pipeline)
wt merge develop           # Merge into specific target
wt merge --no-squash       # Preserve commit history
wt merge --no-remove       # Keep worktree after merge
wt merge --no-commit       # Skip auto-commit (manual commits only)
```

The merge pipeline: stage → squash → rebase → pre-merge hooks → fast-forward → cleanup.

### Remove a worktree

```bash
wt remove                  # Remove current worktree
wt remove feature-name     # Remove specific worktree
wt remove -D experimental  # Force-delete unmerged branch
wt remove --force          # Remove even with untracked files
wt remove --no-delete-branch feature  # Keep the branch
```

### Individual steps (building blocks of merge)

```bash
wt step commit             # Stage + commit with LLM-generated message
wt step squash             # Squash all branch commits into one
wt step rebase             # Rebase onto target branch
wt step push               # Fast-forward target to current branch
wt step diff               # Show all changes since branching
wt step copy-ignored       # Copy gitignored files between worktrees
wt step for-each "cmd"     # Run command in every worktree
wt step prune              # Remove worktrees merged into default
```

## Parallel Agent Workflow

Launch multiple agents on separate features simultaneously:

```bash
# Create worktrees and launch agents in each
wt switch -x claude -c feature-a -- 'Add user authentication'
wt switch -x claude -c feature-b -- 'Fix the pagination bug'
wt switch -x claude -c feature-c -- 'Write tests for the API'

# Monitor progress
wt list --full

# When agents finish, review and merge each
wt switch feature-a
# ... review changes ...
wt merge

wt switch feature-b
wt merge
# etc.
```

## Hooks

Hooks automate tasks at key lifecycle points. Configure in `.config/wt.toml` (project, committed) or `~/.config/worktrunk/config.toml` (user, personal).

### Hook types

| Hook | When | Blocking |
|------|------|----------|
| `pre-switch` | Before every switch | Yes |
| `post-create` | After worktree created | Yes (blocks) |
| `post-start` | After worktree created | No (background) |
| `post-switch` | After every switch | No (background) |
| `pre-commit` | Before commit during merge | Yes |
| `pre-merge` | Before merging to target | Yes |
| `post-merge` | After successful merge | Yes |
| `pre-remove` | Before worktree removed | Yes |
| `post-remove` | After worktree removed | No (background) |

### Example project config (`.config/wt.toml`)

```toml
# Install deps when worktree is created
[post-create]
deps = "npm ci"

# Copy build caches in background
[post-start]
copy = "wt step copy-ignored"
server = "npm run dev -- --port {{ branch | hash_port }}"

# Validate before merge
[pre-merge]
test = "npm test"
build = "npm run build"

# Show dev server URL in wt list
[list]
url = "http://localhost:{{ branch | hash_port }}"
```

### Template variables in hooks

| Variable | Description |
|----------|-------------|
| `{{ repo }}` | Repository directory name |
| `{{ branch }}` | Branch name |
| `{{ worktree_path }}` | Absolute worktree path |
| `{{ default_branch }}` | Default branch name |
| `{{ target }}` | Target branch (merge hooks) |
| `{{ base }}` | Base branch (creation hooks) |

### Template filters

| Filter | Example | Description |
|--------|---------|-------------|
| `sanitize` | `{{ branch \| sanitize }}` | Replace `/` and `\` with `-` |
| `hash_port` | `{{ branch \| hash_port }}` | Deterministic port 10000-19999 |
| `sanitize_db` | `{{ branch \| sanitize_db }}` | Database-safe identifier |

### Run hooks manually

```bash
wt hook pre-merge              # Run all pre-merge hooks
wt hook pre-merge test         # Run specific hook by name
wt hook post-create --yes      # Skip approval prompts
```

## Configuration

### User config (`~/.config/worktrunk/config.toml`)

```toml
# Where worktrees are created (default: sibling directory)
worktree-path = "{{ repo_path }}/../{{ repo }}.{{ branch | sanitize }}"

# Or inside the repo
# worktree-path = "{{ repo_path }}/.worktrees/{{ branch | sanitize }}"

# LLM commit message generation
[commit.generation]
command = "claude -p --model=haiku"
```

### Shell integration (required for cd)

```bash
wt config shell install
```

### Show current config

```bash
wt config show
```

## Common Workflows

### PR workflow

```bash
wt switch -c feature           # Create feature branch
# ... make changes ...
wt step commit                 # Commit with LLM message
gh pr create                   # Open PR
# After PR merges on GitHub:
wt remove                      # Clean up
```

### Local merge workflow

```bash
wt switch -c feature           # Create feature branch
# ... make changes ...
wt merge                       # Squash + rebase + merge + cleanup
```

### Review an open PR

```bash
wt switch pr:123               # Checkout PR's branch into a worktree
# ... review, test, make changes ...
wt remove                      # Clean up when done
```

### Clean up stale worktrees

```bash
wt list                        # Check status (dimmed = safe to delete)
wt step prune                  # Auto-remove merged worktrees
wt remove old-branch           # Remove specific ones
```

## JSON Scripting

```bash
# Current worktree path
wt list --format=json | jq -r '.[] | select(.is_current) | .path'

# Branches with uncommitted changes
wt list --format=json | jq '.[] | select(.working_tree.modified)'

# Branches ahead of main
wt list --format=json | jq '.[] | select(.main.ahead > 0) | .branch'

# Integrated branches (safe to remove)
wt list --format=json | jq '.[] | select(.main_state == "integrated") | .branch'
```

## Tips

- **Always run `wt config shell install`** first — without it, `wt switch` can't change directories.
- **Use `wt list` frequently** to see the state of all worktrees at a glance.
- **Set up `post-create` hooks** for dependency installation so new worktrees are ready immediately.
- **Use `wt step copy-ignored`** in `post-start` hooks to share `node_modules/`, `target/`, etc. between worktrees (avoids cold builds).
- **Pre-merge hooks** act as local CI — add tests/lints to catch issues before merging.
- **`wt merge` is opinionated** — it squashes by default. Use `--no-squash` to preserve history.
- **Background removal** — `wt remove` returns immediately by default; logs go to `.git/wt-logs/`.
