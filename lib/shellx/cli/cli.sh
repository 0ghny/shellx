# shellcheck shell=bash
# ShellX CLI - Command Router
# Maps user-friendly CLI commands to internal functions
# Only whitelisted commands can be executed
# Uses simple pipe-separated registry format for POSIX compatibility

#######################################
# Returns the absolute path to the CLI command registry file (cli_registry.conf).
# Globals:
#   __shellx_libdir - Base lib directory of the ShellX installation.
# Outputs:
#   Writes the registry file path to stdout.
#######################################
shellx::cli::registry() {
  echo "${__shellx_libdir}/shellx/cli/cli_registry.conf"
}

#######################################
# Validates that the CLI command registry file exists and is readable.
# Called at the start of shellx::cli::run to fail fast on misconfiguration.
# Returns:
#   0 if the registry exists, 1 otherwise (with error message to stderr).
#######################################
shellx::cli::init() {
  local registry
  registry=$(shellx::cli::registry)

  if [[ ! -f "${registry}" ]]; then
    echo "Error: Command registry not found: ${registry}" >&2
    return 1
  fi
}

#######################################
# Checks whether a command name is registered in the CLI registry.
# Arguments:
#   $1 - Command name to look up.
# Returns:
#   0 if the command exists in the registry, 1 otherwise.
#######################################
shellx::cli::command_exists() {
  local cmd="${1}"
  local registry
  registry=$(shellx::cli::registry)

  grep -q "^${cmd}|" "${registry}" 2>/dev/null
}

#######################################
# Returns the internal function name mapped to a CLI command.
# Arguments:
#   $1 - Command name.
# Outputs:
#   Writes the mapped function name to stdout.
# Returns:
#   0 if found, non-zero if not found.
#######################################
shellx::cli::get_function() {
  local cmd="${1}"
  local registry
  registry=$(shellx::cli::registry)

  grep "^${cmd}|" "${registry}" 2>/dev/null | cut -d'|' -f2
}

#######################################
# Returns the description string for a registered CLI command.
# Arguments:
#   $1 - Command name.
# Outputs:
#   Writes the description to stdout.
#######################################
shellx::cli::get_description() {
  local cmd="${1}"
  local registry
  registry=$(shellx::cli::registry)

  grep "^${cmd}|" "${registry}" 2>/dev/null | cut -d'|' -f4
}

#######################################
# Returns the category name for a registered CLI command.
# Arguments:
#   $1 - Command name.
# Outputs:
#   Writes the category name to stdout.
#######################################
shellx::cli::get_category() {
  local cmd="${1}"
  local registry
  registry=$(shellx::cli::registry)

  grep "^${cmd}|" "${registry}" 2>/dev/null | cut -d'|' -f3
}

#######################################
# Displays help information for ShellX commands.
# When called with no argument, lists all commands grouped by category
# in a Docker-style format. When called with a command name, shows
# the command's category and description.
# Arguments:
#   $1 - (Optional) Command name for targeted help.
# Outputs:
#   Writes help text to stdout.
# Returns:
#   0 on success, 1 if the specified command is unknown.
#######################################
shellx::cli::help() {
  local cmd="${1}"
  local registry
  registry=$(shellx::cli::registry)

  if [[ -n "${cmd}" ]]; then
    # Help for specific command
    if shellx::cli::command_exists "${cmd}"; then
      local desc
      local category
      desc=$(shellx::cli::get_description "${cmd}")
      category=$(shellx::cli::get_category "${cmd}")
      echo "Command: ${cmd}"
      echo "Category: ${category}"
      echo "Description: ${desc}"
    else
      echo "Unknown command: ${cmd}" >&2
      return 1
    fi
  else
    # List all available commands grouped by category (Docker-style format)
    echo "Usage:  shellx [OPTIONS] COMMAND"
    echo ""
    echo "ShellX - A shell utility framework with plugins"
    echo ""

    if [[ ! -f "${registry}" ]]; then
      echo "Error: Command registry not found" >&2
      return 1
    fi

    # Extract categories in order, preserving their order
    local -a categories
    local -a seen_categories

    # First pass: collect all categories in order
    while IFS='|' read -r cmd_name func_name category desc; do
      # Skip empty lines and comments
      [[ -z "${cmd_name}" ]] && continue
      [[ "${cmd_name}" =~ ^# ]] && continue

      # Check if we've already seen this category
      local found=0
      for seen in "${seen_categories[@]}"; do
        if [[ "${seen}" == "${category}" ]]; then
          found=1
          break
        fi
      done

      if [[ $found -eq 0 ]]; then
        seen_categories+=("${category}")
        categories+=("${category}")
      fi
    done < <(grep -v "^#" "${registry}")

    # Second pass: display commands grouped by category
    for category in "${categories[@]}"; do
      echo "${category}:"

      grep -v "^#" "${registry}" | grep "|${category}|" | while IFS='|' read -r cmd_name func_name cat desc; do
        # Skip empty fields
        [[ -z "${cmd_name}" ]] && continue

        # Format: command followed by description
        printf "  %-20s %s\n" "${cmd_name}" "${desc}"
      done

      echo ""
    done

    echo "Run 'shellx help COMMAND' for more information on a command."
  fi
}

#######################################
# Executes a registered CLI command after resolving it to its mapped function.
# Passes all remaining arguments to the resolved function.
# Arguments:
#   $1 - Command name.
#   $@ - Arguments forwarded to the resolved function.
# Returns:
#   0 on success, 1 if the command is unknown or has no function mapping.
#######################################
shellx::cli::execute() {
  local cmd="${1}"
  shift
  local func

  # Validate command exists
  if ! shellx::cli::command_exists "${cmd}"; then
    echo "Error: Unknown command '${cmd}'" >&2
    echo "Try 'shellx help' for available commands" >&2
    return 1
  fi

  # Get the function to execute
  func=$(shellx::cli::get_function "${cmd}")

  if [[ -z "${func}" ]]; then
    echo "Error: No function mapped for command '${cmd}'" >&2
    return 1
  fi

  # Execute the function with remaining arguments
  # shellcheck disable=SC2086
  ${func} "$@"
}

#######################################
# Main entry point for the ShellX CLI dispatcher.
# Initializes the registry, then routes the invocation to the correct
# handler (help if no args, or the registered command otherwise).
# Arguments:
#   $@ - All arguments passed to the 'shellx' command.
# Returns:
#   0 on success, 1 on unknown command or registry error.
#######################################
shellx::cli::run() {
  local cmd="${1}"

  # Initialize command registry
  shellx::cli::init || return 1

  # No arguments - show help
  if [[ $# -lt 1 ]]; then
    shellx::cli::help
    return 0
  fi

  # Help command
  if [[ "${cmd}" == "help" ]]; then
    shift
    shellx::cli::help "$@"
    return
  fi

  # Execute requested command with remaining arguments
  shellx::cli::execute "$@"
}

#######################################
# Main ShellX shell function — the primary user-facing entry point.
# Implemented as a function (not a script) so that commands such as
# 'debug enable' or 'config reload' can mutate the current shell environment.
# Globals:
#   (delegates entirely to shellx::cli::run)
# Arguments:
#   $@ - ShellX command and its arguments (e.g. "debug enabled").
#######################################
shellx() {
  shellx::log_debug "params_count->$# | parameters->$*"
  shellx::cli::run "${@}"
}
