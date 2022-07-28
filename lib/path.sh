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