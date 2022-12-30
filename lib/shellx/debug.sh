# shellcheck shell=bash

shellx::debug::is_enabled() {
  [[ -n "${SHELLX_DEBUG}" ]]
}

shellx::debug::enable() {
  env::export "SHELLX_DEBUG" "yes"
}

shellx::debug::disable() {
  env::export "SHELLX_DEBUG" ""
}
