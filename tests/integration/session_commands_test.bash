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
  # WHY this symlink is required:
  # The test config (tests/config/shellx_config) sets SHELLX_PLUGINS=( @.shellx ).
  # The plugin loader resolves @<name> tokens by scanning SHELLX_PLUGINS_D for entries
  # whose basename matches <name>. Without a directory/symlink called '.shellx' inside
  # SHELLX_PLUGINS_D, the token '@.shellx' never matches and no plugins are loaded,
  # causing all tests that depend on loaded plugins to fail.
  ln -s "${SHELLX_HOME}" "${SHELLX_PLUGINS_D}/.shellx"
  # shellcheck source=/dev/null
  source "${SHELLX_HOME}/shellx.sh"
}

tear_down() {
  rm -rf "${SHELLX_PLUGINS_D}"
}

# --- shellx list (loaded plugins) ---

function test_list_exits_successfully() {
  shellx list > /dev/null 2>&1
  assert_exit_code "0"
}

function test_list_shows_loaded_plugins_header() {
  local output
  output=$(shellx list 2>/dev/null)
  assert_contains "ShellX Loaded Plugins" "${output}"
}

function test_list_shows_shellx_group() {
  local output
  output=$(shellx list 2>/dev/null)
  assert_contains "@.shellx" "${output}"
}

function test_list_shows_shellx_update_plugin() {
  local output
  output=$(shellx list 2>/dev/null)
  assert_contains "shellx_update.sh" "${output}"
}

function test_list_shows_total_count() {
  local output
  output=$(shellx list 2>/dev/null)
  assert_contains "Total:" "${output}"
}

# --- shellx status ---

function test_status_exits_successfully() {
  shellx status > /dev/null 2>&1
  assert_exit_code "0"
}

function test_status_displays_session_information() {
  local output
  output=$(shellx status 2>/dev/null)
  assert_contains "Session Information" "${output}"
}

function test_status_displays_current_user() {
  local output
  output=$(shellx status 2>/dev/null)
  assert_contains "${USER}" "${output}"
}

function test_status_displays_loaded_in_time() {
  local output
  output=$(shellx status 2>/dev/null)
  assert_contains "Loaded in:" "${output}"
}

function test_status_displays_started_time() {
  local output
  output=$(shellx status 2>/dev/null)
  assert_contains "Started:" "${output}"
}

# --- shellx reload (plugins + config) ---

function test_reload_exits_successfully() {
  shellx reload > /dev/null 2>&1
  assert_exit_code "0"
}

function test_reload_reloads_config_values() {
  # Mutate a config variable in the session, then reload and verify it is
  # reset to what the config file specifies (SHELLX_DEBUG=no in shellx_config).
  SHELLX_DEBUG="reload_test_marker"
  shellx reload > /dev/null 2>&1
  assert_same "no" "${SHELLX_DEBUG}"
}

function test_reload_keeps_plugins_loaded() {
  local count_before count_after
  count_before=${#__shellx_plugins_loaded[@]}
  shellx reload > /dev/null 2>&1
  count_after=${#__shellx_plugins_loaded[@]}
  assert_same "${count_before}" "${count_after}"
}
