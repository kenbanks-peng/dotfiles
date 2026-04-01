// index.ts
import { execSync } from "child_process";
import { randomUUID } from "crypto";
var OAUTH_DUMMY_KEY = "opencode-oauth-dummy-key";
var CLI_VERSION = "2.1.81";
var SDK_VERSION = "0.74.0";
var API_BASE = "https://api.anthropic.com";
var ANTHROPIC_VERSION = "2023-06-01";
var SDK_EVAL_KEY = "sdk-zAZezfDKGoZuXXKe";
var DEVICE_ID = randomUUID();
var BETA_FLAGS = [
  "oauth-2025-04-20",
  "interleaved-thinking-2025-05-14",
  "redact-thinking-2026-02-12",
  "context-management-2025-06-27",
  "prompt-caching-scope-2026-01-05"
].join(",");
var MCP_BETA = "mcp-servers-2025-12-04";
function getStainlessHeaders() {
  return {
    "x-stainless-arch": process.arch,
    "x-stainless-os": process.platform === "darwin" ? "MacOS" : process.platform,
    "x-stainless-runtime": "node",
    "x-stainless-runtime-version": process.versions.node,
    "x-stainless-package-version": SDK_VERSION,
    "x-stainless-lang": "js"
  };
}
function authHeaders(accessToken) {
  return {
    Authorization: `Bearer ${accessToken}`,
    "anthropic-version": ANTHROPIC_VERSION,
    "anthropic-beta": BETA_FLAGS,
    "user-agent": `claude-cli/${CLI_VERSION} (external, cli)`,
    "x-app": "cli",
    ...getStainlessHeaders()
  };
}
async function fetchAccountIdentity(accessToken) {
  try {
    const res = await fetch(`${API_BASE}/api/oauth/account/settings`, {
      headers: authHeaders(accessToken)
    });
    if (!res.ok)
      return null;
    const data = await res.json();
    return {
      accountUUID: data.account_uuid ?? data.uuid ?? "",
      organizationUUID: data.organization_uuid ?? "",
      email: data.email ?? "",
      subscriptionType: data.subscription_type ?? "max",
      rateLimitTier: data.rate_limit_tier ?? "default_claude_max_5x"
    };
  } catch {
    return null;
  }
}
function buildMetadataUserId(identity, sessionId) {
  const parts = [
    DEVICE_ID,
    identity?.accountUUID ?? "",
    sessionId
  ];
  return parts.join("|");
}
async function sendTelemetry(accessToken, identity, sessionId) {
  const now = new Date().toISOString();
  const events = [
    {
      type: "tengu_init",
      properties: {
        sessionId,
        deviceID: DEVICE_ID,
        accountUUID: identity?.accountUUID ?? "",
        platform: "cli",
        version: CLI_VERSION
      },
      timestamp: now
    },
    {
      type: "tengu_started",
      properties: {
        sessionId,
        deviceID: DEVICE_ID,
        accountUUID: identity?.accountUUID ?? "",
        platform: "cli",
        version: CLI_VERSION
      },
      timestamp: now
    }
  ];
  await fetch(`${API_BASE}/api/event_logging/v2/batch`, {
    method: "POST",
    headers: {
      ...authHeaders(accessToken),
      "content-type": "application/json"
    },
    body: JSON.stringify({ events })
  }).catch(() => {});
}
async function performStartupHandshake(accessToken) {
  const headers = authHeaders(accessToken);
  const jsonHeaders = { ...headers, "content-type": "application/json" };
  const sessionId = SESSION_ID;
  const identity = await fetchAccountIdentity(accessToken);
  const evalHeaders = {
    Authorization: `Bearer ${accessToken}`,
    "anthropic-beta": "oauth-2025-04-20",
    "content-type": "application/json",
    "user-agent": `claude-cli/${CLI_VERSION} (external, cli)`
  };
  const mcpHeaders = {
    ...headers,
    "anthropic-beta": MCP_BETA,
    "content-type": "application/json"
  };
  const messagesHeaders = {
    ...jsonHeaders,
    "anthropic-dangerous-direct-browser-access": "true",
    "x-stainless-retry-count": "0",
    "x-stainless-timeout": "600"
  };
  const metadataUserId = buildMetadataUserId(identity, sessionId);
  const requests = [
    fetch(`${API_BASE}/api/eval/${SDK_EVAL_KEY}`, {
      method: "POST",
      headers: evalHeaders,
      body: JSON.stringify({
        attributes: {
          sessionId,
          platform: "cli",
          version: CLI_VERSION,
          deviceID: DEVICE_ID,
          accountUUID: identity?.accountUUID ?? "",
          organizationUUID: identity?.organizationUUID ?? "",
          email: identity?.email ?? "",
          subscriptionType: identity?.subscriptionType ?? "max",
          rateLimitTier: identity?.rateLimitTier ?? "default_claude_max_5x",
          userType: "external"
        }
      })
    }),
    fetch(`${API_BASE}/api/claude_code_grove`, { headers }),
    fetch(`${API_BASE}/api/claude_code_penguin_mode`, { headers }),
    fetch(`${API_BASE}/api/oauth/claude_cli/client_data`, { headers }),
    fetch(`${API_BASE}/v1/mcp_servers?limit=1000`, { headers: mcpHeaders }),
    fetch(`${API_BASE}/v1/messages?beta=true`, {
      method: "POST",
      headers: messagesHeaders,
      body: JSON.stringify({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 1,
        messages: [{ role: "user", content: "quota" }],
        metadata: { user_id: metadataUserId }
      })
    }),
    sendTelemetry(accessToken, identity, sessionId)
  ];
  await Promise.allSettled(requests);
  return metadataUserId;
}
function getKeychainCredentials() {
  const raw = execSync('security find-generic-password -s "Claude Code-credentials" -a "kenbanks" -w', { encoding: "utf-8" });
  const parsed = JSON.parse(raw.trim());
  return parsed.claudeAiOauth;
}
var cachedMetadataUserId = "";
var SESSION_ID = randomUUID();
var KeychainProvider = async (input) => {
  try {
    const creds = getKeychainCredentials();
    await input.client.auth.set({
      path: { id: "anthropic" },
      body: {
        type: "oauth",
        refresh: creds.refreshToken,
        access: creds.accessToken,
        expires: Date.now() + 3600 * 1000
      }
    });
    performStartupHandshake(creds.accessToken).then((userId) => {
      cachedMetadataUserId = userId;
    }).catch(() => {});
  } catch {}
  return {
    auth: {
      provider: "anthropic",
      loader: async (getAuth, _provider) => {
        const auth = await getAuth();
        if (!auth || auth.type !== "oauth")
          return {};
        return {
          apiKey: OAUTH_DUMMY_KEY,
          async fetch(requestInput, init) {
            if (init?.headers) {
              if (init.headers instanceof Headers) {
                init.headers.delete("authorization");
                init.headers.delete("Authorization");
                init.headers.delete("x-api-key");
              } else if (Array.isArray(init.headers)) {
                init.headers = init.headers.filter(([key]) => key.toLowerCase() !== "authorization" && key.toLowerCase() !== "x-api-key");
              } else {
                delete init.headers["authorization"];
                delete init.headers["Authorization"];
                delete init.headers["x-api-key"];
              }
            }
            const currentAuth = await getAuth();
            if (!currentAuth || currentAuth.type !== "oauth")
              return fetch(requestInput, init);
            const headers = new Headers(init?.headers);
            headers.set("Authorization", `Bearer ${currentAuth.access}`);
            headers.set("anthropic-version", ANTHROPIC_VERSION);
            headers.set("anthropic-beta", BETA_FLAGS);
            headers.set("anthropic-dangerous-direct-browser-access", "true");
            headers.set("user-agent", `claude-cli/${CLI_VERSION} (external, cli)`);
            headers.set("x-app", "cli");
            for (const [k, v] of Object.entries(getStainlessHeaders())) {
              headers.set(k, v);
            }
            let url = typeof requestInput === "string" ? requestInput : requestInput instanceof URL ? requestInput.toString() : requestInput instanceof Request ? requestInput.url : String(requestInput);
            if (url.includes("/v1/messages") && !url.includes("beta=")) {
              url += url.includes("?") ? "&beta=true" : "?beta=true";
            }
            let body = init?.body;
            if (body && url.includes("/v1/messages")) {
              try {
                const parsed = JSON.parse(body);
                if (parsed.model && !parsed.model.includes("[1m]")) {
                  parsed.model = `${parsed.model}[1m]`;
                }
                if (!parsed.metadata)
                  parsed.metadata = {};
                if (cachedMetadataUserId && !parsed.metadata.user_id) {
                  parsed.metadata.user_id = cachedMetadataUserId;
                }
                body = JSON.stringify(parsed);
              } catch {}
            }
            return fetch(url, { ...init, headers, body });
          }
        };
      },
      methods: ["oauth"]
    }
  };
};
export {
  KeychainProvider
};
