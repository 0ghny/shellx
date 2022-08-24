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
# .............................................................................
if [[ -f "${HOME}"/.shellxrc ]]; then
  source "${HOME}"/.shellxrc
fi
# .............................................................................
#                                                                    [ GLOBAL ]
# .............................................................................
export __shellx_plugins_loaded=()
export __shellx_plugins_locations=()
export __shellx_homedir="${SHELLX_HOME:-$(dirname ${_shellxLocation})}"
export __shellx_bindir="${SHELLX_BIN:-${__shellx_homedir}/bin}"
export __shellx_libdir="${SHELLX_LIB:-${__shellx_homedir}/lib}"
export __shellx_plugins_d="${SHELLX_PLUGINS_D:-${HOME}/.shellx.plugins.d}"
export __shellx_pluginsdir="${SHELLX_PLUGINS:-${__shellx_homedir}/plugins}"
declare -g __shellx_feature_loadtime_start="$__internal_init_time"
declare -g __shellx_feature_loadtime_end="$__internal_init_time"
# Debug output
[[ -n "${SHELLX_DEBUG}" ]] && cat << EOF
  DEBUG Variables:
  - __shellx_homedir      ${SHELLX_HOME:-$(dirname ${_shellxLocation})}
  - __shellx_bindir       ${SHELLX_BIN:-${__shellx_homedir}/bin}
  - __shellx_libdir:      ${SHELLX_LIB:-${__shellx_homedir}/lib}
  - __shellx_plugins_d:   ${SHELLX_PLUGINS_D:-${HOME}/.shellx.plugins.d}
  - __shellx_pluginsdir:  ${SHELLX_PLUGINS:-${__shellx_homedir}/plugins}
EOF
# .............................................................................
#                                                                 [ LIBRARIES ]
# .............................................................................
[[ -n "${SHELLX_DEBUG}" ]] && echo "Feature: internal libs"
for file in $(find "${__shellx_libdir}" -name '*.*sh'); do
  if [[ -r "${file}" ]]; then
    [[ -n "${SHELLX_DEBUG}" ]] && echo "internal libs: loading library: ${file}"
    builtin source "${file}"
  fi
done
unset file
# .............................................................................
#                                                                [ HOME-EXTRA ]
# .............................................................................
if [[ -z "${SHELLX_SKIP_EXTRA}" ]]; then
  [[ -n "${SHELLX_DEBUG}" ]] && echo "Feature: home-extra enabled"
  for file in "${HOME}"/.{path,exports,aliases,functions,extra}; do
    if [[ -r "${file}" ]]; then
      [[ -n "${SHELLX_DEBUG}" ]] && echo "Loading home-extra file: ${file}"
      builtin source "${file}"
    fi
  done
  unset file
fi
# .............................................................................
#                                                               [ PATH-BACKUP ]
# .............................................................................
[[ -n "${SHELLX_DEBUG}" ]] && echo "Backing up PATH variable to SHELLX_PATH_BACKUP"
export SHELLX_PATH_BACKUP="${PATH}"
# .............................................................................
#                                                                       [ BIN ]
# .............................................................................
[[ -n "${SHELLX_DEBUG}" ]] && echo "Feature: Multi-Bin folder support"
_PATHS=( "$HOME/bin" "$HOME/.local/bin" "${__shellx_bindir}")
for _path in "${_PATHS[@]}"; do
  [[ -n "${SHELLX_DEBUG}" ]] && echo "multi-bin: adding bin folder (${_path}) to PATH"
  path::add "${_path}"
done
# .............................................................................
#                                                                   [ PLUGINS ]
# .............................................................................
[[ -n "${SHELLX_DEBUG}" ]] && echo "Plugins feature enabled"

# __shellx_pluginsdir location
if [[ -d "${__shellx_pluginsdir}" ]]; then
  [[ -n "${SHELLX_DEBUG}" ]] && echo "Bundled Plugins: Adding ${__shellx_pluginsdir} to location list"
  export __shellx_plugins_locations=( "${__shellx_pluginsdir}" )
fi
# SHELLX_PLUGINS_EXTRA location
IFS=""
for location in "${SHELLX_PLUGINS_EXTRA[@]}"; do
  if [[ -d "${location}" ]]; then
    [[ -n "${SHELLX_DEBUG}" ]] && echo "Extra Plugins: adding (${location}) to location list"
    export __shellx_plugins_locations=( "${__shellx_plugins_locations[*]}" "${location}" )
  fi
done
unset IFS location
# ~/.shellx.plugins.d location
if [ -d "${__shellx_plugins_d}" ]; then
  [[ -n "${SHELLX_DEBUG}" ]] && echo "shellx.plugins.d: folder found at ${__shellx_plugins_d}"
  for location in $(find "${__shellx_plugins_d}" -mindepth 1 -maxdepth 1 -type d -or -type l); do
    [[ -n "${SHELLX_DEBUG}" ]] && echo "shellx.plugins.d: adding ${location} to location list"
    export __shellx_plugins_locations=( "${__shellx_plugins_locations[*]}" "${location}" )
  done
fi
unset location
# Plugins: load all plugins from all locations
[[ -n "${SHELLX_DEBUG}" ]] && cat << EOF
Plugins: Init loading of libraries
  __shellx_plugins_locations => ${__shellx_plugins_locations[@]}
EOF
for location in "${__shellx_plugins_locations[@]}"; do
  IFS=$'\n'
  # shellcheck disable=SC2207
  files_in_current_location=($(find "${location}/" -type f -name '*.*sh'))
  unset IFS
  for file in "${files_in_current_location[@]}"; do
    if [[ -r "$file" ]]; then
      [[ -n "${SHELLX_DEBUG}" ]] && echo "Plugins Load: Loading plugin file ${file}"
      source "${file}"
      export __shellx_plugins_loaded=( "${__shellx_plugins_loaded[*]}" "$(basename "${file}")" )
    fi
  done
  unset files_in_current_location
done
unset file location
[[ -n "${SHELLX_DEBUG}" ]] && echo "Plugins: finish loading libraries"
__shellx_feature_loadtime_end="$(date +%s)"
# .............................................................................
#                                                                    [ BANNER ]
# .............................................................................
cat << EOF
 Plugins loaded: ${__shellx_plugins_loaded[*]:-0}
 Plugins locations: ${__shellx_plugins_locations[*]:-unknown locations}
 Loaded in: $(time::to_human_readable "$(stopwatch::elapsed "$__shellx_feature_loadtime_start" "$__shellx_feature_loadtime_end")")
EOF
