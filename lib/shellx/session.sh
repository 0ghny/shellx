# shellcheck shell=bash disable=SC2154

#######################################
# Renders the loaded libraries in a 3-column grid inside the info box.
# Internal helper for shellx::info.
# Globals:
#   __shellx_loaded_libraries - Array of loaded library filenames.
#   _color_*                  - Color variables.
# Outputs:
#   Writes formatted library grid to stdout.
#######################################
shellx::session::private::libraries() {
  local _i=0 _lib
  for _lib in "${__shellx_loaded_libraries[@]}"; do
    _i=$((_i + 1))
    printf "  ${_color_bold_white}│${_color_reset}   ${_color_cyan}·${_color_reset} %-20s" "${_lib}"
    [ $((_i % 3)) -eq 0 ] && printf "\n"
  done
  [ $((_i % 3)) -ne 0 ] && printf "\n"
  return 0
}

#######################################
# Renders the plugins section (filter, packages, loaded) inside the info box.
# Internal helper for shellx::info.
# Globals:
#   __shellx_plugins_locations - Array of known plugin package paths.
#   __shellx_plugins_loaded    - Array of loaded plugin identifiers.
#   SHELLX_PLUGINS             - Active selective load filter.
#   _color_*                   - Color variables.
# Outputs:
#   Writes formatted plugins section to stdout.
#######################################
shellx::session::private::plugins() {
  local _i=0 _loc _name
  printf "  ${_color_bold_white}│${_color_reset}   ${_color_yellow}Filter:${_color_reset} %s\n" "${SHELLX_PLUGINS[*]:-@all}"
  printf "  ${_color_bold_white}│${_color_reset}\n"

  printf "  ${_color_bold_white}│${_color_reset}   ${_color_bold_white}Packages:${_color_reset}\n"
  for _loc in "${__shellx_plugins_locations[@]}"; do
    _i=$((_i + 1))
    _name="[@$(basename "${_loc}")]"
    printf "  ${_color_bold_white}│${_color_reset}     ${_color_bold_blue}%-28s${_color_reset}" "${_name}"
    [ $((_i % 2)) -eq 0 ] && printf "\n"
  done
  [ $((_i % 2)) -ne 0 ] && printf "\n"

  printf "  ${_color_bold_white}│${_color_reset}\n"
  printf "  ${_color_bold_white}│${_color_reset}   ${_color_bold_white}Loaded:${_color_reset}\n"

  local _plug _i=0 _maxlen=0 _len _colw
  # First pass: find the longest name to size the column
  for _plug in "${__shellx_plugins_loaded[@]}"; do
    _len=${#_plug}
    [ $_len -gt $_maxlen ] && _maxlen=$_len
  done
  _colw=$((_maxlen + 4))

  for _plug in "${__shellx_plugins_loaded[@]}"; do
    _i=$((_i + 1))
    printf "  ${_color_bold_white}│${_color_reset}     ${_color_green}·${_color_reset} %-${_colw}s" "${_plug}"
    [ $((_i % 2)) -eq 0 ] && printf "\n"
  done
  [ $((_i % 2)) -ne 0 ] && printf "\n"
  return 0
}


#######################################
# Displays a session status box with user, start time, and load time.
# Globals:
#   USER                          - Current username.
#   HOST / HOSTNAME               - Current hostname.
#   __shellx_feature_loadtime_start - Unix timestamp of ShellX load start.
#   __shellx_feature_loadtime_end   - Unix timestamp of ShellX load completion.
#   _color_*                        - Color variables.
# Outputs:
#   Writes formatted session status block to stdout.
#######################################
shellx::session::status() {
  printf "${_color_bold_white}┌─ Session Information${_color_reset}\n"
  printf "${_color_bold_white}│${_color_reset}  ${_color_yellow}User:${_color_reset}       %s @ %s\n" "${USER}" "${HOST:-${HOSTNAME:-Unknown}}"

  local start_time
  start_time=$(date -d @"${__shellx_feature_loadtime_start}" 2>/dev/null || date -r "${__shellx_feature_loadtime_start}" 2>/dev/null || echo "Unknown")
  printf "${_color_bold_white}│${_color_reset}  ${_color_yellow}Started:${_color_reset}    %s\n" "${start_time}"

  local elapsed_sec loaded_in
  elapsed_sec=$(time::elapsed "$__shellx_feature_loadtime_start" "$__shellx_feature_loadtime_end")
  loaded_in=$(time::to_human_readable "${elapsed_sec}")
  printf "${_color_bold_white}│${_color_reset}  ${_color_yellow}Loaded in:${_color_reset}  %s\n" "${loaded_in}"
  printf "${_color_bold_white}└─────────────────────${_color_reset}\n"
}

#######################################
# Displays full ShellX information: ASCII banner, version, session status,
# loaded libraries, and plugins.
# Combines shellx::session::status with the private library and plugin renderers.
# Globals:
#   _color_*         - Color variables.
# Outputs:
#   Writes the full info panel to stdout.
#######################################
shellx::info() {
  printf "${_color_bold_cyan}"
cat<<'EOF'
  _____ _          _ _  __   __
 / ____| |        | | | \ \ / /
| (___ | |__   ___| | |  \ V / 
 \___ \| '_ \ / _ \ | |   > < 
 ____) | | | |  __/ | |  / . \ 
|_____/|_| |_|\___|_|_| /_/ \_\ 
EOF
  printf "${_color_reset}"
  printf "              ${_color_bold_yellow}%s${_color_reset}\n\n" "$(shellx::version)"

  shellx::session::status

  printf "${_color_bold_white}├─ Libraries${_color_reset}\n"
  shellx::session::private::libraries
  printf "${_color_bold_white}│${_color_reset}\n"
  printf "${_color_bold_white}└─ Plugins${_color_reset}\n"
  shellx::session::private::plugins
  return 0
}

# Command shellx reset
alias shellx::reset='exec $SHELL'
