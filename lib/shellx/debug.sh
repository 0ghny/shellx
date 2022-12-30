# shellcheck shell=bash

shellx::debug::is_enabled() {
  [[ -n "${SHELLX_DEBUG}" ]] && \
  [[ "$(string::to_upper "${SHELLX_DEBUG}")" == "YES" ]]
}

shellx::debug::enable() {
  env::export "SHELLX_DEBUG" "yes"
}

shellx::debug::disable() {
  env::export "SHELLX_DEBUG" ""
}
