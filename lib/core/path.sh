# shellcheck shell=bash

#######################################
# Prepends a directory to PATH if it is not already present.
# Globals:
#   PATH - Modified in place.
# Arguments:
#   $1 - Directory to add.
#######################################
path::add() {
  local _path="${1}"
  if ! path::exists "${_path}"; then
      export PATH="${_path}:${PATH}"
  fi
}

#######################################
# Checks whether a given directory is already present in PATH.
# Arguments:
#   $1 - Directory to search for.
# Returns:
#   0 if the directory is in PATH, 1 otherwise.
#######################################
path::exists() {
  local _path="${1}"
  case ":${PATH}:" in
    *":${_path}:"*) return 0 ;;
    *) return 1 ;;
  esac
}

#######################################
# Saves the current value of PATH into a named variable.
# Useful for restoring PATH after modifications.
# Arguments:
#   $1 - Variable name to store the backup (default: PATH_BAK).
#######################################
path::backup() {
  local var_name="${1:-PATH_BAK}"
  env::export "${var_name}" "${PATH}"
}

# MIT License: https://github.com/dylanaraps/neofetch
#######################################
# Resolves a relative path to its absolute form, following symlinks.
# Arguments:
#   $1 - Relative or partial path to resolve.
# Outputs:
#   Writes the absolute path to stdout if found.
# Returns:
#   0 on success, non-zero if the path cannot be resolved.
#######################################
path::get_absolute() {
  # This function finds the absolute path from a relative one.
  # For example "Pictures/Wallpapers" --> "/home/user/Pictures/Wallpapers"

  # If the file exists in the current directory, stop here.
  [ -f "${PWD}/${1}" ] && { printf '%s\n' "${PWD}/${1}"; return; }

  ! cd "${1%/*}" && {
    shellx::log_error "Error: Directory '${1%/*}' doesn't exist or is inaccessible"
    shellx::log_error "       Check that the directory exists or try another directory."
  }

  local full_dir="${1##*/}"

  # Iterate down a (possible) chain of symlinks.
  while [ -L "$full_dir" ]; do
      full_dir="$(readlink "$full_dir")"
      cd "${full_dir%/*}" || exit
      full_dir="${full_dir##*/}"
  done

  # Final directory.
  full_dir="$(pwd -P)/${1/*\/}"

  [ -e "$full_dir" ] && printf '%s\n' "$full_dir"
}
