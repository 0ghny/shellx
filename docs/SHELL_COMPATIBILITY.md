# ShellX Shell Compatibility Guide

## Overview

ShellX is designed to work with **Bash 4.0+** and **Zsh 4.0+**. While basic sourcing of ShellX may work in other shells, full functionality requires one of these supported shells.

## Supported Shells

### ✅ Bash 4.0 or Higher
- **Full support** for all ShellX features
- Required for plugin management, arrays, and advanced configurations
- Installation: Available by default on most Linux systems; on macOS use `brew install bash`

### ✅ Zsh 4.0 or Higher
- **Full support** for all ShellX features
- Required for plugin management, arrays, and advanced configurations
- Installation: Available by default on modern macOS; on Linux: `apt install zsh` or equivalent

## Partially Supported / Unsupported Shells

### ⚠️ POSIX sh
- ShellX will load but **plugin management will not work**
- Reason: POSIX sh lacks associative arrays and advanced array operations
- Use only for basic shell initialization if absolutely necessary

### ❌ Fish Shell
- **Not compatible** with ShellX architecture
- Reason: Different data model and syntax (no true arrays like Bash/Zsh)
- Consider using Fish-specific plugin managers instead

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
```

### Test ShellX Compatibility
When ShellX loads, it will check your shell automatically:

```bash
# If using a non-compatible shell, you'll see:
# ShellX: WARNING - This shell may not be fully compatible with ShellX.
# ShellX: Requires Bash 4+ or Zsh for full functionality.
# ShellX: Current shell: /bin/sh
```

## Recommended Setup

### Linux
- **Primary**: Bash 4.0+ (usually pre-installed)
- **Alternative**: Zsh (install via package manager)

### macOS
- **Primary**: Zsh (default since macOS Catalina)
- **Alternative**: Bash 4.0+ (via Homebrew, since system Bash 3.x is too old)

```bash
# Install Bash 4+ on macOS
brew install bash

# Add to ~/.zshrc or ~/.bashrc
export SHELL=$(which bash)  # if using Bash
```

## Migration from Unsupported Shells

If you're currently using an unsupported shell:

1. **Switch to Bash or Zsh**:
   ```bash
   chsh -s /bin/zsh      # Set default shell to Zsh
   # or
   chsh -s /usr/local/bin/bash  # Set default shell to Bash (if Homebrew installed)
   ```

2. **Restart your terminal** for changes to take effect

3. **Source ShellX** in your new shell's rc file (`.bashrc` or `.zshrc`)

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
