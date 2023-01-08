# shellcheck shell=bash disable=SC2154

shellx::session::private::libraries() {
  echo "Libraries:"
  if ! [[ -x "$(command -v column)" ]]; then
    for lib in "${__shellx_loaded_libraries[@]}"; do
    echo "    [*] ${lib}"
    done
  else
    for lib in "${__shellx_loaded_libraries[@]}"; do
      echo "    [*] ${lib}"
    done | column
  fi
  unset lib
}

shellx::session::private::plugins() {
  echo "Plugins:"
  echo "  Applied filter: ${SHELLX_PLUGINS[*]:-@all}"
  if ! [[ -x "$(command -v column)" ]]; then
    echo "  Packages:"
    for loc in "${__shellx_plugins_locations[@]}"; do
      echo "    [*] [@$(basename "${loc}")] ${loc}"
    done
    echo "  Loaded:"
    for plug in "${__shellx_plugins_loaded[@]}"; do
      echo "    [*] ${plug}"
    done
  else
    echo "  Packages:"
    for loc in "${__shellx_plugins_locations[@]}"; do
      echo "    [*] [@$(basename "${loc}")] ${loc}"
    done | column
    echo "  Loaded:"
    for plug in "${__shellx_plugins_loaded[@]}"; do
      echo "    [*] ${plug}"
    done | column
  fi
  unset loc plug
}

shellx::session::info() {

cat<<EOF
  _____ _          _ _  __   __
 / ____| |        | | | \ \ / /
| (___ | |__   ___| | |  \ V / 
 \___ \| '_ \ / _ \ | |   > < 
 ____) | | | |  __/ | |  / . \ 
|_____/|_| |_|\___|_|_| /_/ \_\ 

 version -> $(shellx::version)

Release Notes:
$(shellx::version::notes)

EOF

  echo "Session information:"
  echo "  User $USER in ${HOST:-${HOSTNAME:-Unknown}}"
  echo "  Started at $(time::to_human_readable "${__shellx_feature_loadtime_start}")"
  echo "  Loaded in: $(time::to_human_readable "$(stopwatch::elapsed "$__shellx_feature_loadtime_start" "$__shellx_feature_loadtime_end")")"
  echo ""
  shellx::session::private::libraries
  echo ""
  shellx::session::private::plugins
}
# Command shellx::info
alias shellx::info='shellx::session::info'

# Command shellx reset
alias shellx::reset='exec $SHELL'
