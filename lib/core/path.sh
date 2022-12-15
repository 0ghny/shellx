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

path::backup() {
  local var_name="${1:-PATH_BAK}"
  env::export "${var_name}" "${PATH}"
}

# MIT License: https://github.com/dylanaraps/neofetch
path::get_absolute() {
  # This function finds the absolute path from a relative one.
  # For example "Pictures/Wallpapers" --> "/home/user/Pictures/Wallpapers"

  # If the file exists in the current directory, stop here.
  [[ -f "${PWD}/${1}" ]] && { printf '%s\n' "${PWD}/${1}"; return; }

  ! cd "${1%/*}" && {
    shellx::log_error "Error: Directory '${1%/*}' doesn't exist or is inaccessible"
    shellx::log_error "       Check that the directory exists or try another directory."
  }

  local full_dir="${1##*/}"

  # Iterate down a (possible) chain of symlinks.
  while [[ -L "$full_dir" ]]; do
      full_dir="$(readlink "$full_dir")"
      cd "${full_dir%/*}" || exit
      full_dir="${full_dir##*/}"
  done

  # Final directory.
  full_dir="$(pwd -P)/${1/*\/}"

  [[ -e "$full_dir" ]] && printf '%s\n' "$full_dir"
}
