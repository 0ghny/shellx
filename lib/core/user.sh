# shellcheck shell=bash

#######################################
# Returns the current user's login name.
# Falls back to 'id -un' or the last segment of $HOME if $USER is unset.
# Globals:
#   USER - Preferred source for the username.
#   HOME - Used as a last-resort fallback.
# Outputs:
#   Writes the current username to stdout.
#######################################
user::current() {
  echo "${USER:-$(id -un || printf %s "${HOME/*\/}")}"
}
