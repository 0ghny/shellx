# shellcheck shell=bash
shellx::version() {
  # shellcheck disable=SC2154
  echo "$(git -C "${__shellx_homedir}" rev-parse --abbrev-ref HEAD)-$(git -C "${__shellx_homedir}" rev-parse --short HEAD)"
}

shellx:version:notes() {
  local count="${1:-3}"
  # shellcheck disable=SC2086
  git -C "${__shellx_homedir}" --no-pager \
        log --pretty=format:"%h%x09%an%x09%ad%x09%s" -n${count}
}
