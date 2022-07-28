# shellcheck shell=bash
io::exists() {
    local _path="${1}"
    [[ -f "${_path}" ]] || [[ -d "${_path}" ]]
}
