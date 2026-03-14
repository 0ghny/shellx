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

# --- shellx version ---

function test_version_exits_successfully() {
  shellx version > /dev/null 2>&1
  assert_exit_code "0"
}

function test_version_output_starts_with_v() {
  local output
  output=$(shellx version 2>/dev/null)
  assert_matches "^v[0-9]" "${output}"
}

function test_version_matches_version_file() {
  local expected actual
  expected="v$(cat "${SHELLX_HOME}/version.txt")"
  actual=$(shellx version 2>/dev/null)
  assert_contains "${expected}" "${actual}"
}

# --- shellx version info ---

function test_version_info_exits_successfully() {
  shellx version info > /dev/null 2>&1
  assert_exit_code "0"
}

function test_version_info_displays_version_number() {
  local output
  output=$(shellx version info 2>/dev/null)
  assert_contains "Version Number:" "${output}"
}

function test_version_info_displays_release_notes_section() {
  local output
  output=$(shellx version info 2>/dev/null)
  assert_contains "Release Notes" "${output}"
}

# --- shellx version notes ---

function test_version_notes_exits_successfully() {
  shellx version notes > /dev/null 2>&1
  assert_exit_code "0"
}

function test_version_notes_returns_non_empty_output() {
  local output
  output=$(shellx version notes 2>/dev/null)
  assert_not_empty "${output}"
}

# --- shellx info ---

function test_info_exits_successfully() {
  shellx info > /dev/null 2>&1
  assert_exit_code "0"
}

function test_info_displays_ascii_banner() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "\___ \| '_ \ / _ \ | |   > <" "${output}"
}

function test_info_displays_session_information_section() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "Session Information" "${output}"
}

function test_info_displays_current_user() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "${USER}" "${output}"
}

function test_info_displays_loaded_in_time() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "Loaded in:" "${output}"
}

function test_info_displays_libraries_section() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "Libraries" "${output}"
}

function test_info_displays_plugins_section() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "Plugins" "${output}"
}

function test_info_displays_packages_subsection() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "Packages:" "${output}"
}

function test_info_displays_loaded_subsection() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "Loaded:" "${output}"
}

function test_info_displays_shellx_package() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "[@.shellx]" "${output}"
}

function test_info_lists_shellx_update_plugin_as_loaded() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "shellx_update.sh" "${output}"
}

function test_info_lists_wellcome_plugin_as_loaded() {
  local output
  output=$(shellx info 2>/dev/null)
  assert_contains "wellcome.sh" "${output}"
}

# --- shellx self-update ---

function test_self_update_exits_successfully() {
  shellx self-update > /dev/null 2>&1
  assert_exit_code "0"
}

# --- shellx check-update ---

function test_check_update_exits_successfully() {
  shellx check-update > /dev/null 2>&1
  assert_exit_code "0"
}

function test_check_update_displays_version_info() {
  local output
  output=$(shellx check-update 2>/dev/null)
  assert_not_empty "${output}"
}

# --- shellx help ---

function test_help_exits_successfully() {
  shellx help > /dev/null 2>&1
  assert_exit_code "0"
}

function test_help_displays_available_commands() {
  local output
  output=$(shellx help 2>/dev/null)
  assert_not_empty "${output}"
}

function test_help_specific_command_exits_successfully() {
  shellx help list > /dev/null 2>&1
  assert_exit_code "0"
}

function test_help_unknown_command_returns_error() {
  shellx help nonexistent_command_xyz > /dev/null 2>&1
  assert_unsuccessful_code
}

# --- shellx version check ---

function test_version_check_runs_without_crashing() {
  # shellx::update::available exits 0 if an update is available, 1 if already
  # up to date. Both outcomes are valid; just verify the command does not crash.
  shellx version check > /dev/null 2>&1
  local code=$?
  [[ "${code}" -eq 0 || "${code}" -eq 1 ]]
  assert_exit_code "0"
}

# --- shellx help (registry content) ---

function test_help_lists_version_command() {
  local output
  output=$(shellx help 2>/dev/null)
  assert_contains "version" "${output}"
}

function test_help_lists_info_command() {
  local output
  output=$(shellx help 2>/dev/null)
  assert_contains "info" "${output}"
}

function test_help_lists_plugins_command() {
  local output
  output=$(shellx help 2>/dev/null)
  assert_contains "plugins" "${output}"
}

# --- unknown command ---

function test_unknown_command_returns_error() {
  shellx nonexistent_command_xyz_abc > /dev/null 2>&1
  assert_unsuccessful_code
}
