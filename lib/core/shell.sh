# shellcheck shell=bash
# Shell introspection utilities — type checking, existence checks, and alias queries.

#######################################
# Returns the type of a shell entity (alias, function, builtin, file, or empty).
# Wraps the built-in 'type -t' command.
# Arguments:
#   $1 - Name of the command, function, alias, builtin, or executable to query.
# Outputs:
#   Writes the type string to stdout, or empty string if not found.
#######################################
shell::command_type() {
  local name="$1"
  # shellcheck disable=SC2155
  local typeMatch=$(type -t "$name" 2>/dev/null || true)
  echo "$typeMatch"
}

#######################################
# Returns true if the given name resolves to any shell entity or external program.
# Checks aliases, functions, builtins, and executables in PATH.
# Arguments:
#   $1 - Name to check.
# Returns:
#   0 if it exists as an alias, function, builtin, or external program; 1 otherwise.
#######################################
shell::exists() {
  local name="$1"
  # shellcheck disable=SC2155
  local typeMatch=$(shell::command_type "$name")
  [ "$typeMatch" = "alias" ] || [ "$typeMatch" = "function" ] || \
  [ "$typeMatch" = "builtin" ] || [ "$typeMatch" = "file" ]
}

#######################################
# Checks whether an alias with the given name is currently defined.
# Uses a POSIX-compatible approach that works in bash and zsh.
# Arguments:
#   $1 - Alias name to check.
# Returns:
#   0 if the alias exists, 1 otherwise.
#######################################
shell::alias_exists() {
  local alias_name="${1}"

  if [ -z "${alias_name}" ]; then
    return 1
  fi

  # Use alias command to check if it exists
  # Redirect stderr to avoid "not found" messages
  alias "${alias_name}" 2>/dev/null | grep -q "^alias ${alias_name}="
}
