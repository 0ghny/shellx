# shellcheck shell=bash

#######################################
# Prints the name of the current Git branch.
# Optionally accepts a directory to run the command from.
# Arguments:
#   $1 - (Optional) Path to the git repository directory.
# Outputs:
#   Writes the current branch name to stdout.
# Returns:
#   Non-zero if not inside a git repository.
#######################################
git::branch::name() {
  opts=()

  if [ -n "${1}" ]; then
    opts+=(-C "${1}")
  fi

  opts+=(rev-parse --abbrev-ref HEAD)

  git "${opts[@]}"
}

#######################################
# Wipes the entire history of a branch and replaces it with a single commit.
# WARNING: This is destructive and rewrites history. Use with caution.
# Arguments:
#   $1 - Branch name to wipe (default: main).
#   $2 - Commit message for the new initial commit (default: "Initial commit").
# Returns:
#   0 on success, 1 if not inside a git repository.
#######################################
git::branch::wipe() {
  local _git_branch_wipe_name="${1:-main}"
  local _git_branch_wipe_message="${2:-Initial commit}"

  if ! git::isrepo; then
      echo "You're not on a git repo"
      return 1
  fi
  # Checkout to a temporary branch
  git checkout --orphan TEMP_RESET_BRANCH
  # Add all the files:
  git add -A
  # Commit the changes:
  git commit -am "${_git_branch_wipe_message}"
  # Delete the old branch:
  git branch -D ${_git_branch_wipe_name}
  # Rename the temporary branch to master:
  git branch -m ${_git_branch_wipe_name}
  # Finally, force update to our repository:
  #git push -f origin ${_git_branch_wipe_name}
}
