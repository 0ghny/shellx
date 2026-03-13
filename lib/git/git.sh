# shellcheck shell=bash

#######################################
# Checks whether the given path (or current directory) is inside a git repository.
# Arguments:
#   $1 - (Optional) Path to check (default: current directory).
# Returns:
#   0 if inside a git repository, non-zero otherwise.
#######################################
git::isrepo() {
  git -C "${1:-$(pwd)}" rev-parse HEAD &>/dev/null
}

#######################################
# Resolves the HEAD commit SHA for a given repository path.
# Arguments:
#   $1 - (Optional) Repository path (default: current directory).
# Returns:
#   0 on success, non-zero if not a git repository.
#######################################
git::rev::head() {
  local _git_rev_head_path="${1:-$(pwd)}"
  git -C "${_git_rev_head_path}" rev-parse HEAD &>/dev/null
}

#######################################
# Returns the short (abbreviated) SHA of the HEAD commit.
# Arguments:
#   $1 - (Optional) Repository path (default: current directory).
# Outputs:
#   Writes the short SHA string to stdout.
# Returns:
#   0 on success, non-zero if the path is not a git repository.
#######################################
git::sha::short() {
  local _path="${1:-$(pwd)}"
  if git::isrepo "${_path}"; then
    git --git-dir "${_path}/.git" rev-parse --short HEAD
  else
    shellx::log_error "Path ${_path} it's not a git repo"
  fi
}

#######################################
# Clones a remote git repository into a local destination directory.
# Arguments:
#   $1 - Repository URL to clone.
#   $2 - Local destination path.
#######################################
git::clone() {
  git clone "${1}" "${2}"
}

#######################################
# Pulls the latest changes for a repository at the given path.
# Arguments:
#   $1 - Path to the local git repository.
#######################################
git::pull() {
  git -C "${1}" pull
}
