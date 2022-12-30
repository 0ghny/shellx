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
#
# NOTE: if you modify this section, remember to update shellx::config::reload
# function too. It cannot be there since libs hasn't been loaded yet
# .............................................................................
if [[ -n "${SHELLX_CONFIG}" ]] && [[ -r "${SHELLX_CONFIG}" ]]; then
  export __shellx_config="${SHELLX_CONFIG}"
elif [[ -r "${HOME}"/.shellxrc ]]; then
  export __shellx_config="${HOME}"/.shellxrc
elif [[ -r "${HOME}"/.config/shellx/config ]]; then
  export __shellx_config="${HOME}"/.config/shellx/config
else
  echo "ShellX Configuration file not found, applying defaults."
fi

if [[ -n "${__shellx_config}" ]]; then
  set -o allexport
  # shellcheck disable=SC1090
  source "${__shellx_config}"
  set +o allexport
fi
# .............................................................................
#                                                                    [ GLOBAL ]
# .............................................................................
export __shellx_plugins_loaded=()
export __shellx_plugins_locations=()
export __shellx_loaded_libraries=()

export __shellx_homedir="${SHELLX_HOME:-$(dirname "${_shellxLocation}")}"
export __shellx_bindir="${__shellx_homedir}/bin"
export __shellx_libdir="${__shellx_homedir}/lib"
export __shellx_plugins_d="${SHELLX_PLUGINS_D:-${HOME}/.shellx.plugins.d}"
export __shellx_pluginsdir="${__shellx_homedir}/plugins"
declare -g __shellx_feature_loadtime_start="$__internal_init_time"
declare -g __shellx_feature_loadtime_end="$__internal_init_time"
# .............................................................................
#                                                                 [ LIBRARIES ]
# .............................................................................
for file_to_load in $(find "${__shellx_libdir}" -name '*.*sh' | sort); do
  if [[ -r "${file_to_load}" ]]; then
    # shellcheck source=/dev/null
    source "${file_to_load}"
    # shellcheck disable=SC2206
    export __shellx_loaded_libraries=( ${__shellx_loaded_libraries[*]} "$(basename "${file_to_load}")" )
  fi
done
unset file_to_load
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
shellx::log_info "Feature: home-extra"
if [[ -z "${SHELLX_SKIP_EXTRA}" ]]; then
  shellx::log_debug "feat(home-extra): enabled"
  for file_to_load in "${HOME}"/.{path,exports,aliases,functions,extra}; do
    if [[ -r "${file_to_load}" ]]; then
      shellx::log_debug "feat(home-extra): loading file ${file_to_load}"
      # shellcheck source=/dev/null
      source "${file_to_load}"
    fi
  done
  unset file_to_load
else
  shellx::log_debug "feat(home-extra): disabled"
fi
shellx::log_info "Feature: home-extra finalized"
# .............................................................................
#                                                               [ PATH-BACKUP ]
# .............................................................................
shellx::log_debug "feat(path-backup): Backing up PATH variable to SHELLX_PATH_BACKUP"
path::backup "SHELLX_PATH_BACKUP"
# .............................................................................
#                                                                       [ BIN ]
# .............................................................................
shellx::log_info "Feature: Multi-Bin folder support"
_PATHS=( "$HOME/bin" "$HOME/.local/bin" "${__shellx_bindir}")
for _path in "${_PATHS[@]}"; do
  shellx::log_debug "feat(multi-bin): adding bin folder (${_path}) to PATH"
  path::add "${_path}"
done
shellx::log_debug "feat(multi-bin): shellx-bin folder make scripts runnable"
find "${__shellx_bindir}" -type f -exec chmod 744 {} \;
shellx::log_info "Feature: Multi-Bin Finalized"
# .............................................................................
#                                                                   [ PLUGINS ]
# .............................................................................
shellx::log_info "Feature: Plugins enabled"
shellx::plugins::reload
shellx::log_info "Feature: Plugins finalized"
# .............................................................................
#                                                                 [ POST-HOOK ]
# .............................................................................
# Calculates here time expend
__shellx_feature_loadtime_end="$(date +%s)"
# .............................................................................
#                                                                    [ BANNER ]
# Shows a summary banner, can be skip with SHELLX_NO_BANNER variable
# .............................................................................
if [[ -z "${SHELLX_NO_BANNER}" ]]; then
  shellx::session::info
fi
