# ShellX Shell Compatibility Guide

## Overview

ShellX is designed to work with **Bash 4.0+**, **Zsh 4.0+**, and **Fish 3.2+**. Bash and Zsh are natively supported. Fish Shell is supported via a dedicated `shellx.fish` bootstrap file.

## Supported Shells

### ✅ Bash 4.0 or Higher
- **Full support** for all ShellX features
- Required for plugin management, arrays, and advanced configurations
- Installation: Available by default on most Linux systems; on macOS use `brew install bash`

### ✅ Zsh 4.0 or Higher
- **Full support** for all ShellX features
- Required for plugin management, arrays, and advanced configurations
- Installation: Available by default on modern macOS; on Linux: `apt install zsh` or equivalent

### ✅ Fish 3.2 or Higher
- **Supported** via `shellx.fish` — do **not** source `shellx.sh` directly
- Two modes depending on whether [`bass`](https://github.com/edc/bass) is installed:
  - **Full mode** (bass installed): plugin-exported env vars (`GOPATH`, `JAVA_HOME`, …) propagate into the Fish session
  - **Basic mode** (no bass): `shellx` CLI command + PATH setup only
- Installation: `brew install fish` (macOS) or `apt install fish` (Debian/Ubuntu)

#### Fish Setup

1. Add `SHELLX_HOME` and source `shellx.fish` in `~/.config/fish/config.fish`:

   ```fish
   set -gx SHELLX_HOME /path/to/.shellx
   source $SHELLX_HOME/shellx.fish
   ```

2. _(Optional)_ Install [`bass`](https://github.com/edc/bass) for full environment propagation:

   ```fish
   # With Fisher
   fisher install edc/bass
   ```

3. To silence the basic-mode notice without installing bass:

   ```fish
   set -gx SHELLX_FISH_QUIET 1
   ```

## Partially Supported / Unsupported Shells

### ⚠️ POSIX sh
- ShellX will load but **plugin management will not work**
- Reason: POSIX sh lacks associative arrays and advanced array operations
- Use only for basic shell initialization if absolutely necessary

### ❌ Ksh (Korn Shell)
- **Not fully compatible** with ShellX
- Reason: Limited array support and different syntax
- Not tested or supported

## Why Bash/Zsh?

ShellX uses several advanced shell features that are only available in Bash 4+ and Zsh:

1. **Associative Arrays**: For managing plugin metadata and configuration
   - Bash: `declare -A my_array`
   - Zsh: `typeset -A my_array`
   - POSIX sh: ❌ Not available

2. **Array Operations**: For iterating and manipulating plugin lists
   - Bash: `for item in "${array[@]}"; do ...`
   - Zsh: `for item in "${array[@]}"; do ...`
   - POSIX sh: ❌ Not available

3. **String Parameter Expansion**: Advanced variable manipulation
   - Bash/Zsh: Full support for `${var:offset:length}`, `${var//pattern/replacement}`, etc.
   - POSIX sh: Limited support

## Checking Your Shell Compatibility

### Check Your Current Shell
```bash
echo $SHELL
# or
echo $0
```

### Check Your Shell Version
```bash
# Bash
bash --version

# Zsh
zsh --version

# Fish
fish --version
```

### Test ShellX Compatibility
When ShellX loads, it will check your shell automatically:

```bash
# If using a non-compatible shell, you'll see:
# ShellX: WARNING - This shell may not be fully compatible with ShellX.
# ShellX: Requires Bash 4+ or Zsh for full functionality.
# ShellX: Current shell: /bin/sh

# If Fish is detected on a wrong entrypoint, you'll see:
# ShellX: Fish Shell detected. Source shellx.fish instead of shellx.sh.
# ShellX: Add to ~/.config/fish/config.fish:
# ShellX:   source /path/to/.shellx/shellx.fish
```

## Recommended Setup

### Linux
- **Primary**: Bash 4.0+ (usually pre-installed)
- **Alternative**: Zsh (install via package manager)
- **Alternative**: Fish 3.2+ (install via package manager, use `shellx.fish`)

### macOS
- **Primary**: Zsh (default since macOS Catalina)
- **Alternative**: Bash 4.0+ (via Homebrew, since system Bash 3.x is too old)
- **Alternative**: Fish 3.2+ (via Homebrew, use `shellx.fish`)

```bash
# Install Bash 4+ on macOS
brew install bash

# Add to ~/.zshrc or ~/.bashrc
export SHELL=$(which bash)  # if using Bash
```

## Migration from Unsupported Shells

If you're currently using an unsupported shell:

1. **Switch to Bash, Zsh, or Fish**:
   ```bash
   chsh -s /bin/zsh                   # Set default shell to Zsh
   # or
   chsh -s /usr/local/bin/bash        # Set default shell to Bash (Homebrew)
   # or
   chsh -s /usr/local/bin/fish        # Set default shell to Fish (Homebrew)
   ```

2. **Restart your terminal** for changes to take effect

3. **Source ShellX** in your new shell's rc file:
   - Bash: add `source /path/to/shellx.sh` to `.bashrc`
   - Zsh: add `source /path/to/shellx.sh` to `.zshrc`
   - Fish: add `source /path/to/shellx.fish` to `~/.config/fish/config.fish`

## Troubleshooting

### "ShellX: WARNING - This shell may not be fully compatible"
- You're using an unsupported shell
- Switch to Bash 4+ or Zsh
- See "Migration from Unsupported Shells" above

### Plugin features not working
- Verify you're using Bash 4+ or Zsh 4+
- Run: `bash --version` or `zsh --version`
- Ensure you're sourcing ShellX from your correct shell rc file

### ShellX loads but no plugins appear
- Check shell compatibility first
- Verify plugins are installed: `ls -la ~/.shellx.plugins.d/`
- Enable debug mode: `shellx debug enabled` and check output

## Future Compatibility Plans

ShellX may consider alternative data storage mechanisms (YAML, JSON files) to reduce array dependency, but this would require significant refactoring and is not planned in the near term.
