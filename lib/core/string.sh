# shellcheck shell=bash

string::length() {
  echo "${#1}"
}

string::is_null_or_whitespace() {
  [[ -z "${1// }" ]]
}

string::is_null_or_empty() {
  [[ -z "${1}" ]]
}

string::trim() {
  set -f
  # shellcheck disable=2048,2086
  set -- $*
  echo "${*//[[:space:]]/}"
  set +f
}

string::to_lower() {
  echo "${1}" | tr '[:upper:]' '[:lower:]'
}

string::to_upper() {
  echo "${1}" | tr '[:lower:]' '[:upper:]'
}
string::equals() {
  [[ "${1}" == "${2}" ]]
}
