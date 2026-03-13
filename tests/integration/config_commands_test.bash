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
  # Use a temp copy of the config so that config set/unset tests do not
  # modify the committed test fixture at tests/config/shellx_config.
  local _orig_config="${SHELLX_HOME}/tests/config/shellx_config"
  SHELLX_CONFIG="$(mktemp /tmp/shellx-test-config-XXXXXX)"
  cp "${_orig_config}" "${SHELLX_CONFIG}"
  export SHELLX_CONFIG
  # shellcheck source=/dev/null
  source "${SHELLX_HOME}/shellx.sh"
}

tear_down() {
  rm -rf "${SHELLX_PLUGINS_D}"
  rm -f "${SHELLX_CONFIG}"
}

# --- shellx config reload ---

function test_config_reload_exits_successfully() {
  shellx config reload > /dev/null 2>&1
  assert_exit_code "0"
}

function test_config_reload_keeps_shellx_home_set() {
  shellx config reload > /dev/null 2>&1
  assert_not_empty "${__shellx_homedir}"
}

function test_config_reload_keeps_plugins_loaded() {
  local count_before count_after
  count_before=${#__shellx_plugins_loaded[@]}
  shellx config reload > /dev/null 2>&1
  count_after=${#__shellx_plugins_loaded[@]}
  assert_same "${count_before}" "${count_after}"
}

# --- shellx config print ---

function test_config_print_exits_successfully() {
  shellx config print > /dev/null 2>&1
  assert_exit_code "0"
}

function test_config_print_displays_config_file_path() {
  local output
  output=$(shellx config print 2>/dev/null)
  assert_contains "${SHELLX_CONFIG}" "${output}"
}

function test_config_print_displays_config_contents() {
  local output
  output=$(shellx config print 2>/dev/null)
  assert_contains "SHELLX_DEBUG" "${output}"
}

# --- shellx config runtime ---

function test_config_runtime_exits_successfully() {
  shellx config runtime > /dev/null 2>&1
  assert_exit_code "0"
}

function test_config_runtime_displays_shellx_variables() {
  local output
  output=$(shellx config runtime 2>/dev/null)
  assert_contains "SHELLX_" "${output}"
}

# --- shellx config (error cases) ---

function test_config_invalid_action_returns_error() {
  shellx config invalid_action > /dev/null 2>&1
  assert_unsuccessful_code
}

# --- shellx config set ---

function test_config_set_valid_key_exits_successfully() {
  shellx config set SHELLX_DEBUG yes > /dev/null 2>&1
  assert_exit_code "0"
}

function test_config_set_writes_value_to_config_file() {
  shellx config set SHELLX_DEBUG yes > /dev/null 2>&1
  local output
  output=$(shellx config print 2>/dev/null)
  assert_contains "SHELLX_DEBUG=yes" "${output}"
}

function test_config_set_invalid_key_returns_error() {
  shellx config set INVALID_KEY value > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_config_set_missing_value_returns_error() {
  shellx config set SHELLX_DEBUG > /dev/null 2>&1
  assert_unsuccessful_code
}

# --- shellx config unset ---

function test_config_unset_valid_key_exits_successfully() {
  shellx config unset SHELLX_DEBUG > /dev/null 2>&1
  assert_exit_code "0"
}

function test_config_unset_removes_key_from_config_file() {
  shellx config set SHELLX_DEBUG yes > /dev/null 2>&1
  shellx config unset SHELLX_DEBUG > /dev/null 2>&1
  local remaining
  remaining=$(grep "^SHELLX_DEBUG=" "${SHELLX_CONFIG}" 2>/dev/null || echo "")
  assert_empty "${remaining}"
}

function test_config_unset_invalid_key_returns_error() {
  shellx config unset INVALID_KEY > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_config_unset_missing_arg_returns_error() {
  shellx config unset > /dev/null 2>&1
  assert_unsuccessful_code
}
