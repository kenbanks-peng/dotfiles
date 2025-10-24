# OpenCode Formats

## Agent Definition

**Global**: `~/.config/opencode/agent/*.md`
**Project**: `.opencode/agent/*.md`

**Markdown Format**:
```markdown
---
description: Reviews code for quality and best practices
mode: subagent | primary | all
model: provider/model-id
temperature: 0.0-1.0
tools:
  write: true | false
  edit: true | false
  bash: true | false
  tool-name: true | false
permission:
  edit: ask | allow | deny
  bash: ask | allow | deny
  bash "pattern-name": ask | allow | deny
  webfetch: ask | allow | deny
disable: true | false
---

Custom system prompt text for the agent.
```

**Notes**:
- `mode` - Agent availability: `subagent` (task tool only), `primary` (user-selectable), `all` (both, default)
- `temperature` - Randomness (0.0-1.0, defaults: 0 for most models, 0.55 for Qwen)
- Markdown filename becomes agent name
- Agent-specific tool config overrides global config
- Additional options are passed through to provider as model options

## Command Definition

**Global**: `~/.config/opencode/command/*.md`
**Project**: `.opencode/command/*.md`

```markdown
---
description: What this command does
agent: agent-name
model: provider/model
subtask: true | false
---

Command template content with $ARGUMENTS or other variables.
```

**Notes**:
- Filename becomes command name (e.g., `build.md` → `/build`)
- Use `$VARIABLE_NAME` or `$ARGUMENTS` for substitution

## Event Types

- `installation.updated` (version)
- `lsp.client.diagnostics` (serverID, path)
- `message.updated` (info)
- `message.removed` (sessionID, messageID)
- `message.part.updated` (part)
- `message.part.removed` (sessionID, messageID, partID)
- `session.compacted` (sessionID)
- `session.updated` (info)
- `session.deleted` (info)
- `session.idle` (sessionID)
- `session.error` (sessionID, error)
- `permission.updated` (Permission object)
- `permission.replied` (sessionID, permissionID, response)
- `file.edited` (file)
- `file.watcher.updated` (file, event)
- `todo.updated` (sessionID, todos)
- `server.connected`
- `ide.installed` (ide)

## Message Parts

**text** - `{ type: "text", text: string, synthetic?: boolean, time?: { start, end? }, metadata? }`

**reasoning** - `{ type: "reasoning", text: string, time: { start, end? }, metadata? }`

**file** - `{ type: "file", mime: string, filename?: string, url: string, source?: FilePartSource }`

**tool** - `{ type: "tool", callID: string, tool: string, state: ToolState, metadata? }`
- Pending: `{ status: "pending" }`
- Running: `{ status: "running", input, title?, metadata?, time: { start } }`
- Completed: `{ status: "completed", input, output, title, metadata, time: { start, end, compacted? }, attachments?: FilePart[] }`
- Error: `{ status: "error", input, error, metadata?, time: { start, end } }`

**step-start** - `{ type: "step-start", snapshot? }`

**step-finish** - `{ type: "step-finish", snapshot?, cost, tokens: { input, output, reasoning, cache } }`

**snapshot** - `{ type: "snapshot", snapshot }`

**patch** - `{ type: "patch", hash, files: string[] }`

**agent** - `{ type: "agent", name, source?: { value, start, end } }`

## Plugin

**Global**: `~/.config/opencode/plugin/*.ts`
**Project**: `.opencode/plugin/*.ts`

```typescript
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // Handle event by checking event.type
      if (event.type === "session.idle") {
        // Handle specific event
      }
    },
    "tool.execute.before": async (input, output) => {
      // Hook before tool execution
    },
    "tool.execute.after": async (input, output) => {
      // Hook after tool execution
    }
  }
}
```

**Notes**:
- Plugin function receives: `project`, `client`, `$`, `directory`, `worktree`
- Return object with hook implementations
- Available hooks: `event`, `tool.execute.before`, `tool.execute.after`
