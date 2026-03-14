# shellcheck shell=bash

#######################################
# Logs an info-level message attributed to a specific plugin.
# Prefixes the message with "[PLUGIN <name>]" before delegating to shellx::log_info.
# Arguments:
#   $1 - Plugin name (default: "unknown").
#   $@ - Message to log (remaining arguments).
#######################################
shellx::plugins::log_info() {
  local plugin="${1:-unknown}"
  # shellcheck disable=SC2124
  local msg="${@:2:$#}"
  shellx::log_info "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}

#######################################
# Logs a debug-level message attributed to a specific plugin.
# Prefixes the message with "[PLUGIN <name>]" before delegating to shellx::log_debug.
# Arguments:
#   $1 - Plugin name (default: "unknown").
#   $@ - Message to log (remaining arguments).
#######################################
shellx::plugins::log_debug() {
  local plugin="${1:-unknown}"
  # shellcheck disable=SC2124
  local msg="${@:2:$#}"
  shellx::log_debug "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}

#######################################
# Logs an error-level message attributed to a specific plugin.
# Prefixes the message with "[PLUGIN <name>]" before delegating to shellx::log_error.
# Arguments:
#   $1 - Plugin name (default: "unknown").
#   $@ - Message to log (remaining arguments).
#######################################
shellx::plugins::log_error() {
  local plugin="${1:-unknown}"
  # shellcheck disable=SC2124
  local msg="${@:2:$#}"
  shellx::log_error "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}
