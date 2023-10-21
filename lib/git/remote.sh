# shellcheck shell=bash

# remote print
git::remote() {
  git remote -v
}

# sets git remote
git::remote::set() {
  if [[ -n "${1}" ]]; then
      git remote set-url origin "${1}"
  else
      echo "Remote cannot be empty or null."
  fi
}
