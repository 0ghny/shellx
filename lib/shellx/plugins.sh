# shellcheck shell=bash

# .............................................................................
# LOG FUNCTIONS
# .............................................................................
shellx::plugins::log_info() {
  local plugin="${1:-unknown}"
  # shellcheck disable=SC2124
  local msg="${@:2:$#}"
  shellx::log "INFO" "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}

shellx::plugins::log_debug() {
  local plugin="${1:-unknown}"
  # shellcheck disable=SC2124
  local msg="${@:2:$#}"
  shellx::log "DEBUG" "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}

shellx::plugins::log_error() {
  local plugin="${1:-unknown}"
  # shellcheck disable=SC2124
  local msg="${@:2:$#}"
  shellx::log "ERROR" "[PLUGIN ${plugin}] ${msg:-Non specified message, maybe a bug?}"
}
# .............................................................................
# RUNTIME
# .............................................................................
shellx::plugins::loaded() {
  for plug in "${__shellx_plugins_loaded[@]}"; do
    echo "  [*] ${plug}"
  done
}

shellx::plugins::path() {
  # shellcheck disable=SC2154
  echo "${__shellx_plugins_d}/${1}"
}

# .............................................................................
# PLUGIN HANDLING
# .............................................................................
shellx::plugins::internal::dir_reload(){
  # Clean shellx plugins locations global variable first since we wanna reload
  __shellx_plugins_locations=( "${__shellx_pluginsdir}" )

  # SHELLX_PLUGINS_EXTRA location
  IFS=""
  for location in "${SHELLX_PLUGINS_EXTRA[@]}"; do
    if [[ -d "${location}" ]]; then
      shellx::log_debug "Extra Plugins: adding (${location}) to location list"
      # shellcheck disable=SC2206
      export __shellx_plugins_locations=( ${__shellx_plugins_locations[*]} "${location}" )
    fi
  done
  unset IFS location
  # ~/.shellx.plugins.d location
  if [ -d "${__shellx_plugins_d}" ]; then
    shellx::log_debug "shellx.plugins.d: folder found at ${__shellx_plugins_d}"
    # shellcheck disable=SC2044
    for location in $(find "${__shellx_plugins_d}" -mindepth 1 -maxdepth 1 -type d -or -type l); do
      shellx::log_debug "shellx.plugins.d: adding ${location} to location list"
      # shellcheck disable=SC2206
      export __shellx_plugins_locations=( ${__shellx_plugins_locations[*]} "${location}" )
    done
  fi
  unset location
}

shellx::plugins::reload() {
  # Reload plugins directories first
  shellx::plugins::internal::dir_reload

  # Reload all plugins configured into the system
  shellx::log_debug "__shellx_plugins_locations => ${__shellx_plugins_locations[*]}"
  shellx::log_debug "selective plugin filter => ${SHELLX_PLUGINS[*]:-@all}"
  for location in "${__shellx_plugins_locations[@]}"; do
    shellx::log_debug "Plugins Load: reading scripts in location ${location}"
    IFS=$'\n'
    # shellcheck disable=SC2207
    files_in_current_location=($(find "${location}/" -type f -name '*.*sh'))
    unset IFS
    for file_to_load in "${files_in_current_location[@]}"; do
      shellx::log_debug "Applying selective filter to determine if plugin ${file_to_load} should be loaded"
      # Selective loading feature
      # 1. if SHELLX_PLUGINS contains @all or is not defined, load the plugin
      should_load=0
      if [[ -z "${SHELLX_PLUGINS}" ]] || [[ "${SHELLX_PLUGINS[*]}" =~ "@all" ]]; then
        should_load=1
      else
        for token in "${SHELLX_PLUGINS[@]}"; do
          if [[ "${token}" == "@$(basename "${location}")" ]] || \
            [[ "${token}.sh" == "@$(basename "${location}")/$(basename "${file_to_load}")" ]] || \
            [[ "${token}.sh" == "$(basename "${file_to_load}")" ]]; then
            should_load=1
            break
          fi
        done
      fi

      # Loadcheck, if should_load is 1
      if [[ "${should_load}" -eq 1 ]]; then
        if [[ -r "$file_to_load" ]]; then
          shellx::log_debug "selective loading => loading ${file_to_load}"
          # shellcheck source=/dev/null
          source "${file_to_load}"
          # shellcheck disable=SC2206
          export __shellx_plugins_loaded=( ${__shellx_plugins_loaded[*]} "@$(basename "${location}")/$(basename "${file_to_load}")" )
        else
          shellx::log_warn "Plugin should be loaded but doesn't exists or is not readable, skipping."
        fi
      else
        shellx::log_debug "selective loading => not loading"
      fi
    done
    unset files_in_current_location
  done
  unset file_to_load location
}
# .............................................................................
# PLUGIN MANAGEMENT
# .............................................................................
shellx::plugins::is_installed() {
  io::exists "$(shellx::plugins::path "${1}")"
}

shellx::plugins::installed() {
  local plugin
  echo "Plugins Installed:"
  # shellcheck disable=SC2154
  for plugin in "${__shellx_plugins_locations[@]}"; do
    echo "  [*] $(basename "${plugin}") (${plugin})"
  done
}

# shellcheck disable=SC2154
shellx::plugins::install() {
  local plugin_url="${1}"

  echo -n "[PLUGIN] Cloning plugin into shellx plugins directory..."
  git clone \
          "${plugin_url}" "${__shellx_plugins_d}/$(basename "${plugin_url}")" \
      2>/dev/null 1>&2 \
    && {
      echo -e " ${_color_green}OK${_color_reset}"

      echo "[PLUGIN] Reloading plugins..."
      shellx::plugins::reload
    } || echo -e " ${_color_red}KO${_color_reset}"
}

shellx::plugins::uninstall() {
  local plugin_name="${1}"

  if ! shellx::plugins::is_installed "${plugin_name}"; then
    echo "[PLUGIN] ${plugin_name} not installed"
  else
    echo -n "[PLUGIN] ${plugin_name} uninstalling..."
    rm -rfv "$(shellx::plugins::path "${plugin_name}")" \
      2>/dev/null 1>&2 \
    && {
      echo -e " ${_color_green}OK${_color_reset}"
      shellx::plugins::internal::dir_reload
    } || echo -e " ${_color_red}KO${_color_reset}"
  fi
}
