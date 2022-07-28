# shellcheck shell=bash
# For Korn shells (ksh, mksh, etc.), capture $_ (the final parameter passed to
# the last command) straightaway, as it will contain the path to this script.
# For Bash, ${BASH_SOURCE[0]} will be used to obtain this script's path.
# For Zsh and others, $0 (the path to the shell or script) will be used.
_under="$_"
if [ "${BASH_SOURCE[0]}" != "" ]; then
  _shellxLocation="${BASH_SOURCE[0]}"
elif [[ "$_under" == *".sh" ]]; then
  _shellxLocation="$_under"
else
  _shellxLocation="$0"
fi
# .............................................................................
#                                                                    [ GLOBAL ]
# .............................................................................
declare -ag __shellx_plugins_loaded
declare -ag __shellx_plugins_locations
declare -g __shellx_homedir="${SHELLX_HOME:-${_shellxLocation}}"
declare -g __shellx_bindir="${SHELLX_BIN:-${__shellx_homedir}/bin}"
declare -g __shellx_libdir="${SHELLX_LIB:-${__shellx_homedir}/lib}"
declare -g __shellx_pluginsdir="${SHELLX_PLUGINS:-${__shellx_homedir}/plugins}"
# .............................................................................
#                                                                 [ LIBRARIES ]
# .............................................................................
for file in "${__shellx_libdir}"/*.sh; do
    [ -r "${file}" ] && builtin source "${file}"
done
unset file
# .............................................................................
#                                                                [ HOME-EXTRA ]
# .............................................................................
if [ -z "${SHELLX_SKIP_EXTRA}" ]; then
    for file in "${HOME}"/.{path,exports,aliases,functions,extra}; do
        [ -r "${file}" ] && builtin source "${file}"
    done
    unset file
fi
# .............................................................................
#                                                                       [ BIN ]
# .............................................................................
export SHELLX_PATH_BACKUP="${PATH}"
_PATHS=( "$HOME/bin" "$HOME/.local/bin" "${__shellx_bindir}")
for _path in "${_PATHS[@]}"; do
    path::add "${_path}"
done
# .............................................................................
#                                                                   [ PLUGINS ]
# .............................................................................
__shellx_plugins_locations+=( "${__shellx_homedir}/plugins" )
IFS+""
for location in "${SHELLX_PLUGINS_EXTRA[@]}"; do
  __shellx_plugins_locations+=( "${location}")
done
unset IFS location

for location in "${__shellx_plugins_locations[@]}"; do
  IFS=$'\n'
  files_in_current_location=($(find "${location}" -name '*.*sh'))
  unset IFS
  for file in "${files_in_current_location[@]}"; do
    if [ -r "$file" ]; then
        builtin source "${file}"
        __shellx_plugins_loaded+=( "$(basename "${file}")" )
    fi
  done
  unset files_in_current_location
done
unset file location
# .............................................................................
#                                                                    [ BANNER ]
# .............................................................................
cat << EOF
 Plugins loaded: ${__shellx_plugins_loaded[*]:-0}
EOF