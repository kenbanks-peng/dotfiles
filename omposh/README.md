# Oh My Posh Configuration with Relative Shell Levels

This configuration provides a beautiful oh-my-posh theme with relative shell level indicators. Instead of showing absolute shell levels (which might start at 3 or 4), it shows relative levels starting from 1 for your initial shell, then 2, 3, 4, etc. for nested shells.

## Features

- Custom color palette with accessibility-friendly colors
- Shell type indicators (zsh, bash, fish, nu)
- Root user indicator
- Job count display
- Directory path display with intelligent truncation
- Language version indicators (Python, Go, Lua, Zig, Rust, JavaScript)
- Git status with upstream tracking
- Execution time for long-running commands
- **Relative shell level indicators** - shows `❯` for level 1, `❯❯` for level 2, etc.

## Setup

### 1. Install Oh My Posh

Follow the official installation guide at: https://ohmyposh.dev/docs/installation

### 2. Use This Configuration

Source the `omp.zsh` file in your `.zshrc`:

```bash
source $XDG_CONFIG_HOME/omposh/omp.zsh
```

Or if you don't use XDG_CONFIG_HOME:

```bash
source /path/to/omposh/omp.zsh
```

### 3. Restart Your Shell

After adding the source line to your `.zshrc`, restart your terminal or run:

```bash
source ~/.zshrc
```

## How Relative Shell Levels Work

The `omp.zsh` script automatically handles relative shell level tracking by:

- Storing the initial shell level (`INITIAL_SHLVL`) when first loaded
- Calculating relative levels as `(current SHLVL - INITIAL_SHLVL + 1)`
- Updating the `SHLVL_RELATIVE` environment variable on each prompt

This ensures that:
- Your initial shell shows 1 `❯` (level 1)
- First nested shell shows 2 `❯❯` (level 2)  
- Second nested shell shows 3 `❯❯❯` (level 3)
- And so on...

Even if your initial shell was actually at system level 3, it will display as level 1.

## Environment Variables

The configuration uses these environment variables (all managed automatically):

- `JOBCOUNT`: Number of background jobs
- `DIRPATH`: Current directory path with intelligent truncation
- `JSENV`: JavaScript environment info (Node, Deno, React, Svelte)
- `SHLVL_RELATIVE`: Relative shell level (calculated automatically)
- `INITIAL_SHLVL`: Initial shell level (stored automatically)

## Customization

### Colors

The theme uses a custom color palette defined in the `[palette]` section of `config.toml`. You can modify these colors to match your preferences:

```toml
[palette]
  red = "#a90000"
  gold = "#a17a00"
  green = "#006b1d"
  teal = "#005b95"
  blue = "#2f40c2"
  purple = "#6928b0"
  pink = "#8c0888"
  orange = "#f55c1b"
```

### Shell Level Character

To change the character used for shell levels, modify the template in the last segment of `config.toml`:

```toml
template = '{{ if .Env.SHLVL_RELATIVE }}{{ repeat (.Env.SHLVL_RELATIVE | int) ">" }}{{ else }}{{ repeat .SHLVL ">" }}{{ end }}'
```

Change `"❯"` to any character you prefer, like `">"` or `"●"`.

### Directory Display

The `directory_path()` function in `omp.zsh` handles intelligent path truncation:
- Shows home directory with `~` symbol
- Truncates long paths with `..` prefix
- Shows up to 20 characters by default

You can modify the `max_length` variable to change truncation behavior.

### JavaScript Environment Detection

The `jsenv()` function automatically detects:
- **Deno**: Projects with `deno.json`
- **Svelte**: Projects with `svelte.config.js`
- **React**: Projects with `react-dom` dependency
- **Node.js**: General Node projects with `package.json`

## Files Included

- `config.toml`: Main oh-my-posh configuration file
- `omp.zsh`: All-in-one setup script with relative shell levels and utility functions
- `README.md`: This documentation file

## Troubleshooting

### Shell Levels Not Working

1. Make sure you've sourced `omp.zsh` in your `.zshrc`
2. Restart your terminal completely
3. Check that the environment variables are set: `echo $SHLVL_RELATIVE`
4. Ensure the path to `omp.zsh` is correct in your `.zshrc`

### Colors Not Displaying

1. Ensure your terminal supports 24-bit color
2. Check that oh-my-posh is properly installed and in your PATH
3. Verify the config file path is correct

### Missing Segments

Some segments depend on context:
- Language segments only show when relevant files are present in the current directory or its parents
- Git segment only shows in Git repositories
- Job count shows when there are background jobs

### JavaScript Environment Not Detected

1. Ensure you have the required tools installed (`fd`, `rg`, `node`, `deno`)
2. Check that the project has the expected files (`package.json`, `deno.json`, etc.)
3. The function searches up the directory tree, so it should work in subdirectories

## License

This configuration is provided as-is for personal use and modification.