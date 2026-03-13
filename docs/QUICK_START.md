# ShellX Quick Start Guide

Welcome! This guide walks you through everything you need to know to install ShellX and start using it productively, even if you have never used a shell plugin manager before.

---

## Table of Contents

1. [What is ShellX?](#what-is-shellx)
2. [Core Concepts](#core-concepts)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Your First Session](#your-first-session)
6. [Everyday CLI Commands](#everyday-cli-commands)
7. [Configuration](#configuration)
8. [Writing Your First Plugin](#writing-your-first-plugin)
9. [Installing Community Plugins](#installing-community-plugins)
10. [Keeping ShellX Up to Date](#keeping-shellx-up-to-date)

---

## What is ShellX?

ShellX is a **shell-independent plugin loader**. In plain terms, it lets you split your shell setup (the stuff you would normally dump into `~/.bashrc` or `~/.zshrc`) into small, focused **plugin files** that ShellX loads automatically every time you open a terminal.

Instead of a 300-line `~/.bashrc` that is hard to read and breaks when you copy it to a new machine, you end up with a tidy collection of plugins like:

```
~/.shellx.plugins.d/
  myplugins/
    plugins/
      golang.sh        ← sets up Go only when `go` is installed
      python.sh        ← activates pyenv if present
      work-aliases.sh  ← aliases specific to your job
```

ShellX handles the loading order, guards against missing tools, and exposes a clean `shellx` CLI so you can manage everything without leaving your terminal.

---

## Core Concepts

| Concept | What it means |
|---|---|
| **Plugin** | A single `.sh` file that contains shell code (exports, aliases, functions, etc.) |
| **Package** | A directory (or git repo) that contains one or more plugins under a `plugins/` subfolder |
| **Plugin directory** (`~/.shellx.plugins.d/`) | The folder where ShellX looks for packages |
| **`@.shellx`** | The built-in package that ships with ShellX itself (bundled plugins) |
| **Config file** | `~/.shellxrc` (or `~/.config/shellx/config`) — sets ShellX variables like which packages to load |
| **`shellx` CLI** | The command you type in your terminal to interact with ShellX |

---

## Requirements

- **Bash 4.0+** or **Zsh 4.0+**
- `git` (used to clone ShellX and to install plugin packages)

Check your shell version:

```bash
bash --version   # or
zsh  --version
```

---

## Installation

### Step 1 — Clone ShellX

```bash
git clone https://github.com/0ghny/shellx ~/.shellx
```

### Step 2 — Bootstrap your shell

Add one line to the end of your shell's rc file:

**Bash** (`~/.bashrc`):
```bash
[[ -f ~/.shellx/shellx.sh ]] && source ~/.shellx/shellx.sh
```

**Zsh** (`~/.zshrc`):
```zsh
[[ -f ~/.shellx/shellx.sh ]] && source ~/.shellx/shellx.sh
```

### Step 3 — Reload your shell

```bash
exec $SHELL
```

You should see a welcome message confirming ShellX is running. That's it — you're done!

---

## Your First Session

Once installed, open a new terminal. ShellX has already:

- Loaded its built-in libraries (color helpers, path utilities, etc.)
- Loaded the bundled plugins (`@.shellx` package)
- Added `~/bin` and `~/.local/bin` to your `PATH`

Run the following commands to get oriented:

```bash
# Who is ShellX, what version is running?
shellx version

# Full information: session start time, load time, libraries, plugins
shellx info

# What plugins are currently loaded?
shellx list

# All available commands and what they do
shellx help
```

---

## Everyday CLI Commands

### Session

```bash
shellx list          # Show all plugins loaded in this session
shellx status        # Show session info (user, start time, load time)
shellx reload        # Reload all plugins and config without opening a new terminal
shellx reset         # Replace current shell with a fresh one (exec $SHELL)
```

### Plugins

```bash
shellx plugins list                  # Browse available packages from the registry
shellx plugins installed             # List packages installed on your machine
shellx plugins install <url>         # Install a package from a git URL
shellx plugins uninstall <name>      # Remove an installed package
shellx plugins reload                # Reload plugins only (without reloading config)
```

### Version & Updates

```bash
shellx version                       # Print current version
shellx version info                  # Version + recent changelog
shellx check-update                  # Check whether a newer version exists
shellx self-update                   # Pull the latest version from GitHub
```

### Debug

```bash
shellx debug enabled                 # Turn on verbose debug output
shellx debug disabled                # Turn it off
```

### Config

```bash
shellx config print                  # Show the contents of your config file
shellx config runtime                # Show all active SHELLX_* variables
shellx config set SHELLX_DEBUG yes   # Change a config value
shellx config unset SHELLX_DEBUG     # Remove a config value
shellx config reload                 # Re-read the config file without restarting
```

---

## Configuration

ShellX looks for its config file in this order:

1. `$SHELLX_CONFIG` environment variable (if set)
2. `~/.shellxrc`
3. `~/.config/shellx/config`

A minimal config looks like this:

```bash
# ~/.shellxrc

# Load only these packages (use @all to load everything)
SHELLX_PLUGINS=( @.shellx @myplugins )

# Suppress the welcome banner
SHELLX_NO_BANNER=yes

# Turn on debug output (useful when writing plugins)
# SHELLX_DEBUG=yes

# Auto-update ShellX on every new shell session
# SHELLX_AUTO_UPDATE=yes
```

### Useful config variables

| Variable | Default | Description |
|---|---|---|
| `SHELLX_PLUGINS` | `@all` | Packages to load. Use `@all`, `@<package>`, or a specific filename |
| `SHELLX_NO_BANNER` | unset | Set to `yes` to hide the startup message |
| `SHELLX_DEBUG` | unset | Set to `yes` to print debug output during loading |
| `SHELLX_AUTO_UPDATE` | unset | Set to `yes` to pull the latest ShellX automatically |
| `SHELLX_PLUGINS_EXTRA` | `()` | Array of additional directories to scan for packages |

---

## Writing Your First Plugin

A plugin is just a `.sh` file placed inside a `plugins/` subdirectory of your package.

### Step 1 — Create your package

```bash
mkdir -p ~/.shellx.plugins.d/myplugins/plugins
```

### Step 2 — Write a plugin file

```bash
cat > ~/.shellx.plugins.d/myplugins/plugins/aliases.sh << 'EOF'
# My personal aliases
alias ll='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'

# Only set up Go environment if go is installed
command -v go >/dev/null 2>&1 && export GOPATH="$HOME/go"
EOF
```

### Step 3 — Tell ShellX to load your package

Add it to `~/.shellxrc`:

```bash
SHELLX_PLUGINS=( @.shellx @myplugins )
```

### Step 4 — Reload

```bash
shellx reload
```

Your aliases are now active. Verify:

```bash
shellx list    # @myplugins/aliases.sh should appear
```

### Plugin best practices

- **Guard against missing tools** — check with `command -v <tool> >/dev/null 2>&1 && return` before setting up a tool that may not be installed.
- **One concern per file** — keep `golang.sh`, `python.sh`, `aliases.sh` separate. It's easier to enable/disable individual pieces.
- **Keep plugins idempotent** — every plugin is sourced on each shell start, so avoid side effects like appending to `PATH` multiple times. Use pattern: `[[ ":$PATH:" != *":$HOME/bin:"* ]] && export PATH="$HOME/bin:$PATH"`.

---

## Installing Community Plugins

ShellX has an official registry of community packages. Browse them:

```bash
shellx plugins list
```

Install one by its git URL:

```bash
shellx plugins install https://github.com/0ghny/shellx-community-plugins
```

Reload to activate:

```bash
shellx reload
```

Uninstall if you no longer need it:

```bash
shellx plugins uninstall shellx-community-plugins
```

Available community packages include:

| Package | What it provides |
|---|---|
| `shellx-community-plugins` | General-purpose community plugins |
| `shellx-plugins-git` | Git workflow helpers |
| `shellx-plugins-osx` | macOS-specific utilities |
| `shellx-plugins-arch` | Arch Linux utilities |
| `shellx-plugin-asdf` | asdf version manager integration |
| `shellx-docker-stacks` | Docker stack helpers |
| `shellx-dotfiles` | Dotfile management utilities |

---

## Keeping ShellX Up to Date

Check whether a newer version is available:

```bash
shellx check-update
```

Update to the latest version:

```bash
shellx self-update
```

Or enable automatic updates by adding this to your `~/.shellxrc`:

```bash
SHELLX_AUTO_UPDATE=yes
```

> **Tip:** ShellX checks for updates once per shell session (controlled by a lock file at `/tmp/.shellx_update_check.lock`). It will notify you if an update is available, but it won't install it automatically unless `SHELLX_AUTO_UPDATE=yes` is set.

---

## Next Steps

- Browse `plugin-examples/` in the ShellX repository for real-world plugin patterns.
- Read `docs/SHELL_COMPATIBILITY.md` if you use a non-standard shell.
- Run `shellx help <command>` at any time for inline documentation on any command.

Happy hacking!
