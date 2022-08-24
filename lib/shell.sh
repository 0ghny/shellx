# shellcheck shell=bash

shell::function_exists(){
  local name="$1"
  declare -f "$name" &> /dev/null
}

shell::alias_exists(){
  local name="$1"
  # shellcheck disable=SC2155
  local typeMatch=$(command::get_type "$name")
  [[ "$typeMatch" == "alias" ]]
}
