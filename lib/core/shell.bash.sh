# shellcheck shell=bash
shell::is_bash() {
  [[ -n "${BASH_VERSION}" ]]
}

shell::running_bash_script() {
  [[ -n "${BASH_SOURCE}" ]] || [[ -n "${FUNCNAME}" ]] || [[ -n "${BASH_LINENO}" ]]
}

shell::bash::array_first_index() {
  return 0
}
