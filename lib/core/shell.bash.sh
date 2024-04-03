# shellcheck shell=bash
shell::is_bash() {
  [[ -n "${BASH_VERSION}" ]]
}

shell::running_bash_script() {
  [[ -n "${BASH_SOURCE}" ]] || [[ -n "${FUNCNAME}" ]] || [[ -n "${BASH_LINENO}" ]]
}
