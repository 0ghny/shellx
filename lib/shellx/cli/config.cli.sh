# shellcheck shell=bash
# ShellX CLI adapter for the 'config' command.
# Provides the subcommand dispatcher shellx::cli::config mapped from
# the CLI registry. Pure logic lives in lib/shellx/config.sh.

#######################################
# CLI dispatcher for the 'config' command.
# Arguments:
#   reload              - Reload configuration from file
#   print               - Print config file contents
#   runtime             - Print active SHELLX_* session variables
#   set <KEY> <VALUE>   - Set a configuration key
#   unset <KEY>         - Remove a configuration key
# Returns:
#   0 on success, 1 on unknown subcommand or error.
#######################################
shellx::cli::config() {
  local action="${1:-}"

  case "${action}" in
    reload)
      shellx::config::reload
      ;;
    print)
      shellx::config::print
      ;;
    runtime)
      shellx::config::runtime
      ;;
    set)
      shellx::config::set "${2:-}" "${3:-}"
      ;;
    unset)
      shellx::config::unset "${2:-}"
      ;;
    *)
      echo "Usage: shellx config <subcommand> [args]" >&2
      echo "" >&2
      echo "Subcommands:" >&2
      echo "  reload              Reload configuration from file" >&2
      echo "  print               Print config file contents" >&2
      echo "  runtime             Print active SHELLX_* session variables" >&2
      echo "  set <KEY> <VALUE>   Set a configuration key" >&2
      echo "  unset <KEY>         Remove a configuration key" >&2
      echo "" >&2
      echo "Configurable keys: SHELLX_NO_BANNER, SHELLX_DEBUG, SHELLX_PLUGINS" >&2
      return 1
      ;;
  esac
}
