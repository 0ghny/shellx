#!/bin/bash

# @description
# Include env functions to update shellx. It also include an auto-check
# feature which check for updates on shell session init.
# Since shellx SHOULD be installed using git, it will rely on git check
# commands to check for new versions.
# @configuration
#  SHELLX_AUTO_UPDATE variable if defined will execute
# auto-update feature, otherwise, has to be checked manually, either
# using git pull on SHELLX_HOME or using shellx-update function alias

# .............................................................................
#                                                                 [ FUNCTIONS ]
# .............................................................................
# shellcheck disable=SC2120
function __shellx_needs_update() {
  local __UPSTREAM=${1:-'@{u}'}
  local __REMOTE=$(git -C "${__shellx_homedir}" rev-parse "$__UPSTREAM")
  local __LOCAL=$(git -C "${__shellx_homedir}" rev-parse @)
  [[ $__LOCAL != $__REMOTE ]]
}

function shellx::perform_update() {
  git -C "${__shellx_homedir}" remote update >/dev/null 2>&1
  if __shellx_needs_update; then
    echo -n "There's a new shellx version. Proceding to update...   "
    if git -C "${__shellx_homedir}" pull >/dev/null 2>&1; then
        echo -e "updated to latest version."
    else
        echo -e "error updating."
    fi
  fi
}
# .............................................................................
#                                                                   [ ALIASES ]
# .............................................................................
alias shellx-update='shellx::perform_update'
# .............................................................................
#                                                        [FEATURE: AUTO-UPDATE]
# .............................................................................
[[ -n "$SHELLX_AUTO_UPDATE" ]] && shellx::perform_update
