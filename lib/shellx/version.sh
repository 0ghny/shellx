# shellcheck shell=bash
shellx::version() {
  # shellcheck disable=SC2154
  echo "$(git -C "${__shellx_homedir}" rev-parse --abbrev-ref HEAD)-$(git -C "${__shellx_homedir}" rev-parse --short HEAD)"
}
