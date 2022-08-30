# shellcheck shell=bash
command::get_type() {
  local name="$1"
  # shellcheck disable=SC2155
  local typeMatch=$(type -t "$name" 2> /dev/null || true)
  echo "$typeMatch"
}

command::exists(){
  local name="$1"
  # shellcheck disable=SC2155
  local typeMatch=$(command::get_type "$name")
  [[ "$typeMatch" == "alias" || "$typeMatch" == "function" || "$typeMatch" == "builtin" ]]
}