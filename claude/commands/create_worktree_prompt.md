---
model: claude-sonnet-4-5-20250929
description: Create a git worktree with isolated configuration for parallel development
argument-hint: [branch-name]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Purpose

Create a new git worktree in the `trees/` directory with completely isolated configuration for parallel development. This enables working on multiple branches simultaneously with isolated dependencies and build artifacts.

## Variables

```
PROJECT_CWD: . (current working directory - the main project root)
BRANCH_NAME: $1 (required)
WORKTREE_BASE_DIR: trees/
WORKTREE_DIR: trees/<BRANCH_NAME>
```

## Instructions

- Creates a fully functional, isolated clone of the codebase in a separate worktree
- All environment configuration is worktree-specific
- Dependencies are installed automatically for each worktree
- Build artifacts are isolated per worktree
- If branch doesn't exist locally, create it from current HEAD
- If branch exists but isn't checked out, create worktree from it
- Validation ensures the worktree is ready for development

## Workflow

### 1. Parse and Validate Arguments

- Read BRANCH_NAME from $1, error if missing
- Validate branch name format (no spaces, valid git branch name)

### 2. Pre-Creation Validation

- Check if PROJECT_CWD/trees/ directory exists, create if not: `mkdir -p trees`
- Verify trees/ is in PROJECT_CWD/.gitignore (should be there already)
- Check if worktree already exists at WORKTREE_DIR
- Check if branch exists: `git branch --list <BRANCH_NAME>`
  - If branch doesn't exist, will create it in next step
  - If branch exists, will checkout to create worktree

### 3. Create Git Worktree

- From PROJECT_CWD, create worktree with: `git worktree add trees/<BRANCH_NAME> <BRANCH_NAME>`
  - If branch doesn't exist, this creates it from HEAD
  - If branch exists, this checks it out in the worktree
  - This creates WORKTREE_DIR at PROJECT_CWD/trees/<BRANCH_NAME>
- Verify worktree was created: `git worktree list | grep trees/<BRANCH_NAME>`
- All subsequent operations will reference WORKTREE_DIR (which is PROJECT_CWD/trees/<BRANCH_NAME>)

### 4. Setup Root Environment File

- Check if root .env exists in main project at PROJECT_CWD/.env
- If PROJECT_CWD/.env exists:
  - Copy it to worktree root: `cp <PROJECT_CWD>/.env <WORKTREE_DIR>/.env`
  - Note: This preserves any API keys or environment-specific configuration
- If PROJECT_CWD/.env doesn't exist:
  - Copy .env.sample if available: `cp <PROJECT_CWD>/.env.sample <WORKTREE_DIR>/.env`
  - Add warning to report that user needs to configure environment variables

### 5. Install Dependencies (if applicable)

- Check if the project has dependency management files and install accordingly:
  - If package.json exists: `cd <WORKTREE_DIR> && npm install`
  - If go.mod exists: `cd <WORKTREE_DIR> && go mod download`
  - If requirements.txt exists: `cd <WORKTREE_DIR> && pip install -r requirements.txt`
  - If Gemfile exists: `cd <WORKTREE_DIR> && bundle install`
  - If Cargo.toml exists: `cd <WORKTREE_DIR> && cargo fetch`
  - If composer.json exists: `cd <WORKTREE_DIR> && composer install`
- Return to worktree root: `cd <WORKTREE_DIR>`

### 6. Build (if applicable)

- If a justfile exists, attempt to build:
  - `cd <WORKTREE_DIR> && just build`
  - Note any build output or artifacts created
- If a Makefile exists and no justfile:
  - `cd <WORKTREE_DIR> && make`
  - Note any build output or artifacts created
- This ensures the worktree is immediately ready for development

### 7. Validation

- Verify directory structure:
  - Confirm WORKTREE_DIR exists
  - Confirm WORKTREE_DIR/.env exists at root (if applicable)
- List worktrees to confirm: `git worktree list`
- Read back the created env file to confirm values are correct (if applicable)

### 8. Report

Follow the Report section format below to provide comprehensive setup information.

## Report

After successful worktree creation, validation, and setup, provide a detailed report in the following format:

```
✅ Git Worktree Created Successfully!

📁 Worktree Details:
   Location: trees/<BRANCH_NAME>
   Branch: <BRANCH_NAME>
   Status: 🟢 READY

📦 Dependencies:
   ✓ [List what was installed, e.g., "Dependencies installed" or "No dependencies found"]

🔨 Build:
   ✓ [If build ran: "Project built successfully" + note artifacts]
   ℹ️  [If no build: "No build configuration found"]

⚙️  Environment Files:
   ✓ [If .env exists: "Root .env (WORKTREE_DIR/.env)"]
   ℹ️  [If no .env: "No environment file found"]

📝 Important Notes:
   • This worktree is completely isolated from the main codebase
   • You can run multiple worktrees simultaneously
   • Each worktree has its own dependencies and build artifacts

🎯 Common Commands:

   # Navigate to worktree
   cd trees/<BRANCH_NAME>

   # [List project-specific commands if available, e.g.:]
   # If justfile exists: just build, just test, just deploy
   # If Makefile exists: make, make test
   # If package.json exists: npm run build, npm test

🗑️  To Remove This Worktree:

   # Remove the worktree:
   git worktree remove trees/<BRANCH_NAME>

   # Or force remove if needed:
   git worktree remove trees/<BRANCH_NAME> --force

🎉 Next Steps:
   1. cd trees/<BRANCH_NAME>
   2. Make your changes
   3. Build and test as needed
   4. Commit and push when ready
```

If any validation steps failed or warnings occurred, include an additional section:

```
⚠️  Warnings / Action Required:
- <List any warnings or actions the user needs to take>
```
