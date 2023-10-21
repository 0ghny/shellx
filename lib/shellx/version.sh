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
  # shellcheck disable=SC2086
  git -C "${__shellx_homedir}" --no-pager \
        log --pretty=format:"%h%x09%an%x09%ad%x09%s" -n${count}
}

shellx::version::info() {
  echo "Version Number: $(shellx::version)"
  echo "Release Notes (last 5):"
  shellx::version::notes 5
  echo "for more information run shellx version notes <number of notes to show>"
}
