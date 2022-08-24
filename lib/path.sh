# shellcheck shell=bash
path::add() {
  local _path="${1}"
  if ! path::exists "${_path}"; then
      export PATH="${_path}:${PATH}"
  fi
}

path::exists() {
  local _path="${1}"
  [[ ":${PATH}:" == *":${_path}:"* ]]
}

path::export() {
  if [[ :$PATH: == *:"$1":* ]] ; then
    # O.K., the directory is on the path
    :
  else
    # oops, the directory is not on the path
    export PATH=${1}:${PATH}
  fi
}
