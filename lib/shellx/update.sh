# shellcheck shell=bash
# shellcheck disable=SC2120,SC2155,SC2154,SC2053

#######################################
# Checks whether a newer version of ShellX is available upstream.
# Compares the local HEAD commit against the upstream tracking branch.
# Arguments:
#   $1 - (Optional) Upstream ref (default: '@{u}').
# Globals:
#   __shellx_homedir - Path to the ShellX git repository.
# Returns:
#   0 if an update is available (local != remote), 1 if up to date.
#######################################
shellx::update::available() {
  local __UPSTREAM=${1:-'@{u}'}
  local __REMOTE=$(git -C "${__shellx_homedir}" rev-parse "$__UPSTREAM")
  local __LOCAL=$(git -C "${__shellx_homedir}" rev-parse @)
  [ "$__LOCAL" != "$__REMOTE" ]
}

#######################################
# Performs an in-place self-update of ShellX via git pull.
# First fetches remote, then pulls if an update is available.
# Outputs progress messages to stdout.
# Globals:
#   __shellx_homedir - Path to the ShellX git repository.
# Outputs:
#   Writes status messages to stdout.
#######################################
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

#######################################
# Shows update availability and relevant commit log (or release notes).
# If an update is available, prints incoming commits and prompts to update.
# If up to date, displays the latest release notes via shellx::version::notes.
# Globals:
#   __shellx_homedir - Path to the ShellX git repository.
# Outputs:
#   Writes update status and commit log or release notes to stdout.
#######################################
shellx::update::info() {
  local __UPSTREAM=${1:-'@{u}'}
  local __REMOTE=$(git -C "${__shellx_homedir}" rev-parse "$__UPSTREAM")
  local __LOCAL=$(git -C "${__shellx_homedir}" rev-parse @)

  if shellx::update::available; then
    echo "There's a new shellx version that contains the following changes:"
    # shellcheck disable=SC2086
    git -C "${__shellx_homedir}" --no-pager \
        log --pretty=format:"%h%x09%an%x09%ad%x09%s" ${__LOCAL}..${__REMOTE}
    echo "if you wanna update, run 'shellx update'"
  else
    echo "you're running latest version, latest messages from this version are: "
    shellx::version::notes
  fi
}
alias shellx::check='shellx::update::info'
