# shellcheck shell=bash
# shellcheck disable=SC2154
shellx::version() {
  local version
  version="v$(cat "${__shellx_homedir}/version.txt")"
  if git::isrepo "${__shellx_homedir}"; then
    version="${version}-$(git::sha::short "${__shellx_homedir}")"
  fi
  echo "${version}"
}

shellx::version::notes() {
  local count="${1:-3}"

  if [[ "${SHELLX_NO_COLOR:-false}" == "true" ]]; then
    SHELLX_VERSION_NOTES_FORMAT="format: %<(20,trunc)%ar %h %<(12,trunc)%an %<(150,trunc)%s"
  else
    SHELLX_VERSION_NOTES_FORMAT="format:%C(green) %<(20,trunc)%ar %C(bold magenta)%h %C(bold green)%<(12,trunc)%an %C(bold yellow)%<(150,trunc)%s%C(reset)"
  fi

  # shellcheck disable=SC2086
  git -C "${__shellx_homedir}" --no-pager \
        log --no-merges --first-parent \
            --pretty="${SHELLX_VERSION_NOTES_FORMAT}" \
            -n${count} \
            --invert-grep --grep="release" --grep="chore:" --grep="ci:"
}

shellx::version::info() {
  echo "Version Number: $(shellx::version)"
  echo "Release Notes (last 5):"
  shellx::version::notes 5
  echo ""
  echo "  for more information run shellx version notes <number of notes to show>"
}
