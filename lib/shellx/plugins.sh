# shellcheck shell=bash

shellx::plugins::log_info() {
  local plugin="${1:-unknown}"
  local msg="${@:2:$#}"
  shellx::log "INFO" "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}

shellx::plugins::log_debug() {
  local plugin="${1:-unknown}"
  local msg="${@:2:$#}"
  shellx::log "DEBUG" "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}

shellx::plugins::log_error() {
  local plugin="${1:-unknown}"
  local msg="${@:2:$#}"
  shellx::log "ERROR" "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}
