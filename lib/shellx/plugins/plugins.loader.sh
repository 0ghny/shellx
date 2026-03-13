# shellcheck shell=bash

#######################################
# Internal: Rebuilds the __shellx_plugins_locations array.
# Clears any existing locations and reloads them from:
#   1. The bundled plugins directory inside the ShellX install ($__shellx_pluginsdir).
#   2. Extra locations listed in SHELLX_PLUGINS_EXTRA.
#   3. Subdirectories and symlinks inside $__shellx_plugins_d.
# Globals:
#   __shellx_plugins_locations - Rebuilt in place.
#   __shellx_pluginsdir        - Bundled plugins path.
#   __shellx_plugins_d         - User plugins.d directory.
#   SHELLX_PLUGINS_EXTRA       - Array of additional plugin locations.
#######################################
shellx::plugins::internal::dir_reload(){
  # Clean shellx plugins locations global variable first since we wanna reload
  shellx::log_debug "Cleaning _shellx_plugins_locations variable to reload"
  __shellx_plugins_locations=( )
  shellx::log_debug "__shellx_plugins_locations -> ${__shellx_plugins_locations[*]}"

  # BUNDLED PLUGINS: plugins folder from inside shellx installation directory
  # shellcheck disable=SC2154
  if [ -d "${__shellx_pluginsdir}" ]; then
    shellx::log_debug "Bundled Plugins: adding bundled from ${__shellx_pluginsdir} to location list"
    # shellcheck disable=SC2206
    export __shellx_plugins_locations=( ${__shellx_plugins_locations[*]} "${__shellx_homedir}" )
  else
    shellx::log_debug "Bundled Plugins: Cannot find bundled plugins directory or permissions are not correct."
  fi

  # SHELLX_PLUGINS_EXTRA location
  IFS=""
  for location in "${SHELLX_PLUGINS_EXTRA[@]}"; do
    if [ -d "${location}" ]; then
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

#######################################
# Reloads the ShellX configuration and all discovered plugins.
# Steps:
#   1. Reloads ShellX config via shellx::config::reload.
#   2. Rebuilds plugin location list via shellx::plugins::internal::dir_reload.
#   3. Sources each plugin file found under <location>/plugins/.
#   4. Respects the SHELLX_PLUGINS selective loading filter:
#      - @all or empty: load everything
#      - @<package>: load all plugins from a package
#      - <file>.sh: load a specific plugin file
# Globals:
#   __shellx_plugins_loaded     - Rebuilt in place with loaded plugin identifiers.
#   __shellx_plugins_locations  - Used as the list of plugin search paths.
#   SHELLX_PLUGINS              - Optional selective loading filter.
#######################################
shellx::plugins::reload() {
  # Reload shellx configuration
  shellx::config::reload

  # Reload plugins directories first
  shellx::plugins::internal::dir_reload

  shellx::log_debug "Cleaning __shellx_plugins_loaded variable to reload"
  __shellx_plugins_loaded=( )
  shellx::log_debug "__shellx_plugins_loaded -> ${__shellx_plugins_loaded[*]}"

  # Reload all plugins configured into the system
  shellx::log_debug "__shellx_plugins_locations => ${__shellx_plugins_locations[*]}"
  shellx::log_debug "selective plugin filter => ${SHELLX_PLUGINS[*]:-@all}"
  for location in "${__shellx_plugins_locations[@]}"; do
    shellx::log_debug "Plugins Load: reading scripts in location ${location}/plugins (sorted by name desc: 01-script.sh is first)"

    # If no folder `plugins` exists, skip
    if [ ! -d "${location}/plugins" ]; then
      shellx::log_debug "No plugins folder found in ${location}, did your plugins package follow the required structure?, skipping..."
      continue
    fi

    # Load all plugins in the plugins folder for current plugins package location
    IFS=$'\n'
    # shellcheck disable=SC2207
    files_in_current_location=($(find "${location}/plugins" -type f -name '*.*sh' | sort))
    unset IFS
    for file_to_load in "${files_in_current_location[@]}"; do
      shellx::log_debug "Applying selective filter to determine if plugin ${file_to_load} should be loaded"
      # Selective loading feature
      # 1. if SHELLX_PLUGINS contains @all or is not defined, load the plugin
      should_load=0
      if [ -z "${SHELLX_PLUGINS}" ] || case "${SHELLX_PLUGINS[*]}" in *@all*) true ;; *) false ;; esac; then
        should_load=1
      else
        for token in "${SHELLX_PLUGINS[@]}"; do
          if [ "${token}" = "@$(basename "${location}")" ] || \
            [ "${token}.sh" = "@$(basename "${location}")/$(basename "${file_to_load}")" ] || \
            [ "${token}.sh" = "$(basename "${file_to_load}")" ]; then
            should_load=1
            break
          fi
        done
      fi

      # Loadcheck, if should_load is 1
      if [ "${should_load}" -eq 1 ]; then
        if [ -r "$file_to_load" ]; then
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
