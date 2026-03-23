#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs: plugins.utils.sh calls io::exists (via is_installed) and log functions
shellx::log_error() { :; }
shellx::log_warn()  { :; }
shellx::log_info()  { :; }
shellx::log_debug() { :; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/io.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/plugins/plugins.utils.sh"

set_up() {
  export __shellx_plugins_d="/tmp/shellx-unit-test-plugins-d-$$"
  mkdir -p "${__shellx_plugins_d}"
}

tear_down() {
  rm -rf "${__shellx_plugins_d}"
  unset __shellx_plugins_d
}

# -----------------------------------------------------------------------------
# shellx::plugins::path
# -----------------------------------------------------------------------------

function test_plugins_path_returns_correct_path_for_plugin_name() {
  local result
  result=$(shellx::plugins::path "myplugin")
  assert_same "${__shellx_plugins_d}/myplugin" "${result}"
}

function test_plugins_path_combines_base_dir_and_name() {
  local result
  result=$(shellx::plugins::path "some-package")
  assert_contains "${__shellx_plugins_d}" "${result}"
}

function test_plugins_path_appends_name_to_base_dir() {
  local result
  result=$(shellx::plugins::path "testpkg")
  assert_contains "testpkg" "${result}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::name
# -----------------------------------------------------------------------------

function test_plugins_name_extracts_basename_from_full_path() {
  local result
  result=$(shellx::plugins::name "/some/path/to/myplugin")
  assert_same "myplugin" "${result}"
}

function test_plugins_name_handles_plugins_d_path() {
  local result
  result=$(shellx::plugins::name "${__shellx_plugins_d}/community")
  assert_same "community" "${result}"
}

function test_plugins_name_returns_name_for_nested_path() {
  local result
  result=$(shellx::plugins::name "/a/b/c/the-plugin")
  assert_same "the-plugin" "${result}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::is_installed
# -----------------------------------------------------------------------------

function test_plugins_is_installed_returns_true_when_plugin_dir_exists() {
  mkdir -p "${__shellx_plugins_d}/myplugin"
  shellx::plugins::is_installed "myplugin"
  assert_exit_code "0"
}

function test_plugins_is_installed_returns_false_when_plugin_dir_does_not_exist() {
  shellx::plugins::is_installed "nonexistent-plugin-xyz" 2>/dev/null
  assert_unsuccessful_code
}
