import { createCliRenderer, TextAttributes } from "@opentui/core";
import { createRoot, useKeyboard, useRenderer, useTerminalDimensions } from "@opentui/react";
import { useState, useEffect, useRef, useCallback } from "react";
import { join, dirname } from "path";

// Strip ANSI escape codes
function stripAnsi(str: string): string {
  return str.replace(/\x1B\[[0-9;]*[A-Za-z]/g, "");
}

// Parse skills commands from help output
async function parseSkillsCommands(): Promise<string[]> {
  const proc = Bun.spawn(["skills"], {
    stdout: "pipe",
    stderr: "pipe",
    env: { ...process.env },
  });
  const text = await new Response(proc.stdout).text();
  const cleanText = stripAnsi(text);

  // Parse commands from output like: "$ npx skills add <package>"
  const commandRegex = /\$\s+(?:npx\s+)?skills\s+(\w+)/g;
  const commands = new Set<string>();
  let match;
  while ((match = commandRegex.exec(cleanText)) !== null) {
    commands.add(match[1]);
  }
  return Array.from(commands);
}

// Load repos from skills.txt (relative to parent directory)
async function loadRepos(): Promise<string[]> {
  const skillsDir = dirname(dirname(import.meta.dir));
  const skillsPath = join(skillsDir, "skills.txt");
  const file = Bun.file(skillsPath);
  if (!(await file.exists())) {
    return [];
  }
  const text = await file.text();
  return text.split("\n").map(line => line.trim()).filter(Boolean);
}

interface CommandOutputProps {
  command: string | null;
  focused: boolean;
}

function CommandOutput({ command, focused }: CommandOutputProps) {
  const [output, setOutput] = useState<string[]>([]);
  const [isRunning, setIsRunning] = useState(false);
  const procRef = useRef<ReturnType<typeof Bun.spawn> | null>(null);
  const writerRef = useRef<WritableStreamDefaultWriter<Uint8Array> | null>(null);
  const commandIdRef = useRef<number>(0);

  useEffect(() => {
    if (!command) {
      setOutput([]);
      return;
    }

    // Increment command ID to track which command this is
    commandIdRef.current++;
    const thisCommandId = commandIdRef.current;

    setOutput([`$ ${command}`, ""]);
    setIsRunning(true);

    // Filter out empty args from command
    const args = command.split(" ").filter(Boolean);

    const proc = Bun.spawn(args, {
      stdout: "pipe",
      stderr: "pipe",
      stdin: "pipe",
      env: { ...process.env, FORCE_COLOR: "1" },
    });

    procRef.current = proc;
    writerRef.current = proc.stdin.getWriter();

    // Read stdout
    const readStream = async (stream: ReadableStream<Uint8Array>, prefix = "") => {
      const reader = stream.getReader();
      const decoder = new TextDecoder();
      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          // Only update if this is still the current command
          if (thisCommandId !== commandIdRef.current) break;

          const text = decoder.decode(value);
          // Strip ANSI for cleaner display in TUI
          const cleanText = stripAnsi(text);
          const lines = cleanText.split("\n");
          setOutput(prev => [...prev, ...lines.map(l => prefix + l)]);
        }
      } catch {
        // Stream closed
      }
    };

    Promise.all([
      readStream(proc.stdout),
      readStream(proc.stderr),
    ]).then(() => {
      if (thisCommandId === commandIdRef.current) {
        setIsRunning(false);
        setOutput(prev => [...prev, "", "--- Done ---"]);
      }
    });

    return () => {
      if (procRef.current === proc) {
        proc.kill();
        procRef.current = null;
        writerRef.current = null;
      }
    };
  }, [command]);

  // Handle keyboard input when focused and running
  useKeyboard(useCallback((key) => {
    if (!focused || !isRunning || !writerRef.current) return;

    // Forward key presses to subprocess
    const encoder = new TextEncoder();
    let data: string | null = null;

    if (key.name === "enter") {
      data = "\n";
    } else if (key.name === "up") {
      data = "\x1b[A";
    } else if (key.name === "down") {
      data = "\x1b[B";
    } else if (key.name === "left") {
      data = "\x1b[D";
    } else if (key.name === "right") {
      data = "\x1b[C";
    } else if (key.name === "backspace") {
      data = "\x7f";
    } else if (key.name === "space") {
      data = " ";
    } else if (key.name.length === 1 && !key.ctrl && !key.meta) {
      // Regular character
      data = key.shift ? key.name.toUpperCase() : key.name;
    } else if (key.ctrl && key.name === "c") {
      // Ctrl+C to kill process
      procRef.current?.kill();
      return;
    }

    if (data && writerRef.current) {
      writerRef.current.write(encoder.encode(data)).catch(() => {});
    }
  }, [focused, isRunning]));

  return (
    <box flexDirection="column" flexGrow={1} border borderStyle={focused ? "double" : "rounded"} borderColor={focused ? "#00FF00" : "#888888"} padding={1}>
      <text attributes={TextAttributes.BOLD}>Output {isRunning && "(Running...)"}</text>
      <scrollbox flexGrow={1}>
        {output.length > 0 ? (
          output.map((line, i) => (
            <text key={i}>{line || " "}</text>
          ))
        ) : (
          <text fg="#666666">Select a command to run</text>
        )}
      </scrollbox>
      {focused && isRunning && (
        <text fg="#00FF00" attributes={TextAttributes.DIM}>
          Type to interact | Ctrl+C to stop
        </text>
      )}
    </box>
  );
}

function App() {
  const renderer = useRenderer();
  const { width, height } = useTerminalDimensions();

  const [commands, setCommands] = useState<string[]>([]);
  const [repos, setRepos] = useState<string[]>([]);
  const [selectedCommand, setSelectedCommand] = useState<string | null>(null);
  const [selectedRepo, setSelectedRepo] = useState<string | null>(null);
  const [isGlobal, setIsGlobal] = useState(true);
  const [focusedColumn, setFocusedColumn] = useState<"commands" | "toggle" | "repos" | "output">("commands");
  const [currentCommand, setCurrentCommand] = useState<string | null>(null);

  // Load commands and repos on mount
  useEffect(() => {
    parseSkillsCommands().then(setCommands);
    loadRepos().then(setRepos);
  }, []);

  // Handle global keyboard navigation
  useKeyboard((key) => {
    if (key.name === "escape" || (key.ctrl && key.name === "c")) {
      renderer.destroy();
      return;
    }

    // Tab to switch columns
    if (key.name === "tab") {
      if (key.shift) {
        // Shift+Tab goes backwards
        setFocusedColumn(prev => {
          if (prev === "output") return selectedCommand === "add" ? "repos" : "commands";
          if (prev === "repos") return "toggle";
          if (prev === "toggle") return "commands";
          return "commands";
        });
      } else {
        // Tab goes forward
        setFocusedColumn(prev => {
          if (prev === "commands") return "toggle";
          if (prev === "toggle") return selectedCommand === "add" ? "repos" : "output";
          if (prev === "repos") return "output";
          return "commands";
        });
      }
      return;
    }

    // Toggle global/project with 'g' when in toggle focus
    if (focusedColumn === "toggle" && (key.name === "enter" || key.name === "space")) {
      setIsGlobal(prev => !prev);
      return;
    }

    // Enter to execute command
    if (key.name === "enter" && focusedColumn === "repos" && selectedRepo) {
      const globalFlag = isGlobal ? "-g " : "";
      setCurrentCommand(`skills add ${globalFlag}${selectedRepo}`);
      setFocusedColumn("output");
    }
  });

  const commandOptions = commands.map(cmd => ({
    name: cmd,
    description: getCommandDescription(cmd),
    value: cmd,
  }));

  const repoOptions = repos.map(repo => ({
    name: repo,
    description: "",
    value: repo,
  }));

  const showRepos = selectedCommand === "add";
  const col1Width = 20;
  const col2Width = showRepos ? 30 : 0;

  return (
    <box flexDirection="column" flexGrow={1}>
      {/* Header */}
      <box justifyContent="center" padding={1}>
        <ascii-font font="tiny" text="Skills" />
      </box>

      {/* Main content */}
      <box flexDirection="row" flexGrow={1} gap={1} padding={1}>
        {/* Column 1: Commands */}
        <box flexDirection="column" width={col1Width} border borderStyle="rounded" padding={1}>
          <text attributes={TextAttributes.BOLD}>Commands</text>
          {commands.length > 0 ? (
            <select
              options={commandOptions}
              focused={focusedColumn === "commands"}
              height={height - 12}
              onChange={(index, option) => setSelectedCommand(option.value)}
              onSelect={(index, option) => {
                setSelectedCommand(option.value);
                if (option.value === "add") {
                  setFocusedColumn("repos");
                } else {
                  // For non-add commands, run directly
                  const globalFlag = isGlobal ? "-g " : "";
                  setCurrentCommand(`skills ${option.value} ${globalFlag}`);
                  setFocusedColumn("output");
                }
              }}
            />
          ) : (
            <text fg="#888888">Loading...</text>
          )}
        </box>

        {/* Toggle: Global/Project */}
        <box flexDirection="column" width={12}>
          <box
            border
            borderStyle={focusedColumn === "toggle" ? "double" : "rounded"}
            borderColor={focusedColumn === "toggle" ? "#00FF00" : "#888888"}
            padding={1}
            flexDirection="column"
            alignItems="center"
          >
            <text attributes={TextAttributes.BOLD}>Scope</text>
            <text fg={isGlobal ? "#00FF00" : "#888888"}>
              {isGlobal ? "[x]" : "[ ]"} Global
            </text>
            <text fg={!isGlobal ? "#00FF00" : "#888888"}>
              {!isGlobal ? "[x]" : "[ ]"} Project
            </text>
          </box>
          <text fg="#666666" attributes={TextAttributes.DIM}>
            Tab to focus
          </text>
        </box>

        {/* Column 2: Repos (shown for "add" command) */}
        {showRepos && (
          <box flexDirection="column" width={col2Width} border borderStyle="rounded" padding={1}>
            <text attributes={TextAttributes.BOLD}>Repositories</text>
            {repos.length > 0 ? (
              <select
                options={repoOptions}
                focused={focusedColumn === "repos"}
                height={height - 12}
                onChange={(index, option) => setSelectedRepo(option.value)}
                onSelect={(index, option) => {
                  setSelectedRepo(option.value);
                  const globalFlag = isGlobal ? "-g " : "";
                  setCurrentCommand(`skills add ${globalFlag}${option.value}`);
                  setFocusedColumn("output");
                }}
              />
            ) : (
              <text fg="#888888">No repos in skills.txt</text>
            )}
          </box>
        )}

        {/* Column 3: Output */}
        <CommandOutput command={currentCommand} focused={focusedColumn === "output"} />
      </box>

      {/* Footer */}
      <box padding={1} borderStyle="single" borderColor="#444444">
        <text fg="#888888">
          <span fg="#00FFFF">Tab</span>: Switch columns |
          <span fg="#00FFFF">↑/↓</span>: Navigate |
          <span fg="#00FFFF">Enter</span>: Select |
          <span fg="#00FFFF">Esc</span>: Exit
        </text>
      </box>
    </box>
  );
}

function getCommandDescription(cmd: string): string {
  const descriptions: Record<string, string> = {
    add: "Install a skill",
    list: "List installed skills",
    find: "Search for skills",
    check: "Check for updates",
    update: "Update all skills",
    remove: "Remove installed skills",
    init: "Create a new skill",
  };
  return descriptions[cmd] || "";
}

const renderer = await createCliRenderer({ exitOnCtrlC: false });
createRoot(renderer).render(<App />);
