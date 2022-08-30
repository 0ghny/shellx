# shellcheck shell=bash

shellx::debug_enabled() {
  [[ -n "${SHELLX_DEBUG}" ]]
}
