# shellcheck shell=bash
# prints current branch name
# optional sets the directory
git::branch::name() {
  opts=()

  if [[ -n "${1}" ]]; then
    opts+=(-C "${1}")
  fi

  opts+=(rev-parse --abbrev-ref HEAD)

  git "${opts[@]}"
}

# This wipe the specified branch, it means,
# delete all history and leaves only one commit
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
    git push -f origin ${_git_branch_wipe_name}
}
