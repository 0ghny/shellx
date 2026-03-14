# shellcheck shell=bash

#######################################
# Resolves the ShellX configuration file path using the standard priority order:
#   1. $SHELLX_CONFIG environment variable (if set and readable)
#   2. ~/.shellxrc
#   3. ~/.config/shellx/config
# Outputs:
#   Writes the resolved path to stdout if a file was found.
# Returns:
#   0 if a config file was found, 1 otherwise.
#######################################
shellx::config::_resolve_file() {
  # If the session already has a resolved config path, use it first
  if [ -n "${__shellx_config:-}" ] && [ -w "${__shellx_config}" ]; then
    echo "${__shellx_config}"
    return 0
  fi

  if [ -n "${SHELLX_CONFIG:-}" ] && [ -r "${SHELLX_CONFIG}" ]; then
    echo "${SHELLX_CONFIG}"
    return 0
  elif [ -r "${HOME}/.shellxrc" ]; then
    echo "${HOME}/.shellxrc"
    return 0
  elif [ -r "${HOME}/.config/shellx/config" ]; then
    echo "${HOME}/.config/shellx/config"
    return 0
  fi
  return 1
}

#######################################
# Reloads the ShellX configuration file.
# Delegates file resolution to shellx::config::_resolve_file (see that
# function for the priority order).
# All variables in the config file are auto-exported via 'allexport'.
# Unsets SHELLX_PLUGINS before sourcing to avoid stale configuration.
# Globals:
#   SHELLX_CONFIG   - Optional path override (consumed by _resolve_file).
#   __shellx_config - Set to the resolved config file path.
# Returns:
#   0 always (warnings are logged for missing or unreadable files).
#######################################
# shellcheck disable=SC2154
shellx::config::reload() {
  local resolved
  if resolved="$(shellx::config::_resolve_file)"; then
    export __shellx_config="${resolved}"
  else
    shellx::log_warn "ShellX Configuration file not found, applying defaults."
  fi

  # Ensure some special vars are unset
  unset SHELLX_PLUGINS

  if [ -n "${__shellx_config:-}" ] && [ -r "${__shellx_config}" ]; then
    shellx::log_info "shellx configuration file loading -> ${__shellx_config}"
    set -o allexport
    # shellcheck disable=SC1090
    source "${__shellx_config}"
    set +o allexport
  else
    shellx::log_warn "shellxrc file not found or not readable, check permissions"
  fi
}

#######################################
# Prints the contents of the resolved ShellX configuration file.
# Outputs:
#   Writes the config file contents to stdout, or a message if not found.
#######################################
shellx::config::print() {
  local file
  if file="$(shellx::config::_resolve_file)"; then
    echo "# ${file}"
    cat "${file}"
  else
    echo "No ShellX configuration file found." >&2
    return 1
  fi
}

#######################################
# Prints all SHELLX_* environment variables active in the current session.
# Outputs:
#   Writes matching SHELLX_* variables and their values to stdout.
#######################################
shellx::config::runtime() {
  env | grep SHELLX_
}

# Allowed keys that can be manipulated via the CLI.
__shellx_config_allowed_keys=(
  SHELLX_NO_BANNER
  SHELLX_DEBUG
  SHELLX_PLUGINS
)

#######################################
# Validates that a key is in the allowed list.
# Arguments:
#   $1 - Key name.
# Returns:
#   0 if allowed, 1 otherwise (with error message to stderr).
#######################################
shellx::config::_validate_key() {
  local key="${1}"
  local k
  for k in "${__shellx_config_allowed_keys[@]}"; do
    [ "${k}" = "${key}" ] && return 0
  done
  echo "Error: '${key}' is not a configurable key." >&2
  echo "Allowed keys: ${__shellx_config_allowed_keys[*]}" >&2
  return 1
}

#######################################
# Resolves a writable config file path using the standard priority order.
# If no existing config file is found, creates ~/.config/shellx/config.
# Outputs:
#   Writes the config file path to stdout.
# Returns:
#   0 on success, 1 if no writable path could be determined.
#######################################
shellx::config::_resolve_writable_file() {
  local found
  if found="$(shellx::config::_resolve_file)"; then
    if [ -w "${found}" ]; then
      echo "${found}"
      return 0
    fi
  fi
  # No existing file found (or not writable) — create the default location
  local default="${HOME}/.config/shellx/config"
  mkdir -p "$(dirname "${default}")"
  touch "${default}"
  echo "${default}"
}

#######################################
# Sets a ShellX configuration key in the config file.
# Allowed keys: SHELLX_NO_BANNER, SHELLX_DEBUG, SHELLX_PLUGINS.
# If the key already exists it is replaced; otherwise it is appended.
# Arguments:
#   $1 - Key name.
#   $2 - Value.
# Returns:
#   0 on success, 1 on invalid key or write error.
#######################################
shellx::config::set() {
  local key="${1:-}"
  local value="${2:-}"

  if [ -z "${key}" ] || [ -z "${value}" ]; then
    echo "Usage: shellx config set <KEY> <VALUE>" >&2
    return 1
  fi

  shellx::config::_validate_key "${key}" || return 1

  local file
  file="$(shellx::config::_resolve_writable_file)" || return 1

  # Remove any existing line for this key, then append the new one
  local tmp
  tmp="$(mktemp)"
  grep -v "^${key}=" "${file}" > "${tmp}" 2>/dev/null || true
  echo "${key}=${value}" >> "${tmp}"
  mv "${tmp}" "${file}"

  shellx::log_info "config: set ${key}=${value} in ${file}"
}

#######################################
# Removes a ShellX configuration key from the config file.
# Allowed keys: SHELLX_NO_BANNER, SHELLX_DEBUG, SHELLX_PLUGINS.
# Arguments:
#   $1 - Key name.
# Returns:
#   0 on success, 1 on invalid key or write error.
#######################################
shellx::config::unset() {
  local key="${1:-}"

  if [ -z "${key}" ]; then
    echo "Usage: shellx config unset <KEY>" >&2
    return 1
  fi

  shellx::config::_validate_key "${key}" || return 1

  local file
  file="$(shellx::config::_resolve_writable_file)" || return 1

  local tmp
  tmp="$(mktemp)"
  grep -v "^${key}=" "${file}" > "${tmp}" 2>/dev/null || true
  mv "${tmp}" "${file}"

  shellx::log_info "config: unset ${key} from ${file}"
}
