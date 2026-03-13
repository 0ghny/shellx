# shellcheck shell=bash

#######################################
# Prints the list of configured remotes for the current repository.
# Outputs:
#   Writes remote names and URLs to stdout (result of 'git remote -v').
#######################################
git::remote() {
  git remote -v
}

#######################################
# Sets the 'origin' remote URL for the current repository.
# Arguments:
#   $1 - New remote URL to set. Must be non-empty.
# Returns:
#   0 on success, non-zero if the URL argument is empty.
#######################################
git::remote::set() {
  if [ -n "${1}" ]; then
      git remote set-url origin "${1}"
  else
      echo "Remote cannot be empty or null."
  fi
}
