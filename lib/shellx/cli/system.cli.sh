# shellcheck shell=bash
# ShellX CLI adapters for system-level commands.
# Provides shellx::cli::reset and shellx::cli::reload mapped from the CLI registry.

#######################################
# Resets the current shell by replacing the process with a fresh shell.
# Equivalent to running 'exec $SHELL'.
# Returns:
#   Does not return (replaces current process).
#######################################
shellx::cli::reset() {
  exec "$SHELL"
}

#######################################
# Performs a full reload: plugins and configuration.
# Runs shellx::plugins::reload followed by shellx::config::reload so that
# both the plugin state and the config file are re-applied in a single command.
# Returns:
#   0 if both reloads succeed, non-zero on first failure.
#######################################
shellx::cli::reload() {
  shellx::plugins::reload && shellx::config::reload
}
