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

# --- shellx plugins (error cases) ---

function test_plugins_no_args_returns_error() {
  shellx plugins > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_plugins_invalid_subcommand_returns_error() {
  shellx plugins invalid_sub > /dev/null 2>&1
  assert_unsuccessful_code
}

# --- shellx plugins list ---

function test_plugins_list_exits_successfully() {
  shellx plugins list > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_list_shows_available_packages_header() {
  local output
  output=$(shellx plugins list 2>/dev/null)
  assert_contains "Available Plugin Packages" "${output}"
}

# --- shellx plugins installed ---

function test_plugins_installed_exits_successfully() {
  shellx plugins installed > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_installed_shows_header() {
  local output
  output=$(shellx plugins installed 2>/dev/null)
  assert_contains "ShellX Installed Plugin Packages" "${output}"
}

function test_plugins_installed_shows_shellx_package() {
  local output
  output=$(shellx plugins installed 2>/dev/null)
  assert_contains ".shellx" "${output}"
}

function test_plugins_installed_shows_total_count() {
  local output
  output=$(shellx plugins installed 2>/dev/null)
  assert_contains "Total:" "${output}"
}

# --- shellx plugins install / uninstall (network) ---

function test_plugins_install_valid_url_succeeds() {
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_install_already_installed_fails_with_message() {
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  local output
  output=$(shellx plugins install https://github.com/0ghny/shellx-community-plugins 2>&1)
  assert_exit_code "1"
  assert_contains "[PLUGIN] shellx-community-plugins is already installed!" "${output}"
}

function test_plugins_install_invalid_url_fails() {
  shellx plugins install https://github.com/0ghny/shellx-community-plugins2 > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_plugins_uninstall_installed_package_succeeds() {
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  shellx plugins uninstall shellx-community-plugins > /dev/null 2>&1
  assert_exit_code "0"
}
