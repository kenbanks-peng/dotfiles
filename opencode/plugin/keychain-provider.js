// index.ts
import { execSync } from "child_process";
var OAUTH_DUMMY_KEY = "opencode-oauth-dummy-key";
function getKeychainCredentials() {
  const raw = execSync('security find-generic-password -s "Claude Code-credentials" -a "kenbanks" -w', { encoding: "utf-8" });
  const parsed = JSON.parse(raw.trim());
  return parsed.claudeAiOauth;
}
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
            headers.set("anthropic-beta", "claude-code-20250219,oauth-2025-04-20,interleaved-thinking-2025-05-14");
            headers.set("user-agent", "claude-cli/2.1.2 (external, cli)");
            headers.set("x-app", "cli");
            return fetch(requestInput, { ...init, headers });
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
