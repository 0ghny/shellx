# shellcheck shell=bash

# shellcheck disable=SC2154
shellx::config::reload() {
  if [[ -n "${SHELLX_CONFIG}" ]] && [[ -r "${SHELLX_CONFIG}" ]]; then
    export __shellx_config="${SHELLX_CONFIG}"
  elif [[ -r "${HOME}"/.shellxrc ]]; then
    export __shellx_config="${HOME}"/.shellxrc
  elif [[ -r "${HOME}"/.config/shellx/config ]]; then
    export __shellx_config="${HOME}"/.config/shellx/config
  else
    echo "ShellX Configuration file not found, applying defaults."
  fi

  # Ensure some special vars are unset
  unset SHELLX_PLUGINS

  if [[ -n "${__shellx_config}" ]]; then
    set -o allexport
    # shellcheck disable=SC1090
    source "${__shellx_config}"
    set +o allexport
  fi
}

shellx::config::print() {
  env | grep SHELLX_
}
