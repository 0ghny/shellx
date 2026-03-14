# shellcheck shell=bash disable=SC2068,SC2154,SC2145
# Simplified logging module - consolidated from 5 slug functions into 1

#######################################
# Returns the colored log level slug for a given log level name.
# Color output is suppressed when SHELLX_NO_COLOR is set.
# Globals:
#   SHELLX_NO_COLOR - When set, disables ANSI color codes.
#   _color_*        - Color variables from lib/core/colors.sh.
# Arguments:
#   $1 - Log level name: debug, info, warn, or error (default: DEBUG).
# Outputs:
#   Writes the (optionally colored) level slug string to stdout.
#######################################
shellx::log_internal::get_slug() {
  local level="${1:-DEBUG}"
  
  if [ -z "${SHELLX_NO_COLOR}" ]; then
    case "${level}" in
      debug) echo "${_color_green}DEBUG${_color_reset}" ;;
      info)  echo "${_color_yellow}INFO${_color_reset}" ;;
      warn)  echo "${_color_white}WARN${_color_reset}" ;;
      error) echo "${_color_red}ERROR${_color_reset}" ;;
      *)     echo "${_color_green}${level}${_color_reset}" ;;
    esac
  else
    echo "${level}"
  fi
}

#######################################
# Returns a string identifying the caller of the current log function.
# The format depends on the active shell:
#   bash: "<script> <funcname>:<lineno>"
#   zsh:  "<script>:<lineno>"
# Falls back to "cannot-get-caller <$0>:0" for unsupported shells.
# This function inspects shell-specific variables ($funcfiletrace,
# $BASH_SOURCE, $FUNCNAME, $BASH_LINENO) to determine the true caller
# without relying on $ZSH_VERSION or $BASH_VERSION (which may be inherited).
# Outputs:
#   Writes caller information string to stdout.
# Examples:
#   bash: "./lib/shellx/cli.sh shellx::cli::run:33"
#   zsh:  "./lib/shellx/plugins.sh:101"
#######################################
shellx::log_internal::caller_info() {

  # Since you may open a bash session on a zsh shell, or vice versa, we need to check both
  if [ -n "${funcfiletrace}" ]; then
    # source: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html
    echo "${funcfiletrace[3]}"
  elif [ -n "${BASH_SOURCE}" ] || [ -n "${FUNCNAME}" ] || [ -n "${BASH_LINENO}" ]; then
    # source: https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
    # An array variable whose members are the line numbers in source files where each corresponding member of FUNCNAME was invoked. 
    # ${BASH_LINENO[$i]} is the line number in the source file (${BASH_SOURCE[$i+1]}) 
    # where ${FUNCNAME[$i]} was called (or ${BASH_LINENO[$i-1]} if referenced within another shell function). 
    # Use LINENO to obtain the current line number.
    echo "${BASH_SOURCE[2]} ${FUNCNAME[3]}:${BASH_LINENO[2]}"
  else
    echo "cannot-get-caller ${0}:0"
  fi
}

#######################################
# Core logging function. Prints a structured log line to stderr.
# Output format:  <timestamp> | <level_slug> | (<caller_info>) <message>
# Only emits output when debug mode is enabled (shellx::debug::is_enabled).
# Globals:
#   __shellx_homedir   - Replaced with variable name in output for brevity.
#   __shellx_plugins_d - Replaced with variable name in output for brevity.
# Arguments:
#   $1 - Colored level slug (from shellx::log_internal::get_slug).
#   $@ - Log message (remaining arguments joined).
# Outputs:
#   Writes a log line to stderr.
#######################################
shellx::__log() {
  local slug="${1:-$(shellx::log_internal::get_slug debug)}"
  shift  # Remove slug parameter
  if shellx::debug::is_enabled; then
    local _caller_info _msg
    _caller_info="$(shellx::log_internal::caller_info)"
    _caller_info="${_caller_info//"${__shellx_homedir}"/\${__shellx_homedir\}}"
    _msg="$*"
    [ -n "${__shellx_plugins_d}" ] && _msg="${_msg//"${__shellx_plugins_d}"/\${__shellx_plugins_d\}}"
    [ -n "${__shellx_homedir}" ]   && _msg="${_msg//"${__shellx_homedir}"/\${__shellx_homedir\}}"
    printf -- '%-25s| %-17s| (%s) %s\n' "$(date '+%F %T.%-3N' 2>/dev/null || :) " "${slug}" "${_caller_info}" "${_msg}" 1>&2 || :
  fi
}

#######################################
# Logs a debug-level message to stderr (when debug mode is enabled).
# Arguments:
#   $@ - Message to log.
#######################################
shellx::log_debug() { shellx::__log "$(shellx::log_internal::get_slug debug)" "$@"; }
#######################################
# Logs an error-level message to stderr (when debug mode is enabled).
# Arguments:
#   $@ - Message to log.
#######################################
shellx::log_error() { shellx::__log "$(shellx::log_internal::get_slug error)" "$@"; }
#######################################
# Logs an info-level message to stderr (when debug mode is enabled).
# Arguments:
#   $@ - Message to log.
#######################################
shellx::log_info()  { shellx::__log "$(shellx::log_internal::get_slug info)"  "$@"; }
#######################################
# Logs a warn-level message to stderr (when debug mode is enabled).
# Arguments:
#   $@ - Message to log.
#######################################
shellx::log_warn()  { shellx::__log "$(shellx::log_internal::get_slug warn)"  "$@"; }
