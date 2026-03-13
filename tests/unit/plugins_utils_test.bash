#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs: plugins.utils.sh calls shellx::log_error and shellx::plugins::config_file_path
# (the latter is defined in plugins.manager.sh, which we stub here to avoid cross-module deps)
shellx::log_error() { :; }
shellx::plugins::config_file_path() { echo "${SHELLX_HOME}/plugins.repositories"; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/colors.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/io.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/plugins/plugins.utils.sh"

set_up() {
  export __shellx_plugins_d="/tmp/shellx-unit-test-plugins-d-$$"
  mkdir -p "${__shellx_plugins_d}"
  __shellx_plugins_loaded=()
  __shellx_plugins_locations=()
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

# -----------------------------------------------------------------------------
# shellx::plugins::loaded
# -----------------------------------------------------------------------------

function test_plugins_loaded_exits_successfully_with_empty_list() {
  __shellx_plugins_loaded=()
  shellx::plugins::loaded > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_loaded_shows_no_plugins_message_when_empty() {
  __shellx_plugins_loaded=()
  local output
  output=$(shellx::plugins::loaded 2>/dev/null)
  assert_contains "No plugins loaded" "${output}"
}

function test_plugins_loaded_shows_plugin_entry_when_loaded() {
  __shellx_plugins_loaded=("@mypkg/plugin.sh")
  local output
  output=$(shellx::plugins::loaded 2>/dev/null)
  assert_contains "mypkg" "${output}"
}

function test_plugins_loaded_shows_total_count() {
  __shellx_plugins_loaded=("@pkgA/a.sh" "@pkgA/b.sh")
  local output
  output=$(shellx::plugins::loaded 2>/dev/null)
  assert_contains "Total:" "${output}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::installed
# -----------------------------------------------------------------------------

function test_plugins_installed_exits_successfully() {
  __shellx_plugins_locations=()
  shellx::plugins::installed > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_installed_output_contains_header() {
  __shellx_plugins_locations=()
  local output
  output=$(shellx::plugins::installed 2>/dev/null)
  assert_contains "ShellX Installed Plugin Packages" "${output}"
}

function test_plugins_installed_shows_no_packages_message_when_empty() {
  local output
  output=$(shellx::plugins::installed 2>/dev/null)
  assert_contains "No plugin packages installed" "${output}"
}

function test_plugins_installed_shows_location_entry() {
  __shellx_plugins_locations=("${__shellx_plugins_d}/testpkg")
  local output
  output=$(shellx::plugins::installed 2>/dev/null)
  assert_contains "testpkg" "${output}"
}

function test_plugins_installed_shows_total_count() {
  __shellx_plugins_locations=("${__shellx_plugins_d}/pkgA" "${__shellx_plugins_d}/pkgB")
  local output
  output=$(shellx::plugins::installed 2>/dev/null)
  assert_contains "Total:" "${output}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::list
# -----------------------------------------------------------------------------

function test_plugins_list_exits_successfully_with_bundled_registry() {
  shellx::plugins::list > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_list_output_contains_header() {
  local output
  output=$(shellx::plugins::list 2>/dev/null)
  assert_contains "Available Plugin Packages:" "${output}"
}

function test_plugins_list_output_contains_a_known_package() {
  local output
  output=$(shellx::plugins::list 2>/dev/null)
  assert_contains "community" "${output}"
}
