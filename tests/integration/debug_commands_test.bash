#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
SHELLX_PLUGINS_D=/tmp/shellx-bashunit-tests
SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config"
SHELLX_DEBUG=no
SHELLX_NO_BANNER=1
export SHELLX_HOME SHELLX_PLUGINS_D SHELLX_DEBUG SHELLX_CONFIG SHELLX_NO_BANNER

set_up() {
  rm -rf "${SHELLX_PLUGINS_D}"
  mkdir -p "${SHELLX_PLUGINS_D}"
  # shellcheck source=/dev/null
  source "${SHELLX_HOME}/shellx.sh"
}

tear_down() {
  rm -rf "${SHELLX_PLUGINS_D}"
  # Restore debug state
  SHELLX_DEBUG=no
  export SHELLX_DEBUG
}

# --- shellx debug ---

function test_debug_enable_exits_successfully() {
  shellx debug enabled > /dev/null 2>&1
  assert_exit_code "0"
}

function test_debug_disable_exits_successfully() {
  shellx debug enabled > /dev/null 2>&1
  shellx debug disabled > /dev/null 2>&1
  assert_exit_code "0"
}

function test_debug_invalid_action_returns_error() {
  shellx debug invalid_action > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_debug_no_args_returns_error() {
  shellx debug > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_debug_no_args_shows_current_status() {
  local output
  output="$(shellx debug 2>&1)"
  assert_contains "Current Status:" "${output}"
}

function test_debug_no_args_shows_usage() {
  local output
  output="$(shellx debug 2>&1)"
  assert_contains "Usage: shellx debug enabled|disabled" "${output}"
}

function test_debug_no_args_shows_disabled_status_when_debug_off() {
  SHELLX_DEBUG=no
  export SHELLX_DEBUG
  local output
  output="$(shellx debug 2>&1)"
  assert_contains "Current Status: disabled" "${output}"
}

function test_debug_no_args_shows_enabled_status_when_debug_on() {
  shellx debug enabled > /dev/null 2>&1
  local output
  output="$(shellx debug 2>&1)"
  assert_contains "Current Status: enabled" "${output}"
}

function test_debug_enable_sets_shellx_debug_variable() {
  shellx debug enabled > /dev/null 2>&1
  assert_same "yes" "${SHELLX_DEBUG}"
}

function test_debug_disable_unsets_shellx_debug_variable() {
  shellx debug enabled > /dev/null 2>&1
  shellx debug disabled > /dev/null 2>&1
  assert_empty "${SHELLX_DEBUG}"
}

function test_debug_is_enabled_returns_true_when_enabled() {
  SHELLX_DEBUG=yes
  export SHELLX_DEBUG
  shellx::debug::is_enabled
  assert_exit_code "0"
}

function test_debug_is_enabled_returns_false_when_disabled() {
  SHELLX_DEBUG=no
  export SHELLX_DEBUG
  shellx::debug::is_enabled 2>/dev/null
  assert_unsuccessful_code
}
