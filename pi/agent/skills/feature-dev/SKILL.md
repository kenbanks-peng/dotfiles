---
name: feature-dev
description: Agent-driven feature development workflow using git worktrees. Use when the user asks to build a feature, fix a bug, or make changes that should be done on a separate branch. The agent autonomously creates a worktree, implements changes, tests, commits, and optionally merges — without requiring step-by-step prompting. Depends on the worktree skill for command reference.
---

# Feature Development Workflow

This skill defines an autonomous, agent-driven workflow for developing features and fixes using git worktrees managed by worktrunk (`wt`). The agent drives each phase to completion, only pausing for user input when a decision or review is genuinely needed.

Read the `worktree` skill for full command reference when needed.

## Workflow Phases

### Phase 1: Setup

When the user describes work to be done:

1. **Determine branch name** — Derive a descriptive kebab-case branch name from the task (e.g., `add-user-auth`, `fix-pagination-bug`). Ask only if ambiguous.
2. **Check current state** — Run `wt list` to see existing worktrees. Avoid name collisions.
3. **Create the worktree** — Run `wt switch --create <branch-name>` to create the branch and worktree and cd into it.
4. **Verify environment** — Confirm you're in the new worktree. If the project has a build/install step, run it.

### Phase 2: Implementation

Proceed autonomously through implementation:

1. **Understand the codebase** — Read relevant files to understand the existing code structure and patterns.
2. **Plan the changes** — Identify which files need to be created or modified. For complex work, outline the plan briefly to the user before starting.
3. **Implement** — Make all necessary code changes. Follow existing code style and conventions.
4. **Validate** — After implementation:
   - Run the project's test suite if one exists
   - Run linters/formatters if configured
   - Fix any issues found — do not leave broken tests or lint errors
   - Repeat until clean

Do NOT stop after each file edit to ask if you should continue. Complete the full implementation, then validate.

### Phase 3: Commit

Once implementation is validated:

1. **Review changes** — Run `wt step diff` to see all changes since branching.
2. **Commit** — Run `wt step commit` to stage and commit with an LLM-generated message. If `wt step commit` is not configured or fails, use `git add -A && git commit -m "<message>"` with a clear, imperative-mood commit message.

### Phase 4: Deliver

Present the completed work to the user:

1. **Summarize what was done** — List the files changed, what was added/modified, and any decisions made.
2. **Report test results** — Confirm tests pass, or note any issues.
3. **Offer next steps** — Ask the user what they'd like to do:
   - **Merge locally** → Run `wt merge` (squash + rebase + fast-forward + cleanup)
   - **Open a PR** → Run `git push -u origin <branch>` then `gh pr create` (if `gh` is available)
   - **Keep working** → Stay in the worktree for further changes
   - **Discard** → Run `wt remove -D` to clean up

## Multi-Feature Workflow

When the user describes multiple features or tasks at once:

1. **List the tasks** — Confirm the set of features/fixes to be worked on.
2. **Work sequentially** — For each task, run the full workflow (Setup → Implement → Commit → Deliver) before moving to the next. Present a summary after each.
3. **Final summary** — After all tasks, run `wt list` and present the overall state. Offer to merge all, merge selectively, or keep them as separate branches.

> **Note:** Since this agent operates in a single session, true parallelism (multiple agents simultaneously) requires the user to launch separate agent sessions. This skill handles the sequential case. To help the user set up parallel agents, suggest the `wt switch -x` pattern from the worktree skill.

## Error Handling

- **Merge conflicts during `wt merge`** — Report the conflict to the user with the conflicting files. Offer to resolve manually or abort with `git rebase --abort`.
- **Test failures** — Attempt to fix the failing tests (up to 2 retry cycles). If still failing after retries, report the failures and ask the user how to proceed.
- **Build failures** — Same as test failures: attempt to fix, report if unable.
- **Worktree already exists** — If the branch name is taken, `wt switch <branch>` to it and ask the user if they want to continue from where it left off or `wt remove` and start fresh.

## Guidelines

- **Be autonomous** — Drive the workflow forward. Don't ask "should I continue?" between phases.
- **Be transparent** — Show command output for key steps (test results, merge output). Don't hide failures.
- **Be safe** — Never force-push. Never merge without tests passing (if tests exist). Never delete unmerged work without confirmation.
- **Stay in the worktree** — All implementation work happens in the feature worktree, not on the default branch.
- **Clean up** — After a successful merge, the worktree is automatically removed by `wt merge`. Don't leave orphaned worktrees.
