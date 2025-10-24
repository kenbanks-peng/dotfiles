# OpenCode Configuration

This directory contains the OpenCode configuration for the multi-agent observability system, migrated from Claude Code.

## Directory Structure

```
.opencode/
├── opencode.json              # Main configuration file
├── agent/                     # Custom agent definitions
│   ├── fetch-docs-haiku45.md
│   └── fetch-docs-sonnet45.md
├── command/                   # Custom commands
│   ├── build.md
│   ├── prime.md
│   ├── quick-plan.md
│   ├── load_ai_docs.md
│   ├── start.md
│   ├── convert_paths_absolute.md
│   └── bench/
│       ├── find_and_summarize.md
│       ├── load_ai_docs.md
│       └── plan_new_feature.md
├── hooks/                     # Hook scripts and utilities (for reference)
│   ├── utils/
│   ├── *.py                   # Python hook scripts (Claude Code format)
│   └── examples/
├── plugin/                    # OpenCode plugins
│   ├── observability.ts       # Multi-agent observability plugin
│   └── package.json
└── README.md                  # This file

```

## Configuration

### opencode.json

The main configuration file that:
- References the observability plugin for event tracking
- Can be extended with additional agents, commands, and tools

### Agents

Two model-specific agents for documentation fetching:
- `fetch-docs-haiku45.md` - Uses Haiku 4.5 model for faster benchmarking
- `fetch-docs-sonnet45.md` - Uses Sonnet 4.5 model for higher quality

### Commands

Custom commands for the project:
- `/build` - Build codebase from a plan
- `/prime` - Understand codebase structure
- `/quick-plan` - Create quick implementation plans
- `/load_ai_docs` - Load documentation (benchmarking)
- `/start` - Start workflow
- `/convert_paths_absolute` - Convert paths to absolute

Benchmark commands in `bench/`:
- `find_and_summarize` - Find and summarize files
- `load_ai_docs` - AI documentation loading benchmark
- `plan_new_feature` - Planning feature implementation

## Observability System

### Multi-Agent Observability Plugin

The `plugin/observability.ts` file implements a TypeScript plugin that:

1. **Hooks into OpenCode Events**: Captures all significant events in the system
   - Session events (creation, updates, completion)
   - Message events (user prompts, AI responses)
   - Tool execution events (before/after)
   - File operation events

2. **Sends Events to Server**: Forwards events to the observability WebSocket server
   - Server endpoint: `http://localhost:4000/events`
   - Event format compatible with the client dashboard
   - Includes session IDs, timestamps, and model information

3. **Automatic Integration**: No manual configuration needed
   - Enabled in `opencode.json` via the `plugins` array
   - Runs automatically when OpenCode starts

### Event Flow

```
OpenCode Events
    ↓
Observability Plugin
    ↓
HTTP POST to localhost:4000/events
    ↓
Observability Server
    ↓
WebSocket to Client
    ↓
Dashboard Visualization
```

## Migration from Claude Code

### Key Changes

1. **Directory Naming**
   - `.claude/agents/` → `.opencode/agent/` (singular)
   - `.claude/commands/` → `.opencode/command/` (singular)

2. **Agent Configuration**
   - Removed `name` field (filename is now the agent name)
   - Added `mode: subagent`
   - Updated `model` to new format (`anthropic/claude-haiku-4-20250514`)
   - Converted `tools` to object format with boolean values

3. **Command Configuration**
   - Removed `argument-hint` field
   - Removed `allowed-tools` directives
   - Kept `description` field and command content

4. **Hooks & Observability**
   - Migrated from Claude Code hook scripts to OpenCode plugin system
   - Python hook scripts preserved in `hooks/` for reference
   - New TypeScript plugin provides automatic event tracking

## Setup Instructions

### Prerequisites

1. Node.js/Bun environment with TypeScript support
2. OpenCode CLI installed
3. Observability server running on `localhost:4000`

### Installation

1. Ensure OpenCode is configured in your project:
   ```bash
   opencode /init
   ```

2. Install plugin dependencies:
   ```bash
   cd .opencode/plugin
   npm install
   cd ../..
   ```

3. Start OpenCode:
   ```bash
   opencode
   ```

The observability plugin will automatically load and start capturing events.

## Testing

### Verify Plugin Loading

1. Start OpenCode: `opencode`
2. Check logs for: `[Observability] Plugin initialized`
3. Start the observability server: `cd apps/server && bun run dev`
4. Use the client dashboard: `cd apps/client && bun run dev`
5. Send a prompt to OpenCode and verify events appear in the dashboard

### Hook Testing (for debugging)

The `.opencode/hooks/` directory contains the original Claude Code hook scripts. These are provided for reference and can be tested with:

```bash
# Test send_event.py directly
echo '{"session_id": "test-123"}' | \
  uv run .opencode/hooks/send_event.py \
    --source-app cc-hook-multi-agent-obvs \
    --event-type TestEvent
```

## Environment Variables

The plugin uses these environment variables (optional):

- `OBSERVABILITY_SERVER_URL` - Override server endpoint (default: `http://localhost:4000/events`)

## Troubleshooting

### Plugin Not Loading

1. Check TypeScript syntax: `npx tsc --noEmit .opencode/plugin/observability.ts`
2. Verify plugin path is correct in `opencode.json`
3. Check OpenCode logs for plugin loading errors

### Events Not Reaching Server

1. Verify observability server is running: `curl http://localhost:4000/events`
2. Check network connectivity to localhost:4000
3. Inspect network traffic: `curl -X POST http://localhost:4000/events -d '{}'`
4. Enable debug logging in plugin (add console.log statements)

### TypeScript Compilation Errors

1. Ensure `@opencode-ai/plugin` is installed in `.opencode/plugin/`
2. Check TypeScript version compatibility
3. Install missing types: `npm install --save-dev @types/node`

## Future Improvements

1. **Enhanced Event Types**: Add more granular event categorization
2. **Event Filtering**: Allow selective event capturing based on patterns
3. **Local Storage**: Option to log events locally before sending
4. **Event Compression**: Reduce bandwidth for high-volume events
5. **Performance Metrics**: Track tool execution times and resource usage

## References

- [OpenCode Plugins Documentation](https://opencode.ai/docs/plugins)
- [OpenCode SDK Documentation](https://opencode.ai/docs/sdk)
- [Multi-Agent Observability System](../MIGRATION_PLAN.md)
- [Original Claude Code Configuration](./../.claude/)

## Notes

- The original `.claude/` configuration is preserved for reference and backward compatibility
- Python hook scripts in `.opencode/hooks/` can be adapted for other use cases
- The TypeScript plugin is the recommended approach for new OpenCode installations
