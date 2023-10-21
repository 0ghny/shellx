# shellcheck shell=bash
# shellcheck disable=SC2154
shellx::help() {
  printf "version: %s\n\n" "$(shellx::version)"
  cat "${__shellx_homedir}/help.txt"
}
