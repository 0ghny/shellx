# shellcheck shell=bash

#######################################
# Returns a comma-separated list of unique users currently logged in.
# Reads from the 'who' command and deduplicates by username.
# Outputs:
#   Writes a comma-separated user list (e.g. "alice, bob") to stdout.
#######################################
sysinfo::host::users() {
  # shellcheck disable=SC2155
  local _users="$(who | awk '!seen[$1]++ {printf $1 ", "}')"
  _users="${_users%\,*}"
  # Fall back to the current user when no interactive session is detected (e.g. CI)
  echo "${_users:-$(whoami)}"
}

#######################################
# Returns the system hostname.
# Prefers the HOSTNAME environment variable, falls back to the 'hostname' command.
# Globals:
#   HOSTNAME - Used when defined.
# Outputs:
#   Writes the hostname string to stdout.
#######################################
sysinfo::host::name() {
  echo "${HOSTNAME:-$(hostname)}"
}
