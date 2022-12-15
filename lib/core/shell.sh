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

# TODO
# shell::print_list_as_table() {
#   local elements="${1}"
#   local icon="${2:-*}"
#   local element
#   for element in ${elements}; do

#   done
# }
