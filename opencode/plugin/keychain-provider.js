// index.ts
import { execSync } from "child_process";
function getKeychainCredentials() {
  const raw = execSync('security find-generic-password -s "Claude Code-credentials" -a "kenbanks" -w', { encoding: "utf-8" });
  const parsed = JSON.parse(raw.trim());
  return parsed.claudeAiOauth;
}
var KeychainProvider = async (_input) => {
  return {
    auth: {
      provider: "anthropic",
      loader: async (_auth, _provider) => {
        const { accessToken, refreshToken } = getKeychainCredentials();
        return {
          type: "oauth",
          access: accessToken,
          refresh: refreshToken,
          expires: Date.now() + 3600 * 1000
        };
      },
      methods: [
        {
          type: "api",
          label: "Claude Code Keychain (macOS)",
          authorize: async () => {
            try {
              const { accessToken } = getKeychainCredentials();
              return {
                type: "success",
                key: accessToken
              };
            } catch {
              return { type: "failed" };
            }
          }
        }
      ]
    },
    "chat.headers": async (input, output) => {
      if (input.provider.info.id !== "anthropic")
        return;
      output.headers = {
        ...output.headers,
        "anthropic-beta": "claude-code-20250219,oauth-2025-04-20,interleaved-thinking-2025-05-14", // gitleaks:allow
        "user-agent": "claude-cli/2.1.2 (external, cli)",
        "x-app": "cli"
      };
    }
  };
};
export {
  KeychainProvider
};
