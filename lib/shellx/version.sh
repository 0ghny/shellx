# shellcheck shell=bash
# shellcheck disable=SC2154

#######################################
# Returns the current ShellX version string.
# Reads the version number from version.txt and appends the short git SHA
# when running inside a git repository.
# Globals:
#   __shellx_homedir - Path to the ShellX installation directory.
# Outputs:
#   Writes the version string (e.g. "v1.2.3-abc1234") to stdout.
#######################################
shellx::version::str() {
  local version
  version="v$(cat "${__shellx_homedir}/version.txt")"
  if git::isrepo "${__shellx_homedir}"; then
    version="${version}-$(git::sha::short "${__shellx_homedir}")"
  fi
  echo "${version}"
}

#######################################
# Returns the current ShellX version string.
# Convenience alias for shellx::version::str, kept for backward compatibility
# (used by session.sh, help.sh, and external callers).
# Globals:
#   __shellx_homedir - Path to the ShellX installation directory.
# Outputs:
#   Writes the version string to stdout.
#######################################
shellx::version() {
  shellx::version::str
}

#######################################
# Displays the last N git commit messages as formatted release notes.
# Excludes merge commits and commits matching release/chore/ci patterns.
# Supports colored output (disabled when SHELLX_NO_COLOR=true).
# Globals:
#   __shellx_homedir         - Path to the ShellX git repository.
#   SHELLX_NO_COLOR          - When "true", disables colors.
#   SHELLX_VERSION_NOTES_FORMAT - Git pretty format string (set internally).
# Arguments:
#   $1 - Number of notes to show (default: 3).
# Outputs:
#   Writes formatted commit log lines to stdout.
#######################################
shellx::version::notes() {
  local count="${1:-3}"

  if [ "${SHELLX_NO_COLOR:-false}" = "true" ]; then
    SHELLX_VERSION_NOTES_FORMAT="tformat: %<(20,trunc)%ar %h %<(12,trunc)%an %<(80,trunc)%s"
  else
    SHELLX_VERSION_NOTES_FORMAT="tformat:%C(green) %<(20,trunc)%ar %C(bold magenta)%h %C(bold green)%<(12,trunc)%an %C(bold yellow)%<(80,trunc)%s%C(reset)"
  fi

  # shellcheck disable=SC2086
  git -C "${__shellx_homedir}" --no-pager \
        log --no-merges --first-parent \
            --pretty="${SHELLX_VERSION_NOTES_FORMAT}" \
            -n${count} \
            --invert-grep --grep="release" --grep="chore:" --grep="ci:" \
        | grep -v "^[[:space:]]*$"
}

#######################################
# Displays the current version number and the last 5 release notes.
# Convenience function combining shellx::version and shellx::version::notes.
# Outputs:
#   Writes version and release notes to stdout.
#######################################
shellx::version::info() {
  echo "Version Number: $(shellx::version::str)"
  echo "Release Notes (last 5):"
  shellx::version::notes 5
  echo ""
  echo "  for more information run shellx version notes <number of notes to show>"
}
