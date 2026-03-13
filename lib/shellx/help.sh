# shellcheck shell=bash

#######################################
# Displays the ShellX version and the full content of the help text file.
# Globals:
#   __shellx_homedir - Path to the ShellX installation directory.
# Outputs:
#   Writes version and help text to stdout.
#######################################
# shellcheck disable=SC2154
shellx::help() {
  printf "version: %s\n\n" "$(shellx::version)"
  cat "${__shellx_homedir}/help.txt"
}
