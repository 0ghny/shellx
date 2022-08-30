# shellcheck shell=bash
__internal_init_time="$(date +%s)"
# Determine this script location compatible with many shells
_under="$_"
if [ "${BASH_SOURCE[0]}" != "" ]; then
  _shellxLocation="${BASH_SOURCE[0]}"
elif [[ "$_under" == *".sh" ]]; then
  _shellxLocation="$_under"
else
  _shellxLocation="$0"
fi

# .............................................................................
#                                               [ FEATURE: CONFIGURATION FILE ]
# Locations by priority:
#   1. ENV VAR: SHELLX_CONFIG
#   2. $HOME/.shellxrc
#   3. $HOME/.config/shellx/config
# .............................................................................
if [[ -n "${SHELLX_CONFIG}" ]] && [[ -r "${SHELLX_CONFIG}" ]]; then
  export __shellx_config="${SHELLX_CONFIG}"
elif [[ -r "${HOME}"/.shellxrc ]]; then
  export __shellx_config="${HOME}"/.shellxrc
elif [[ -r "${HOME}"/.config/shellx/config ]]; then
  export __shellx_config="${HOME}"/.config/shellx/config
else
  ;
fi

if [[ -n "${__shellx_config}" ]]; then
  set -o allexport
  source "${__shellx_config}"
  set +o allexport
fi
# .............................................................................
#                                                                    [ GLOBAL ]
# .............................................................................
export __shellx_plugins_loaded=()
export __shellx_plugins_locations=()
export __shellx_loaded_libraries=()

export __shellx_homedir="${SHELLX_HOME:-$(dirname ${_shellxLocation})}"
export __shellx_bindir="${__shellx_homedir}/bin"
export __shellx_libdir="${__shellx_homedir}/lib"
export __shellx_plugins_d="${SHELLX_PLUGINS_D:-${HOME}/.shellx.plugins.d}"
export __shellx_pluginsdir="${__shellx_homedir}/plugins"
declare -g __shellx_feature_loadtime_start="$__internal_init_time"
declare -g __shellx_feature_loadtime_end="$__internal_init_time"
# .............................................................................
#                                                                 [ LIBRARIES ]
# .............................................................................
for file in $(find "${__shellx_libdir}" -name '*.*sh' | sort); do
  if [[ -r "${file}" ]]; then
    source "${file}"
    export __shellx_loaded_libraries=( ${__shellx_loaded_libraries[*]} "$(basename ${file})" )
  fi
done
unset file
# .............................................................................
#                                                                 [ DEBUG ]
# .............................................................................
shellx::log_debug "Loaded libraries: ${__shellx_loaded_libraries[*]}"
shellx::log_debug "Variable __shellx_homedir      ${__shellx_homedir}"
shellx::log_debug "Variable __shellx_bindir       ${__shellx_bindir}"
shellx::log_debug "Variable __shellx_libdir:      ${__shellx_libdir}"
shellx::log_debug "Variable __shellx_plugins_d:   ${__shellx_plugins_d}"
shellx::log_debug "Variable __shellx_pluginsdir:  ${__shellx_pluginsdir}"
shellx::log_debug "Variable __shellx_config:      ${__shellx_config}"
# .............................................................................
#                                                                [ HOME-EXTRA ]
# .............................................................................
if [[ -z "${SHELLX_SKIP_EXTRA}" ]]; then
  shellx::log_debug "Feature: home-extra enabled"
  for file in "${HOME}"/.{path,exports,aliases,functions,extra}; do
    if [[ -r "${file}" ]]; then
      shellx::log_debug "Loading home-extra file: ${file}"
      source "${file}"
    fi
  done
  unset file
fi
# .............................................................................
#                                                               [ PATH-BACKUP ]
# .............................................................................
shellx::log_debug "Backing up PATH variable to SHELLX_PATH_BACKUP"
export SHELLX_PATH_BACKUP="${PATH}"
# .............................................................................
#                                                                       [ BIN ]
# .............................................................................
shellx::log_debug "Feature: Multi-Bin folder support"
_PATHS=( "$HOME/bin" "$HOME/.local/bin" "${__shellx_bindir}")
for _path in "${_PATHS[@]}"; do
  shellx::log_debug "multi-bin: adding bin folder (${_path}) to PATH"
  path::add "${_path}"
done
# .............................................................................
#                                                           [ BUNDLED-PLUGINS ]
# .............................................................................
# BUNDLED PLUGINS: __shellx_pluginsdir location
if [[ -d "${__shellx_pluginsdir}" ]]; then
  shellx::log_debug "Bundled Plugins: Loading from ${__shellx_pluginsdir}"

  IFS=$'\n'
  # shellcheck disable=SC2207
  files_in_current_location=($(find "${__shellx_pluginsdir}/" -type f -name '*.*sh'))
  unset IFS
  for file in "${files_in_current_location[@]}"; do
    if [[ -r "$file" ]]; then
      shellx::log_debug "Bundled Plugins: Loading bundledplugin file ${file}"
      source "${file}"
      export __shellx_plugins_loaded=( ${__shellx_plugins_loaded[*]} "@bundled/$(basename "${file}")" )
    fi
  done
  unset files_in_current_location

else
  shellx::log_debug "Bundled Plugins: Cannot find bundled plugins directory or permissions are not correct."
fi
# .............................................................................
#                                                                   [ PLUGINS ]
# .............................................................................
shellx::log_debug "Plugins feature enabled"
# SHELLX_PLUGINS_EXTRA location
IFS=""
for location in "${SHELLX_PLUGINS_EXTRA[@]}"; do
  if [[ -d "${location}" ]]; then
    shellx::log_debug "Extra Plugins: adding (${location}) to location list"
    export __shellx_plugins_locations=( ${__shellx_plugins_locations[*]} "${location}" )
  fi
done
unset IFS location
# ~/.shellx.plugins.d location
if [ -d "${__shellx_plugins_d}" ]; then
  shellx::log_debug "shellx.plugins.d: folder found at ${__shellx_plugins_d}"
  for location in $(find "${__shellx_plugins_d}" -mindepth 1 -maxdepth 1 -type d -or -type l); do
    shellx::log_debug "shellx.plugins.d: adding ${location} to location list"
    export __shellx_plugins_locations=( ${__shellx_plugins_locations[*]} "${location}" )
  done
fi
unset location
# Plugins: load all plugins from all locations
shellx::log_debug "__shellx_plugins_locations => ${__shellx_plugins_locations[@]}"
for location in "${__shellx_plugins_locations[@]}"; do
  shellx::log_debug "Plugins Load: finding scripts in location ${location}"
  IFS=$'\n'
  # shellcheck disable=SC2207
  files_in_current_location=($(find "${location}/" -type f -name '*.*sh'))
  unset IFS
  for file in "${files_in_current_location[@]}"; do
    if [[ -r "$file" ]]; then
      shellx::log_debug "Plugins Load: Loading plugin file ${file}"
      source "${file}"
      export __shellx_plugins_loaded=( ${__shellx_plugins_loaded[*]} "@$(basename "${location}")/$(basename "${file}")" )
    fi
  done
  unset files_in_current_location
done
unset file location
shellx::log_debug "Plugins: finish loading libraries"
__shellx_feature_loadtime_end="$(date +%s)"
# .............................................................................
#                                                                    [ BANNER ]
# Shows a summary banner, can be skip with SHELLX_NO_BANNER variable
# .............................................................................
if [[ -z "${SHELLX_NO_BANNER}" ]]; then
echo "ShellX initalised for $USER in $HOST"
echo "  Plugin Locations:"
echo "    - [@bundled] ${__shellx_pluginsdir}"
for loc in "${__shellx_plugins_locations[@]}"; do
echo "    - [@$(basename "${loc}")] ${loc}"
done

echo "  Plugins Loaded:"
for plug in "${__shellx_plugins_loaded[@]}"; do
echo "    - ${plug}"
done
echo "Loaded in: $(time::to_human_readable "$(stopwatch::elapsed "$__shellx_feature_loadtime_start" "$__shellx_feature_loadtime_end")")"
unset loc plug
fi
