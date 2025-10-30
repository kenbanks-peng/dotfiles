---
description: Generate a UML sequence diagram in D2 format showing function call flows
---

# Sequence Diagram Generator

Create a UML sequence diagram in D2 format that visualizes the execution flow and interactions between components in the codebase. The diagram shows how functions call each other across packages, directories, files, or classes over time.

## Variables

SCOPE: $ARGUMENTS
OUTPUT_DIR: `AIDOCS\architecture`
OUTPUT_FILE: Will be generated based on diagram type and flow (e.g., `app-startup-sequence-diagram.d2`)

## Instructions

### Pre-Flight Checks

1. **Verify D2 Installation**
   - Check if D2 is installed using: `which d2`
   - If not found (empty output), inform the user: "D2 is not installed. Please install it from https://d2lang.com before proceeding."
   - If installed, proceed to next step

2. **Set Expectations**
   - Inform the user: "Creating the sequence diagram may take a minute or so while I analyze the codebase and generate the diagram."

### Understanding the Request

1. **Analyze Available Flows**
   - Examine the codebase structure (main.go, package layout, key functions)
   - Look for entry points: CLI commands, HTTP handlers, user interactions, main functions
   - Identify major features and use cases from the code
   - Present a numbered list of applicable flows to the user, for example:
     ```
     I've analyzed your codebase. Here are the available flows I can diagram:
     
     1. Application startup - How the UI initializes and loads data
     2. MCP server configuration - User configuring an MCP server
     3. Agent management - Listing, getting, or installing agents
     4. Tool management - Listing, getting, or installing tools
     5. Platform switching - Switching between OpenCode and Agentic platforms
     6. GetAgent flow - Trace how GetAgent retrieves configurations
     7. Configuration validation - How configs are validated across the system
     
     Which flow would you like me to diagram? (Enter number or describe a different flow)
     ```

2. **Choose Actor Granularity**
   - Present granularity options to the user:
     ```
     What level of detail would you like for the actors in the diagram?
     
     1. High-level (Packages) - Architectural view showing package interactions
        Example actors: internal/mcp, internal/agents, internal/tools
     
     2. Medium (Files) - Balanced view showing file-level interactions
        Example actors: domain.go, platform.go, state.go
     
     3. Detailed (Structs/Classes) - Detailed view showing object interactions
        Example actors: Manager, Config, StateManager
     
     4. Mixed - Combination based on what makes the most sense for this flow
     
     Which granularity level? (1-4)
     ```

3. **Include Self-Calls to Internal Functions**
   - Ask the user about self-calls to internal/private functions:
     ```
     Should I include self-calls (where an actor calls its own internal functions)?
     
     1. Yes - Show when an actor calls its own private/internal methods
        Example: Manager -> Manager: validateConfig()
        Note: A self-call means the actor is both caller AND callee
     
     2. No - Only show calls between different actors (cleaner view)
        Example: Skip Manager -> Manager calls, only show Manager -> Other
     
     Which option? (1-2)
     ```
   - **Clarification for agent**: A self-call occurs when the caller and callee are the SAME actor at your chosen granularity level. If you chose package-level granularity, then `internal/mcp -> internal/mcp` is a self-call. If you chose struct-level granularity, then `Manager -> Manager` is a self-call. The arrow loops back to the same actor box on the diagram.

4. **Select Output Format**
   - Ask the user for their preferred output format:
     ```
     What output format would you like?
     
     1. PNG - Raster image, good for documentation
     2. SVG - Vector image, scalable and editable
     3. Both PNG and SVG
     4. D2 source only (you'll render it yourself)
     
     Which format? (1-4)
     ```

5. **Generate Output File Name**
   - Create a descriptive filename based on the flow being diagrammed
   - Format: `<flow-name>-sequence-diagram.d2`
   - Examples:
     - Application startup → `app-startup-sequence-diagram.d2`
     - MCP server configuration → `mcp-config-sequence-diagram.d2`
     - Agent management → `agent-management-sequence-diagram.d2`
     - GetAgent flow → `get-agent-sequence-diagram.d2`
   - Ensure OUTPUT_DIR exists before writing file

6. **Parse SCOPE**
   - If SCOPE is provided via $ARGUMENTS, use it
   - Otherwise, use the user's selection from the flow list
   - Confirm understanding before proceeding

### Analyzing the Codebase

1. **Identify Entry Points**
   - User interactions (if applicable)
   - Public API functions
   - HTTP handlers or CLI commands
   - Main execution paths

2. **Trace Function Calls**
   - Follow the execution flow from entry point
   - Track which functions call which other functions
   - Note the packages/files/structs involved
   - Identify return paths and data flow
   - Look for loops, conditionals, and error handling paths

3. **Apply Selected Granularity**
   - Use the granularity level chosen by the user:
     - **Level 1 (Packages)**: Actors are packages like `internal/mcp`, `internal/agents`
     - **Level 2 (Files)**: Actors are files like `domain.go`, `platform.go`
     - **Level 3 (Structs/Classes)**: Actors are types like `Manager`, `Config`, `StateManager`
     - **Level 4 (Mixed)**: Use judgment - packages for cross-cutting, structs for detailed interactions
   - Always include **User** actor if there's external user interaction

4. **Handle Self-Calls to Internal Functions**
   - **Understanding self-calls**: A self-call is when an actor calls its own function. The caller IS the callee at your chosen granularity level. This appears as an arrow that loops back to the same actor in the diagram.
   - Based on user's preference:
     - **Option 1 (Include)**: Show self-calls using syntax `actor -> actor: internalMethod()`
       - At package level: `internal/mcp -> internal/mcp: validateConfig()`
       - At struct level: `Manager -> Manager: loadCache()`
       - These represent internal implementation details within the same component
     - **Option 2 (Exclude)**: Only show calls where caller ≠ callee (interactions between different actors)
       - Skip any `actor -> actor` calls
       - Results in cleaner diagram focused on component interactions
   - Private/internal functions typically identified by lowercase first letter (Go convention) or internal/ visibility

### Creating the D2 Diagram

#### Structure

```d2
flow: {
  shape: sequence_diagram
  
  # Define actors in desired order (left to right)
  actor1
  actor2
  actor3
  
  # Show function calls as messages
  actor1 -> actor2: FunctionName()
  actor2 -> actor3: AnotherFunction(param)
  
  # Show return values
  actor3 -> actor2: returnValue
  actor2 -> actor1: result
  
   # Self-calls: actor calls its own internal function (caller == callee)
   actor2 -> actor2: internalMethod()
  
  # Spans for critical sections or transaction blocks
  actor2."processing": {
    actor1 -> actor2."processing": BeginTransaction()
    actor2."processing" -> actor3: SaveData()
    actor2."processing" -> actor1: CommitTransaction()
  }
  
  # Groups for conditional logic or loops
  errorHandling: {
    actor2 -> actor3: Validate()
    actor3 -> actor2: error
    actor2 -> actor1: ErrorResponse()
  }
  errorHandling.label: Error Handling
  
  # Notes for important context
  actor2.note: {
    shape: text
  }
  actor2.note: Key implementation detail
}
```

#### Best Practices

1. **Actor Naming**
   - Use clear, descriptive names
   - For Go packages: `internal/mcp` or just `mcp`
   - For structs: `Manager` or `mcp.Manager`
   - For files: `domain.go` or `mcp/domain.go`
   - Include User actor if there's user interaction

2. **Message Labels**
   - Format: `FunctionName(params)` or just `FunctionName()`
   - For methods: `MethodName()` 
   - For return values: use descriptive names like `config`, `error`, `result`
   - Keep labels concise but meaningful

3. **Use Spans For**
   - Transaction boundaries
   - Critical sections
   - Long-running operations
   - Lock/unlock regions

4. **Use Groups For**
   - Conditional branches (if/else)
   - Loop iterations
   - Error handling blocks
   - Optional operations
   - Label groups clearly: `group.label: Loop: For each item`

5. **Add Notes For**
   - Complex logic explanation
   - Important side effects
   - Performance considerations
   - Security concerns

6. **Styling (Optional)**
   - Highlight critical paths with colors
   - Use dashed lines for async calls
   - Different colors for different types of actors

### Example Scenarios

#### High-Level Package View
```d2
userFlow: {
  shape: sequence_diagram
  
  User
  "cmd/openconfig"
  "internal/mcp"
  "internal/agents"
  "internal/util"
  
  User -> "cmd/openconfig": Start Application
  "cmd/openconfig" -> "internal/mcp": ListServers()
  "internal/mcp" -> "internal/util": ReadConfigFile()
  "internal/util" -> "internal/mcp": configData
  "internal/mcp" -> "cmd/openconfig": serverList
  "cmd/openconfig" -> User: Display Servers
}
```

#### Detailed Method-Level View
```d3
getAgent: {
  shape: sequence_diagram
  
  Client
  "agents.Manager"
  "util.FileUtil"
  
  Client -> "agents.Manager": GetAgent(name, platform, dir)
  "agents.Manager" -> "agents.Manager": ListAgents(platform, dir)
  "agents.Manager" -> "util.FileUtil": DirExists(agentPath)
  "util.FileUtil" -> "agents.Manager": true
  "agents.Manager" -> "agents.Manager": searchAgents
  "agents.Manager" -> Client: agent, nil
}
```

## Workflow

1. **Pre-Flight Checks** 
   - Verify user has D2 installed
   - Set expectations about processing time (~1 minute)

2. **Gather Requirements**
   - Analyze codebase and present list of available flows
   - Get user to select a flow (or accept SCOPE if provided)
   - Ask user to choose actor granularity level (1-4)
   - Ask whether to include private function self-calls (1-2)
   - Ask user to select output format (PNG/SVG/Both/D2 only)
   - Generate appropriate output filename based on selected flow

3. **Research Code** 
   - Use grep/glob to find relevant files, functions, and call chains
   - Focus on the selected flow

4. **Trace Execution** 
   - Follow the control flow from entry point through the system
   - Apply the user's selected granularity level

5. **Generate D2** 
   - Write valid D2 syntax with sequence_diagram shape
   - Use actor granularity as specified by user
   - Include or exclude self-calls based on user preference
   - **Remember**: Self-call means `actor -> actor` (caller and callee are the same)

6. **Save & Render** 
   - Ensure OUTPUT_DIR directory exists (create if needed)
   - Generate appropriate filename: `<flow-name>-sequence-diagram.d2`
   - Check if OUTPUT_DIR/OUTPUT_FILE already exists:
     - **If file exists**: Use the Edit tool to update the existing file with the new diagram content
     - **If file doesn't exist**: Use the Write tool to create the new file
   - Write/Update to OUTPUT_DIR/OUTPUT_FILE
   - Render to user's selected format(s):
     - PNG: `d2 OUTPUT_DIR/OUTPUT_FILE OUTPUT_DIR/<flow-name>-sequence-diagram.png`
     - SVG: `d2 OUTPUT_DIR/OUTPUT_FILE OUTPUT_DIR/<flow-name>-sequence-diagram.svg`
     - Both: render both formats

7. **Report** 
   - Summarize what was diagrammed
   - Provide the manual D2 command for rendering

## Report

After creating the sequence diagram, provide:

```
✅ Sequence Diagram Created

File: OUTPUT_DIR/OUTPUT_FILE
Rendered: <list of rendered files if applicable>
Scope: <what was diagrammed>
Granularity: <level chosen by user>
Self-Calls: <included or excluded>
Actors: <list of actors in diagram>

Key Flows:
- <main flow 1>
- <main flow 2>
- <main flow 3>

Manual D2 Commands:
  PNG:  d2 OUTPUT_DIR/OUTPUT_FILE OUTPUT_DIR/<flow-name>-sequence-diagram.png
  SVG:  d2 OUTPUT_DIR/OUTPUT_FILE OUTPUT_DIR/<flow-name>-sequence-diagram.svg
```

## Tips

- **Always verify D2 installation first** - Save time by checking before doing the work
- **Present options to the user** - Don't assume granularity or format preferences
- **Set time expectations** - Let users know diagram generation takes about a minute
- **Check for existing files** - Use Edit tool for existing files, Write tool for new files
- **Quote special characters in D2** - Strings with `[]`, newlines, or special chars must be quoted
- Start simple with high-level flow, then add detail if needed
- Don't try to show everything - focus on the main path
- Use groups to show alternative/error paths without cluttering
- Order actors left-to-right in logical flow order
- For complex systems, create multiple sequence diagrams for different scenarios
- **Provide manual D2 commands** - Always show users how to render themselves

## D2 Syntax Requirements

**CRITICAL:** Follow these D2 syntax rules to avoid compilation errors:

1. **Quote Strings with Special Characters**
   - Strings containing brackets `[]`, curly braces `{}`, ampersands `&`, or parentheses in descriptions MUST be quoted
   - Example: `"map[string]interface{}"` not `map[string]interface{}`
   - Example: `"Config (with Servers & OrphanedServers)"` not `Config (with Servers & OrphanedServers)`

2. **Quote Array/Map References**
   - Any string that looks like code (array access, map keys) must be quoted
   - Example: `"Store in platformConfigs"` not `Store in platformConfigs[platformID]`
   - Simplify the message if brackets are just informational

3. **Handle Curly Braces in Text**
   - Curly braces `{}` in message labels will be interpreted as D2 substitutions
   - Either quote the entire string or avoid braces in message text
   - For multi-line notes with special characters, use markdown format:
     ```d2
     actor.note: |md
       Line 1 with {special} characters
       Line 2 with $variables
     |
     ```

4. **Common Errors to Avoid**
   - ❌ `actor1 -> actor2: map[string]interface{}`
   - ✅ `actor1 -> actor2: "map[string]interface{}"`
   
   - ❌ `actor1 -> actor2: Save to configs[id]`
   - ✅ `actor1 -> actor2: "Save to configs"`
   
   - ❌ `actor.note: "Handles {env:VAR} format"`
   - ✅ `actor.note: |md`
     `    Handles {env:VAR} format`
     `  |`

5. **Test Before Claiming Success**
   - Always run `d2 <file>.d2 <output>.png` to verify syntax
   - If compilation fails, fix all quoted string issues before reporting success
   - Read error messages carefully - they indicate line numbers and issue types
