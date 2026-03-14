# shellcheck shell=bash

#######################################
# Checks whether a file or directory exists at the given path.
# Arguments:
#   $1 - Filesystem path to check.
# Returns:
#   0 if the path exists (file or directory), 1 otherwise.
#######################################
io::exists() {
    local _path="${1}"
    [ -f "${_path}" ] || [ -d "${_path}" ]
}
