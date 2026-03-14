# shellcheck shell=bash
# ShellX CLI adapter for the 'debug' command.
# Provides the subcommand dispatcher shellx::cli::debug mapped from
# the CLI registry. Pure logic lives in lib/shellx/debug.sh.

#######################################
# CLI dispatcher for the 'debug' command.
# Arguments:
#   enabled  - Enable debug output
#   disabled - Disable debug output
# Globals:
#   SHELLX_DEBUG
# Returns:
#   0 on success, 1 on unknown argument.
#######################################
shellx::cli::debug() {
  local action="${1}"

  case "${action}" in
    enabled)
      shellx::debug::enable
      ;;
    disabled)
      shellx::debug::disable
      ;;
    *)
      local _status
      shellx::debug::is_enabled && _status="enabled" || _status="disabled"
      echo "Current Status: ${_status}" >&2
      echo "Usage: shellx debug enabled|disabled" >&2
      return 1
      ;;
  esac
}
