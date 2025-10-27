import type { Plugin } from "@opencode-ai/plugin";

const OBSERVABILITY_SERVER_URL = "http://localhost:4000/events";

const EVENT_ENABLED: Record<string, boolean> = {
	"installation.updated": false,
	"lsp.client.diagnostics": false,
	"message.updated": true,
	"message.removed": false,
	"message.part.updated": false,
	"message.part.removed": false,
	"session.compacted": true,
	"session.updated": true,
	"session.deleted": true,
	"session.idle": true,
	"session.error": true,
	"permission.updated": false,
	"permission.replied": false,
	"file.edited": true,
	"file.watcher.updated": false,
	"todo.updated": true,
	"server.connected": true,
	"ide.installed": true,
	"tool.execute.before": true,
	"tool.execute.after": true,
};

interface EventData {
	source_app: string;
	session_id: string;
	hook_event_type: string;
	payload: any;
	timestamp: number;
	model_name?: string;
	summary?: string;
	project?: string;
	directory?: string;
	worktree?: string;
}

/*
 * OpenCode Event Types (from FORMATS.md):
 * - installation.updated
 * - lsp.client.diagnostics
 * - message.updated - Fires when a complete message is added (user OR assistant)
 *   * For user prompt detection: check message.role === "user"
 * - message.removed
 * - message.part.updated - Fires during ASSISTANT streaming (NOT for user input)
 *   * Contains incremental text deltas as AI responds
 *   * NOT suitable for detecting user prompt submission
 * - message.part.removed
 * - session.compacted
 * - session.updated
 * - session.deleted
 * - session.idle
 * - session.error
 * - permission.updated
 * - permission.replied
 * - file.edited
 * - file.watcher.updated
 * - todo.updated
 * - server.connected
 * - ide.installed
 * And tool execution events are handled by tool.execute.before and tool.execute.after hooks
 */
export const ObservabilityPlugin: Plugin = async ({
	project,
	directory,
	worktree,
	client: _client,
	$: _$,
}) => {
	// Capture context information from plugin args
	const projectId = project?.id || "unknown";
	const workingDirectory = directory || "unknown";
	const gitWorktree = worktree || "unknown";

	async function sendEventToServer(eventData: EventData): Promise<boolean> {
		try {
			const response = await fetch(OBSERVABILITY_SERVER_URL, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"User-Agent": "OpenCode-Plugin/1.0",
				},
				body: JSON.stringify(eventData),
			});
			return response.ok;
		} catch {
			return false;
		}
	}

	function getSessionId(event: any): string {
		if (event.properties?.sessionID) return event.properties.sessionID;
		if (event.properties?.info?.id) return event.properties.info.id;
		if (event.sessionID) return event.sessionID;
		if (event.session?.id) return event.session.id;
		if (event.id) return event.id;
		return "unknown";
	}

	function getModelName(event: any): string {
		if (event.properties?.info?.model?.id) return event.properties.info.model.id;
		if (event.properties?.model?.id) return event.properties.model.id;
		if (event.model?.id) return event.model.id;
		if (event.model?.modelID) return event.model.modelID;
		if (event.modelID) return event.modelID;
		return "";
	}

	return {
		event: async ({ event }) => {
			if (!EVENT_ENABLED[event.type]) return;

			const eventData: EventData = {
				source_app: "opencode-multi-agent-obvs",
				session_id: getSessionId(event),
				hook_event_type: event.type,
				payload: event,
				timestamp: Date.now(),
				model_name: getModelName(event),
				project: projectId,
				directory: workingDirectory,
				worktree: gitWorktree,
			};

			if (event.type === "message.updated") {
				const message = event.properties?.info;
				if (message?.role === "user") {
					const userPrompt = message.summary?.body || "";
					eventData.summary = `User prompt: ${userPrompt.slice(0, 100)}${userPrompt.length > 100 ? "..." : ""}`;
				}
			}

			await sendEventToServer(eventData);
		},

		"tool.execute.before": async (input, output) => {
			if (!EVENT_ENABLED["tool.execute.before"]) return;

			const sessionId = input.session?.id || input.sessionID || "unknown";
			const modelName = input.session?.model?.id || input.model?.id || "";

			const eventData: EventData = {
				source_app: "opencode-multi-agent-obvs",
				session_id: sessionId,
				hook_event_type: "tool.execute.before",
				payload: {
					tool: input.tool,
					args: output.args,
					input: input,
					timestamp: new Date().toISOString(),
				},
				timestamp: Date.now(),
				model_name: modelName,
				project: projectId,
				directory: workingDirectory,
				worktree: gitWorktree,
			};

			await sendEventToServer(eventData);
		},

		"tool.execute.after": async (input, output) => {
			if (!EVENT_ENABLED["tool.execute.after"]) return;

			const sessionId = input.session?.id || input.sessionID || "unknown";
			const modelName = input.session?.model?.id || input.model?.id || "";

			const eventData: EventData = {
				source_app: "opencode-multi-agent-obvs",
				session_id: sessionId,
				hook_event_type: "tool.execute.after",
				payload: {
					tool: input.tool,
					input: input,
					title: output.title,
					output: output.output,
					metadata: output.metadata,
					timestamp: new Date().toISOString(),
				},
				timestamp: Date.now(),
				model_name: modelName,
				project: projectId,
				directory: workingDirectory,
				worktree: gitWorktree,
			};

			await sendEventToServer(eventData);
		},
	};
};
