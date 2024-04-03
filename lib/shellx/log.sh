# shellcheck shell=bash disable=SC2068,SC2154,SC2145

shellx::log_internal::debug_slug() {
  if [[ -n "${SHELLX_NO_COLOR}" ]]; then
    echo "DEBUG"
  else
    echo "${_color_green}DEBUG${_color_reset}"
  fi
}

shellx::log_internal::info_slug() {
  if [[ -n "${SHELLX_NO_COLOR}" ]]; then
    echo "INFO"
  else
    echo "${_color_yellow}INFO${_color_reset}"
  fi
}

shellx::log_internal::warn_slug() {
  if [[ -n "${SHELLX_NO_COLOR}" ]]; then
    echo "WARN"
  else
    echo "${_color_white}WARN${_color_reset}"
  fi
}

shellx::log_internal::error_slug() {
  if [[ -n "${SHELLX_NO_COLOR}" ]]; then
    echo "ERROR"
  else
    echo "${_color_red}ERROR${_color_reset}"
  fi
}

# Returns the caller information
# The output depends on the shell that is running, since the way to get the caller information is different
# between bash and zsh (and other shells).
# @output
# - bash: script function-name:line-relative-to-function
# - zsh: script:line
# @limitations
#  - It only works for bash and zsh
# examples:
#  - bash: ./lib/shellx/cli.sh:33 shellx::cli:run
#  - zsh: ./lib/shellx/plugins.sh:101
# @notes
#  i don't use $ZSH_VERSION or $BASH_VERSION to determine the shell, because it may be defined in the environment
# and it may not be the current shell running the script that's why i just check if the variables i need are defined.
shellx::log_internal::caller_info() {

  # Since you may open a bash session on a zsh shell, or vice versa, we need to check both
  if [[ -n "${funcfiletrace}" ]]; then
    # source: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html
    echo "${funcfiletrace[3]}"
  elif [[ -n "${BASH_SOURCE}" ]] || [[ -n "${FUNCNAME}" ]] || [[ -n "${BASH_LINENO}" ]]; then
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

# prints a log line with the following format:
#    timestamp slug caller_info message
# caller_info is a call to shellx::log_internal::caller_info
# @see shellx::log_internal::caller_info for more information
# @output
#  2024-04-03 17:42:42.779  | DEBUG | (./lib/shellx/cli.sh:54) params_count->2 | parameters->debug enable
shellx::__log() {
  local slug="${1:-$(shellx::log_internal::debug_slug)}"
  if shellx::debug::is_enabled; then
    printf -- '%-25s| %-17s| (%s) %s\n' "$(date '+%F %T.%-3N' 2>/dev/null || :) " "${slug}" "$(shellx::log_internal::caller_info)" "$(array::except_first $@)" 1>&2 || :
  fi
}

# log functions by level
shellx::log_debug() { shellx::__log "$(shellx::log_internal::debug_slug)" $@; }
shellx::log_error() { shellx::__log "$(shellx::log_internal::error_slug)" $@; }
shellx::log_info() { shellx::__log "$(shellx::log_internal::info_slug)" $@; }
shellx::log_warn() { shellx::__log "$(shellx::log_internal::warn_slug)" $@; }
