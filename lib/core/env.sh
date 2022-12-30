# shellcheck shell=bash
env::export() {
  local key="$1"
  local value="$2"
  eval "export ${key}=\"${value}\""
}

env::is_defined() {
  [[ -v $1 ]]
}
