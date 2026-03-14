# shellcheck shell=bash
# ShellX CLI adapter for the 'plugins' command.
# Provides the subcommand dispatcher shellx::cli::plugins mapped from
# the CLI registry. Pure logic lives in lib/shellx/plugins/.

#######################################
# CLI dispatcher for the 'plugins' command.
# Arguments:
#   list                   - List available plugin packages
#   installed              - List installed plugin packages
#   install <name|url>     - Install a plugin by package name or URL
#   uninstall <name>       - Uninstall a plugin package
#   update <name>          - Update an installed plugin package (git pull)
#   reload                 - Reload plugins into current session
# Returns:
#   0 on success, 1 on unknown subcommand or error.
#######################################
shellx::cli::plugins() {
  local subcommand="${1:-}"

  case "${subcommand}" in
    list)
      shellx::plugins::list
      ;;
    installed)
      shellx::plugins::installed
      ;;
    install)
      shift
      shellx::plugins::install "$@"
      ;;
    uninstall)
      shift
      shellx::plugins::uninstall "$@"
      ;;
    update)
      shift
      shellx::plugins::update "$@"
      ;;
    reload)
      shellx::plugins::reload
      ;;
    *)
      echo "Usage: shellx plugins <subcommand> [args]" >&2
      echo "" >&2
      echo "Subcommands:" >&2
      echo "  list                   List available plugin packages" >&2
      echo "  installed              List installed plugin packages" >&2
      echo "  install <name|url>     Install a plugin by package name or URL" >&2
      echo "  uninstall <name>       Uninstall a plugin package" >&2
      echo "  update <name>          Update an installed plugin (git pull)" >&2
      echo "  reload                 Reload plugins into current session" >&2
      return 1
      ;;
  esac
}
