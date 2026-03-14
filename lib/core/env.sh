# shellcheck shell=bash

#######################################
# Safely exports a key-value pair as an environment variable.
# Validates the key format (alphanumeric and underscores only) to prevent
# injection attacks.
# Globals:
#   Writes to the exported variable named by $1.
# Arguments:
#   $1 - Variable name (alphanumeric and underscores only).
#   $2 - Value to assign.
# Returns:
#   0 on success, 1 if the key format is invalid.
#######################################
env::export() {
  local key="$1"
  local value="$2"
  
  # Validate key format (alphanumeric and underscore only)
  case "${key}" in
    *[!a-zA-Z0-9_]*)
      shellx::log_error "Invalid export key: ${key}"
      return 1
      ;;
  esac
  
  # Use printf to safely format the export command
  eval "export ${key}=\"$(printf '%s\n' "${value}" | sed 's/\\/\\\\/g; s/"/\\"/g')\""
}

#######################################
# Checks whether a shell variable is defined and non-empty.
# Validates the variable name format before evaluation to prevent injection.
# Arguments:
#   $1 - Variable name to check (alphanumeric and underscores only).
# Returns:
#   0 if the variable is defined and non-empty, 1 otherwise.
#######################################
env::is_defined() {
  local varname="$1"
  
  # Validate variable name format
  case "${varname}" in
    *[!a-zA-Z0-9_]*)
      return 1
      ;;
  esac
  
  # Use eval safely with parameter expansion (POSIX safe)
  eval "[ -n \"\${${varname}:-}\" ] && true || false"
}
