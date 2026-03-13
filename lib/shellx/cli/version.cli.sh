# shellcheck shell=bash
# ShellX CLI adapter for the 'version' command.
# Provides the subcommand dispatcher shellx::cli::version mapped from
# the CLI registry. Pure logic lives in lib/shellx/version.sh.

#######################################
# CLI dispatcher for the 'version' command.
# With no subcommand prints the current version string.
# Subcommands:
#   info        - Print version with release notes
#   notes [N]   - Print last N release notes (default: 3)
#   check       - Check if a newer version is available
# Outputs:
#   Writes version information to stdout.
# Returns:
#   0 on success, 1 on unknown subcommand.
#######################################
shellx::cli::version() {
  local subcommand="${1:-}"
  case "${subcommand}" in
    info)
      shellx::version::info
      ;;
    notes)
      shift
      shellx::version::notes "$@"
      ;;
    check)
      shellx::update::available
      ;;
    "")
      shellx::version
      ;;
    *)
      echo "Unknown version subcommand: ${subcommand}" >&2
      echo "Usage: shellx version [info|notes [N]|check]" >&2
      return 1
      ;;
  esac
}
