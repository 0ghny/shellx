# shellcheck shell=bash

# Log levels
_shellx_loglevel_debug_="${_color_green}DEBUG${_color_reset}"
_shellx_loglevel_info_="${_color_yellow}INFO${_color_reset}"
_shellx_loglevel_warn_="${_color_white}WARN${_color_reset}"
_shellx_loglevel_error_="${_color_red}ERROR${_color_reset}"

shellx::log() {
  shellx::debug_enabled && \
  echo "`date "+%Y/%m/%d %H:%M:%S"` [$(shellx::__log_level ${1:-DEBUG})] ${@:2:$#}"
}

shellx::log_debug() { shellx::log "DEBUG" $@ }

shellx::log_error() { shellx::log "ERROR" $@ }

shellx::log_info() { shellx::log "INFO" $@ }

shellx::log_warn() { shellx::log "WARN" $@ }

shellx::__log_level() {
  case "${1}" in
    DEBUG) echo $_shellx_loglevel_debug_;;
    INFO) echo $_shellx_loglevel_info_;;
    ERROR) echo $_shellx_loglevel_error_;;
    *) echo $_shellx_loglevel_warn_;;
  esac
}
