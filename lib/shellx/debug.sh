# shellcheck shell=bash

#######################################
# Checks whether debug mode is currently enabled.
# Debug is enabled when SHELLX_DEBUG is set to "yes" or "YES".
# Globals:
#   SHELLX_DEBUG - Checked for value "YES" (case-insensitive).
# Returns:
#   0 if debug is enabled, 1 otherwise.
#######################################
shellx::debug::is_enabled() {
  [ -n "${SHELLX_DEBUG}" ] && \
  [ "$(string::to_upper "${SHELLX_DEBUG}")" = "YES" ]
}

#######################################
# Enables debug mode by setting SHELLX_DEBUG to "yes".
# Globals:
#   SHELLX_DEBUG - Set to "yes".
#######################################
shellx::debug::enable() {
  env::export "SHELLX_DEBUG" "yes"
}

#######################################
# Disables debug mode by clearing the SHELLX_DEBUG variable.
# Globals:
#   SHELLX_DEBUG - Set to empty string.
#######################################
shellx::debug::disable() {
  env::export "SHELLX_DEBUG" ""
}
