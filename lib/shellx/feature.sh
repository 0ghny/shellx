# shellcheck shell=bash

#######################################
# Checks whether a given ShellX feature is enabled.
# Currently a stub that always returns true.
# Arguments:
#   $1 - (Reserved) Feature name (not yet evaluated).
# Returns:
#   0 always (all features considered enabled).
#######################################
shellx::feature_enabled() {
  true
}
