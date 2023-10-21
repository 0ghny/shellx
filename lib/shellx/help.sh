# shellcheck shell=bash
# shellcheck disable=SC2154
shellx::help() {
  printf "version: %s\n\n" "${__shellx_version}"
  cat "${__shellx_homedir}/help.txt"
}
