# shellcheck shell=bash
# shellcheck disable=SC2120,SC2155,SC2154,SC2053
shellx::update::available() {
  local __UPSTREAM=${1:-'@{u}'}
  local __REMOTE=$(git -C "${__shellx_homedir}" rev-parse "$__UPSTREAM")
  local __LOCAL=$(git -C "${__shellx_homedir}" rev-parse @)
  [[ $__LOCAL != $__REMOTE ]]
}

shellx::update() {
  git -C "${__shellx_homedir}" remote update >/dev/null 2>&1
  if shellx::update::available; then
    echo -n "There's a new shellx version. Proceding to update...   "
    if git -C "${__shellx_homedir}" pull >/dev/null 2>&1; then
        echo -e "updated to latest version."
    else
        echo -e "error updating."
    fi
  fi
}
