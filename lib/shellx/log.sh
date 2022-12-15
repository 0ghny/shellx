# shellcheck shell=bash disable=SC2068,SC2154,SC2145

# Log levels
_shellx_loglevel_debug="${_color_green}DEBUG${_color_reset}"
_shellx_loglevel_info="${_color_yellow}INFO${_color_reset}"
_shellx_loglevel_warn="${_color_white}WARN${_color_reset}"
_shellx_loglevel_error="${_color_red}ERROR${_color_reset}"

shellx::__log_level() {
  case "${1}" in
    DEBUG) echo "${_shellx_loglevel_debug}" ;;
    INFO) echo "${_shellx_loglevel_info}" ;;
    ERROR) echo "${_shellx_loglevel_error}" ;;
    *) echo "${_shellx_loglevel_warn}" ;;
  esac
}

# Generic log function
shellx::log() {
  shellx::debug_enabled && \
  echo "$(date "+%Y/%m/%d %H:%M:%S") [$(shellx::__log_level "${1:-DEBUG}")] ${@:2:$#}"
}

# Specific level log functions
shellx::log_debug() { shellx::log "DEBUG" $@; }
shellx::log_error() { shellx::log "ERROR" $@; }
shellx::log_info() { shellx::log "INFO" $@; }
shellx::log_warn() { shellx::log "WARN" $@; }
