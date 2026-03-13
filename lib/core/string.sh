# shellcheck shell=bash

#######################################
# Returns the character length of a string.
# Arguments:
#   $1 - The input string.
# Outputs:
#   Writes the character count to stdout.
#######################################
string::length() {
  echo "${#1}"
}

#######################################
# Returns true if the string is null, empty, or contains only whitespace.
# Arguments:
#   $1 - The input string.
# Returns:
#   0 if null or whitespace-only, 1 otherwise.
#######################################
string::is_null_or_whitespace() {
  [ -z "${1// }" ]
}

#######################################
# Returns true if the string is null or empty.
# Arguments:
#   $1 - The input string.
# Returns:
#   0 if null or empty, 1 otherwise.
#######################################
string::is_null_or_empty() {
  [ -z "${1}" ]
}

#######################################
# Removes all whitespace characters from a string.
# Note: collapses and removes all spaces, not just leading/trailing.
# Arguments:
#   $* - One or more words to trim.
# Outputs:
#   Writes the trimmed string (no whitespace) to stdout.
#######################################
string::trim() {
  set -f
  # shellcheck disable=2048,2086
  set -- $*
  echo "${*//[[:space:]]/}"
  set +f
}

#######################################
# Converts a string to lowercase.
# Arguments:
#   $1 - The input string.
# Outputs:
#   Writes the lowercase string to stdout.
#######################################
string::to_lower() {
  echo "${1}" | tr '[:upper:]' '[:lower:]'
}

#######################################
# Converts a string to uppercase.
# Arguments:
#   $1 - The input string.
# Outputs:
#   Writes the uppercase string to stdout.
#######################################
string::to_upper() {
  echo "${1}" | tr '[:lower:]' '[:upper:]'
}

#######################################
# Performs a case-sensitive equality check between two strings.
# Arguments:
#   $1 - First string.
#   $2 - Second string.
# Returns:
#   0 if equal, 1 otherwise.
#######################################
string::equals() {
  [ "${1}" = "${2}" ]
}
