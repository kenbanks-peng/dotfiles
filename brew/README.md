# Custom Homebrew Formulas

This directory contains custom Homebrew cask formulas.

## Monaspace Variable Font

The `monaspace-variable.rb` formula installs the variable font version of Monaspace instead of the static fonts provided by the official `font-monaspace` cask.

### Installation

#### Using as a Local Tap (Recommended)

```bash
# Tap this directory
brew tap kenbanks/fonts /Users/kenbanks/Software/brew

# Install the cask
brew install --cask kenbanks/fonts/monaspace-variable
```

#### Direct Installation

You can also install this formula directly:

```bash
brew install --cask /Users/kenbanks/Software/brew/Casks/monaspace-variable.rb
```

### Variable Font Benefits

Variable fonts allow applications to adjust font properties dynamically:
- **Weight**: Adjust from ExtraLight to ExtraBold smoothly
- **Width**: Adjust from normal to wide smoothly
- **Slant**: Adjust italic angle smoothly

This provides more flexibility than static fonts and is particularly useful in modern terminal emulators and code editors that support variable fonts (like Ghostty, WezTerm, Kitty, etc.).

### Verifying Installation

After installation, you can verify the fonts are installed:

```bash
ls ~/Library/Fonts/Monaspace*VarVF*
```

### Updating

To update to a new version:
1. Update the `version` and `sha256` in `monaspace-variable.rb`
2. Reinstall: `brew reinstall --cask monaspace-variable`

To get the new SHA256 for a version:
```bash
curl -L https://github.com/githubnext/monaspace/releases/download/v1.301/monaspace-v1.301.zip | shasum -a 256
```
