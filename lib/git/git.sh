# shellcheck shell=bash
git::isrepo() {
  git -C "${1:-$(pwd)}" rev-parse HEAD &>/dev/null
}

git::rev::head() {
  local _git_rev_head_path="${1:-$(pwd)}"
  git -C "${_git_rev_head_path}" rev-parse HEAD &>/dev/null
}

git::sha::short() {
  local _path="${1:-$(pwd)}"
  if git::isrepo "${_path}"; then
    git --git-dir "${_path}/.git" rev-parse --short HEAD
  else
    shellx::log_error "Path ${_path} it's not a git repo"
  fi
}

# clone repo destination
git::clone() {
  git clone "${1}" "${2}"
}

git::pull() {
  git -C "${1}" pull
}





