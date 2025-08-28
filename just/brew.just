set unstable
set script-interpreter := ['zsh']
set shell := ['zsh', '-cu']

import 'colors.just'

default:
  @just --justfile "$JUST/brew.just" --list | zsh -c "$JUSTGREP"

#############  BREW + MISE  ##############

# outdated
[no-exit-message]
[script]
o:
  print
  print "{{BrightCyan}}BREW: mac apps, binaries"
  print -- "------------------------{{BrightBlue}}"
  brew outdated --greedy --verbose
  print
  print "{{BrightCyan}}MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------{{BrightBlue}}"
  mise outdated --bump --silent
  print
  print "{{BrightCyan}}RUSTUP: rust"
  print -- "------------------------------------{{BrightBlue}}"
  rustup check
  # uv tool upgrade --all
  # cargo install-update -a
  # -bun -g update
  # -gup update

# update
[no-exit-message]
up: _update versions

[no-exit-message]
[script]
_update:
  print
  print "{{BrightCyan}}BREW: mac apps, binaries"
  print -- "------------------------{{BrightBlue}}"
  brew upgrade --greedy
  brew cleanup
  print
  print "{{BrightCyan}}MISE: uv, bun, go, node, python, git"
  print -- "------------------------------------{{BrightBlue}}"
  mise self-update --silent --yes
  mise upgrade --bump --silent
  print
  print "{{BrightCyan}}RUSTUP: rust"
  print -- "------------------------------------{{BrightBlue}}"
  rustup update


# brew versions
[no-exit-message]
[script]
versions:
  {
    print "BREW CASKS"
    print -- "----------"
    brew list --versions --cask || print "No casks found"
    print
    print "BREW FORMULAS"
    print -- "-------------"
    brew list --versions --formula || print "No formulas found"
    print
    print "MISE PACKAGES"
    print -- "-------------"
    mise list 2>/dev/null || print "No global mise packages found"
    print
    print "RUSTUP/CARGO"
    print -- "------------"
    rustup show || print "No rustup found"
    # cargo version || print "No cargo found"
    # cargo install --list 2>/dev/null || print "No global cargo/rust packages found"
    # print
    # print "UV TOOLS"
    # print -- "--------"
    # uv tool list
    # print
    # print "GO TOOLS"
    # print -- "--------"
    # gup list 2>/dev/null || print "No global go packages found"
    # print
    # print "BUN"
    # print -- "---"
    # bun pm ls -g 2>/dev/null || print "No global bun packages found"
  } > "$DOTFILES/versions.txt"
 
  git -C "$DOTFILES" add versions.txt &>/dev/null
  git -C "$DOTFILES" diff --staged --quiet || (git -C "$DOTFILES" commit -m "update versions" && git -C "$DOTFILES" push) &>/dev/null
  
  print
  print "{{BrightMagenta}}updated versions.txt{{BrightBlue}}"


#############  BREW ONLY  ##############

# brew versions
[no-exit-message]
@bv *args:
  print "brew list --versions {{args}}"
  print
  print "{{BrightMagenta}}CASK APPS"
  print -- "---------{{BrightBlue}}"
  brew list --versions --cask {{args}} || print "{{BrightRed}}No cask apps found{{BrightCyan}}"
  print
  print "{{BrightMagenta}}FORMULA APPS"
  print -- "------------{{BrightCyan}}"
  brew list --versions --formula {{args}} || print "{{BrightRed}}No formula apps found{{BrightCyan}}"

# brew list / leaves
[no-exit-message]
[script]
bl *$args:
  set -- ${=args}
  len=$#

  if [ $len = 1 ] && [ $1 = "leaves" ]; then
    print "brew leaves"
    print
    print "{{BrightMagenta}}USER-INSTALLED LEAF FORMULAS"
    print -- "----------------------------{{BrightCyan}}"
    brew leaves --installed-on-request
  elif [ $len = 1 ] && [ $1 = "apps" ]; then
    print "brew list casks"
    print
    print "{{BrightMagenta}}CASK APPS"
    print -- "---------{{BrightCyan}}"
    brew list --cask 
  else
    print "brew list {{args}}"
    print
    brew list --formula {{args}}
  fi

# brew outdated (greedy)
[no-exit-message]
@bo:
  print "brew outdated (greedy)"
  print
  brew outdated --greedy --verbose

# brew search
[no-exit-message]
@bs *args:
  print "brew search" {{args}}
  print
  brew search {{args}}

# brew remove (w/ autoremove, cleanup)
[no-exit-message]
@br *args:
  print "brew remove /w autoremove and cleanup"
  print
  brew remove {{ args }}
  brew autoremove
  brew cleanup
  just --justfile "$JUST/brew.just" versions

# brew tree (casks and formulas)
[no-exit-message]
[script]
bt *args:
  print "brew tree {{args}}"
  print
  print "{{BrightMagenta}}FORMULAS"
  print -- "--------{{BrightCyan}}"
  if [ -n "{{args}}" ]; then
    brew deps --tree --formula {{args}}
  else
    brew leaves | xargs brew deps --tree --formula
  fi

# brew packages that depend on
[no-exit-message]
@bdo *args:
  print "brew packages that depend on" {{args}}
  print
  brew uses --installed {{args}}

# brew zap
[no-exit-message]
bz:
  brew cleanup --prune=all
  rm -rf "$HOME/Library/Application Support/Caches"
  mkdir "$HOME/Library/Application Support/Caches"
  rm -rf "$HOME/.cache"
  mkdir "$HOME/.cache"
  go clean -modcache

# brew fonts 
[no-exit-message]
[script]
bf *$args:
  set -- ${=args}
  len=$#

  if [ $len = 1 ] && [ $1 = "installed" ]; then
    print "brew fonts installed"
    print
    brew list --cask | rg "font-"
  else
    print "brew fonts available"
    print
    brew search --cask "font" | rg "font-" | rg -v -f <(brew list --cask | rg "font-")
  fi

#############  MISE ONLY  ##############

# mise list by category
[no-exit-message]
[script]
ml *$args:
  set -- ${=args}
  len=$#

  # Define tool category aliases and display names
  # These map user-friendly names to the actual mise category prefixes
  declare -A tool_aliases
  tool_aliases=(
    # Rust ecosystem
    rust        cargo

    # Python ecosystem
    python      pipx
    uv          pipx

    # JavaScript/Node ecosystem
    js          npm
    node        npm
    bun         npm
    deno        npm
  )

  # Display names for mise categories (used in output headers)
  declare -A category_display_names
  category_display_names=(
    cargo       "RUST"
    pipx        "PYTHON"
    npm         "NODE"
  )

  # Create reverse mapping: category -> list of tools that belong to it
  # This is derived from tool_aliases to avoid duplication
  declare -A category_tools_map
  for alias category in ${(kv)tool_aliases}; do
    if [[ -n "${category_tools_map[$category]}" ]]; then
      category_tools_map[$category]="${category_tools_map[$category]} $alias"
    else
      category_tools_map[$category]="$alias"
    fi
  done

  mise_output=$(mise list)
  purple="\033[95m"
  white="\033[97m"
  title="${purple}Tool                                       Version           Source                    Requested${white}"

  # Helper function to filter ungrouped tools (excluding language-specific ones)
  filter_ungrouped_tools() {
    local ungrouped="$1"
    # Get all aliased tools plus standalone tools like 'go'
    local tools="${(k)tool_aliases} go"
    local filtered_ungrouped=""

    for line in ${(f)ungrouped}; do
      tool_name=$(echo "$line" | awk '{print $1}')
      is_tool=false
      for tool in ${=tools}; do
        if [[ "$tool_name" == "$tool" ]]; then
          is_tool=true
          break
        fi
      done
      if [[ "$is_tool" == false ]]; then
        if [[ -n "$filtered_ungrouped" ]]; then
          filtered_ungrouped="$filtered_ungrouped\n$line"
        else
          filtered_ungrouped="$line"
        fi
      fi
    done

    echo -e "$filtered_ungrouped"
  }

  # Helper function to get category tools for a specific tool category
  get_category_tools() {
    local tool_category="$1"
    local ungrouped="$2"
    local track_displayed="${3:-false}"
    local category_tools=""

    for line in ${(f)ungrouped}; do
      tool_name=$(echo "$line" | awk '{print $1}')
      should_include=false

      # Check if this tool belongs to the requested category using our reverse mapping
      if [[ -n "${category_tools_map[$tool_category]}" ]]; then
        # Check if tool_name is in the list of tools for this category
        for category_tool in ${=category_tools_map[$tool_category]}; do
          if [[ "$tool_name" == "$category_tool" ]]; then
            should_include=true
            break
          fi
        done
      else
        # Fallback: direct match (for categories not in our mapping)
        if [[ "$tool_name" == "$tool_category" ]]; then
          should_include=true
        fi
      fi

      if [[ "$should_include" == true ]]; then
        if [[ -n "$category_tools" ]]; then
          category_tools="$category_tools\n$line"
        else
          category_tools="$line"
        fi
        if [[ "$track_displayed" == true ]]; then
          displayed_tools="$displayed_tools $tool_name"
        fi
      fi
    done

    echo -e "$category_tools"
  }

  if [ $len = 1 ]; then
    # Map aliases to actual prefixes using the predefined mapping
    original_arg=$1
    arg_lower="${(L)1}"

    # Check if the argument (case-insensitive) exists in our alias mapping
    a1="${tool_aliases[$arg_lower]:-$1}"

    echo -e "$title"

    # Get ungrouped tools and filter them
    ungrouped=$(echo "$mise_output" | grep -v ":")
    filtered_ungrouped=$(filter_ungrouped_tools "$ungrouped")

    # Check if we have the requested category in the available tools
    available_tools=$(echo "$mise_output" | grep ":" | cut -d: -f1 | sort -u)
    category_exists=false
    for tool in ${=available_tools}; do
      if [[ "$tool" == "$a1" ]]; then
        category_exists=true
        break
      fi
    done

    if [[ "$category_exists" == true ]]; then

      # Get category tools for this specific category
      category_tools=$(get_category_tools $a1 "$ungrouped")
      if [[ -n "$category_tools" ]]; then
        echo -e "$category_tools"
      fi

      # Then show the regular category tools
      echo "$mise_output" | grep "^$a1:"
    else
      # Fallback to original behavior if category doesn't exist
      # First show the standalone tool if it exists (for cases like 'ml go')
      if [[ "$original_arg" != "$a1" ]]; then
        # If we mapped the argument, show the original standalone tool
        echo "$mise_output" | grep -v ":" | grep "^$original_arg "
      fi

      # Then show the prefixed tools
      echo "$mise_output" | grep "^$a1:"
    fi
  else
    echo -e "$title"

    # Get ungrouped tools and filter them
    ungrouped=$(echo "$mise_output" | grep -v ":")
    filtered_ungrouped=$(filter_ungrouped_tools "$ungrouped")

    if [[ -n "$filtered_ungrouped" ]]; then
      echo -e "$filtered_ungrouped"
    fi

    # Get unique tool prefixes from mise output
    tools=$(echo "$mise_output" | grep ":" | cut -d: -f1 | sort -u)

    for tool in ${=tools}; do
      echo
      echo -e "${purple}${category_display_names[$tool]:-$(echo "$tool" | tr '[:lower:]' '[:upper:]')}${white}"

      # Get category tools for this tool category
      category_tools=$(get_category_tools "$tool" "$ungrouped" true)
      if [[ -n "$category_tools" ]]; then
        echo -e "$category_tools"
      fi

      # Then show the regular category tools
      echo "$mise_output" | grep "^$tool:"
    done
  fi