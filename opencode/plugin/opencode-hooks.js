// @bun
// src/lib/observability.ts
import {
  mkdirSync,
  existsSync,
  readFileSync,
  writeFileSync,
  renameSync,
  statSync,
  appendFileSync,
  openSync,
  closeSync,
  unlinkSync
} from "fs";
import { homedir } from "os";
import { join } from "path";
var _dir = process.env.OCHOOKS_LOG_DIR ?? join(homedir(), ".opencode");
var _maxBytes = parseInt(process.env.OCHOOKS_LOG_MAX_BYTES ?? "1048576", 10);
var _maxBackups = 10;
var LOG_FILE = join(_dir, "hooks.log");
var METRICS_FILE = join(_dir, "hooks_metrics.json");
var LOG_ARCHIVE_DIR = join(_dir, "logs");
function _ensureDirs() {
  mkdirSync(_dir, { recursive: true });
  mkdirSync(LOG_ARCHIVE_DIR, { recursive: true });
}
function _rotateLogs() {
  if (!existsSync(LOG_FILE))
    return;
  const size = statSync(LOG_FILE).size;
  if (size < _maxBytes)
    return;
  for (let i = _maxBackups - 1;i >= 1; i--) {
    const src = join(LOG_ARCHIVE_DIR, `hooks.log.${i}`);
    const dst = join(LOG_ARCHIVE_DIR, `hooks.log.${i + 1}`);
    if (existsSync(src))
      renameSync(src, dst);
  }
  renameSync(LOG_FILE, join(LOG_ARCHIVE_DIR, "hooks.log.1"));
}
function _now() {
  return new Date().toISOString().replace(/\.\d{3}Z$/, "+00:00");
}
function log(event, fields = {}) {
  _ensureDirs();
  _rotateLogs();
  const parts = [
    _now(),
    event,
    ...Object.entries(fields).map(([k, v]) => `${k}=${v}`)
  ];
  const line = parts.join(" | ") + `
`;
  appendFileSync(LOG_FILE, line, "utf8");
}
function increment(key, by = 1) {
  _ensureDirs();
  const lockFile = METRICS_FILE + ".lock";
  const lockFd = openSync(lockFile, "w");
  try {
    let metrics = {};
    if (existsSync(METRICS_FILE)) {
      try {
        metrics = JSON.parse(readFileSync(METRICS_FILE, "utf8"));
      } catch {
        metrics = {};
      }
    }
    metrics[key] = (metrics[key] ?? 0) + by;
    writeFileSync(METRICS_FILE, JSON.stringify(metrics, null, 2) + `
`, "utf8");
  } finally {
    closeSync(lockFd);
    try {
      unlinkSync(lockFile);
    } catch {}
  }
}

// src/session-idle/index.ts
import { extname } from "path";

// src/lib/token-tracker.ts
import { existsSync as existsSync2, mkdirSync as mkdirSync2, unlinkSync as unlinkSync2 } from "fs";
import { homedir as homedir2 } from "os";
import { join as join2 } from "path";
var _dir2 = process.env.OCHOOKS_LOG_DIR ?? join2(homedir2(), ".opencode");
var SESSION_FILE = join2(_dir2, "hooks_session.json");
async function endSession() {
  if (!existsSync2(SESSION_FILE)) {
    return { duration: null, startTs: null };
  }
  try {
    const text = await Bun.file(SESSION_FILE).text();
    const data = JSON.parse(text);
    const startTs = data.start_ts;
    const startDate = new Date(startTs);
    const duration = (Date.now() - startDate.getTime()) / 1000;
    try {
      unlinkSync2(SESSION_FILE);
    } catch {}
    return { duration, startTs };
  } catch {
    return { duration: null, startTs: null };
  }
}

// src/lib/lint-format-config.ts
var FORMATTERS = {
  ".py": ["ruff", "format"],
  ".js": ["biome", "format", "--write"],
  ".ts": ["biome", "format", "--write"],
  ".tsx": ["biome", "format", "--write"],
  ".jsx": ["biome", "format", "--write"],
  ".css": ["biome", "format", "--write"],
  ".html": ["biome", "format", "--write"],
  ".json": ["biome", "format", "--write"],
  ".yaml": ["yamlfmt"],
  ".yml": ["yamlfmt"],
  ".rs": ["rustfmt"],
  ".go": ["gofmt", "-w"]
};

// src/session-idle/session-summary.ts
import { appendFileSync as appendFileSync2 } from "fs";
import { join as join3, basename } from "path";
var logDir = process.env.OCHOOKS_LOG_DIR ?? join3(process.env.HOME ?? "~", ".opencode");
var JOURNAL_FILE = join3(logDir, "hooks_journal.log");
function runGit(args, cwd) {
  const result = Bun.spawnSync(["git", ...args], { cwd });
  if (result.exitCode !== 0)
    return null;
  return new TextDecoder().decode(result.stdout).trim();
}
function parseDiffStat(statOutput) {
  const lines = statOutput.trim().split(`
`);
  const lastLine = lines[lines.length - 1] ?? "";
  const filesMatch = lastLine.match(/(\d+) files? changed/);
  const insertMatch = lastLine.match(/(\d+) insertions?\(\+\)/);
  const deleteMatch = lastLine.match(/(\d+) deletions?\(-\)/);
  const files = filesMatch ? parseInt(filesMatch[1], 10) : 0;
  const insertions = insertMatch ? parseInt(insertMatch[1], 10) : 0;
  const deletions = deleteMatch ? parseInt(deleteMatch[1], 10) : 0;
  return [files, insertions, deletions];
}
function getUntrackedFiles(cwd) {
  const output = runGit(["ls-files", "--others", "--exclude-standard"], cwd);
  return (output ?? "").split(`
`).filter((f) => f.length > 0);
}
function getChangedFileNames(cwd) {
  const tracked = runGit(["diff", "--name-only", "HEAD"], cwd);
  const trackedFiles = (tracked ?? "").split(`
`).filter((f) => f.length > 0);
  const untracked = getUntrackedFiles(cwd);
  return [
    ...new Map([...trackedFiles, ...untracked].map((f) => [f, f])).values()
  ];
}
function getCommitCount(cwd, startTs) {
  if (!startTs)
    return 0;
  const output = runGit(["log", "--oneline", `--since=${startTs}`], cwd);
  return output ? output.split(`
`).filter((l) => l.length > 0).length : 0;
}
function formatSummary(filesChanged, insertions, deletions, commitCount, newFileCount) {
  const parts = [];
  if (filesChanged > 0) {
    parts.push(`${filesChanged} file${filesChanged !== 1 ? "s" : ""} changed (+${insertions}/-${deletions})`);
  } else {
    parts.push("0 files changed");
  }
  if (commitCount > 0) {
    parts.push(`${commitCount} commit${commitCount !== 1 ? "s" : ""}`);
  }
  if (newFileCount > 0) {
    parts.push(`${newFileCount} new file${newFileCount !== 1 ? "s" : ""}`);
  }
  return parts.join(", ");
}
function appendJournal(cwd, summary, fileList) {
  const ts = new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
  const fileNames = fileList.slice(0, 20).map((f) => basename(f)).join(", ");
  const entry = `${ts} | ${cwd} | ${summary} | ${fileNames}
`;
  appendFileSync2(JOURNAL_FILE, entry);
}
function summarize(cwd, startTs = null) {
  const statOutput = runGit(["diff", "--stat", "HEAD"], cwd);
  const [filesChanged, insertions, deletions] = parseDiffStat(statOutput ?? "");
  const untracked = getUntrackedFiles(cwd);
  const commitCount = getCommitCount(cwd, startTs);
  const allFiles = getChangedFileNames(cwd);
  if (filesChanged === 0 && commitCount === 0 && untracked.length === 0) {
    return null;
  }
  const summary = formatSummary(filesChanged, insertions, deletions, commitCount, untracked.length);
  appendJournal(cwd, summary, allFiles);
  return summary;
}

// src/session-idle/alert.ts
import { existsSync as existsSync3 } from "fs";
import { join as join4 } from "path";
var ICON = "claude-icon.png";
var SOUND = "ding.wav";
function resource(name) {
  return join4(process.env.OCHOOKS ?? import.meta.dir, "resources", name);
}
async function ghosttyIsFocused() {
  const proc = Bun.spawn([
    "osascript",
    "-e",
    'tell application "System Events" to get name of first application process whose frontmost is true'
  ], { stdout: "pipe", stderr: "pipe" });
  const exitCode = await proc.exited;
  if (exitCode !== 0)
    return false;
  const stdout = await new Response(proc.stdout).text();
  return stdout.trim().toLowerCase() === "ghostty";
}
async function send(message, title = "OpenCode", timeout = 10, sound = SOUND) {
  if (await ghosttyIsFocused()) {
    return;
  }
  const cmd = [
    "alerter",
    "--message",
    message,
    "--title",
    title,
    "--actions",
    "Show",
    "--timeout",
    String(timeout)
  ];
  const iconPath = resource(ICON);
  if (existsSync3(iconPath)) {
    cmd.push("--app-icon", iconPath);
  }
  const soundPath = resource(sound);
  if (existsSync3(soundPath)) {
    Bun.spawn(["afplay", soundPath], {
      stdio: ["ignore", "ignore", "ignore"]
    });
  }
  const alertProc = Bun.spawn(cmd, {
    stdio: ["ignore", "pipe", "ignore"]
  });
  (async () => {
    const result = await new Response(alertProc.stdout).text();
    if (result.trim() === "Show") {
      Bun.spawn(["osascript", "-e", 'tell application "Ghostty" to activate'], {
        stdio: ["ignore", "ignore", "ignore"]
      });
    }
  })();
}

// src/session-idle/index.ts
function getChangedFiles(cwd) {
  const decoder = new TextDecoder;
  const tracked = Bun.spawnSync(["git", "diff", "--name-only", "HEAD"], {
    cwd
  });
  const trackedFiles = tracked.exitCode === 0 ? decoder.decode(tracked.stdout).trim().split(`
`).filter(Boolean) : [];
  const untracked = Bun.spawnSync(["git", "ls-files", "--others", "--exclude-standard"], { cwd });
  const untrackedFiles = untracked.exitCode === 0 ? decoder.decode(untracked.stdout).trim().split(`
`).filter(Boolean) : [];
  return [...new Set([...trackedFiles, ...untrackedFiles])];
}
function formatFile(filePath, cwd) {
  const ext = extname(filePath).toLowerCase();
  const fmt = FORMATTERS[ext];
  if (!fmt)
    return false;
  const binary = Bun.which(fmt[0]);
  if (!binary)
    return false;
  const result = Bun.spawnSync([binary, ...fmt.slice(1), filePath], { cwd });
  return result.exitCode === 0;
}
async function handleSessionIdle(directory, previouslyFormatted) {
  const changedFiles = getChangedFiles(directory);
  const newlyChanged = changedFiles.filter((f) => !previouslyFormatted.has(f));
  const formatted = [];
  for (const f of newlyChanged) {
    if (formatFile(f, directory)) {
      formatted.push(f);
    }
  }
  if (formatted.length > 0) {
    log("Formatted", {
      count: formatted.length,
      files: formatted.join(",")
    });
  }
  const { duration, startTs } = await endSession();
  const summary = summarize(directory, startTs);
  if (summary) {
    log("SessionSummary", { directory, summary });
  }
  log("Stop", {
    directory,
    formatted: formatted.length,
    duration: duration ?? 0
  });
  increment("stop.invocations");
  if (formatted.length > 0) {
    increment("formatted.files_total", formatted.length);
  }
  if (duration !== null) {
    increment("session.duration_seconds", Math.floor(duration));
  }
  await send("Session idle", "OpenCode", 10, "ding.wav");
  const updatedSet = new Set(previouslyFormatted);
  for (const f of changedFiles)
    updatedSet.add(f);
  return updatedSet;
}

// plugin.ts
var OcHooksPlugin = async ({ directory }) => {
  let lastIdleFormattedSet = new Set;
  return {
    event: async ({ event }) => {
      try {
        if (event.type === "session.idle") {
          lastIdleFormattedSet = await handleSessionIdle(directory, lastIdleFormattedSet);
        }
      } catch (err) {
        log("EventError", {
          type: event.type,
          error: err instanceof Error ? err.message : String(err)
        });
      }
    }
  };
};
var plugin_default = OcHooksPlugin;
export {
  plugin_default as default,
  OcHooksPlugin
};
