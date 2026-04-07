#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
SHELLX_PLUGINS_D=/tmp/shellx-bashunit-tests
SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config_all_plugins"
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

function test_plugins_installed_shows_git_ref_for_installed_package() {
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  local output
  output=$(shellx plugins installed 2>/dev/null)
  assert_matches "shellx-community-plugins.*\(" "${output}"
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

# --- shellx plugins install: manifest side-effects ---

function test_plugins_install_creates_manifest_file() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-test"
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  assert_file_exists "${SHELLX_PLUGINS_MANIFEST}"
  unset SHELLX_PLUGINS_MANIFEST
}

function test_plugins_install_writes_url_to_manifest() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-test"
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "https://github.com/0ghny/shellx-community-plugins"
  unset SHELLX_PLUGINS_MANIFEST
}

# --- shellx plugins uninstall: manifest side-effects ---

function test_plugins_uninstall_removes_entry_from_manifest() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-test"
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  shellx plugins uninstall shellx-community-plugins > /dev/null 2>&1
  local remaining
  remaining=$(grep -v "^#" "${SHELLX_PLUGINS_MANIFEST}" | grep "shellx-community-plugins" || true)
  assert_empty "${remaining}"
  unset SHELLX_PLUGINS_MANIFEST
}

# --- shellx plugins export ---

function test_plugins_export_exits_successfully() {
  shellx plugins export > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_export_outputs_manifest_header() {
  local output
  output=$(shellx plugins export 2>/dev/null)
  assert_contains "ShellX Plugins Manifest" "${output}"
}

function test_plugins_export_includes_installed_plugin_url() {
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  local output
  output=$(shellx plugins export 2>/dev/null)
  assert_contains "https://github.com/0ghny/shellx-community-plugins" "${output}"
}

function test_plugins_export_output_is_valid_manifest_input() {
  # Install a plugin, export to a tmp file, then sync from it on a clean dir
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  local manifest="${SHELLX_PLUGINS_D}/.exported-manifest"
  shellx plugins export > "${manifest}" 2>/dev/null
  assert_file_contains "${manifest}" "https://github.com/0ghny/shellx-community-plugins"
}

# --- shellx plugins sync ---

function test_plugins_sync_exits_error_when_manifest_missing() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-nonexistent"
  shellx plugins sync > /dev/null 2>&1
  assert_exit_code "1"
  unset SHELLX_PLUGINS_MANIFEST
}

function test_plugins_sync_prints_manifest_not_found_message() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-nonexistent"
  local output
  output=$(shellx plugins sync 2>&1)
  assert_contains "Manifest not found" "${output}"
  unset SHELLX_PLUGINS_MANIFEST
}

function test_plugins_sync_installs_plugin_from_manifest() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-sync-test"
  printf "https://github.com/0ghny/shellx-community-plugins\n" > "${SHELLX_PLUGINS_MANIFEST}"
  shellx plugins sync > /dev/null 2>&1
  assert_exit_code "0"
  assert_directory_exists "${SHELLX_PLUGINS_D}/shellx-community-plugins"
  unset SHELLX_PLUGINS_MANIFEST
}

function test_plugins_sync_skips_already_installed_plugin() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-sync-skip"
  shellx plugins install https://github.com/0ghny/shellx-community-plugins > /dev/null 2>&1
  printf "https://github.com/0ghny/shellx-community-plugins\n" > "${SHELLX_PLUGINS_MANIFEST}"
  local output
  output=$(shellx plugins sync 2>/dev/null)
  assert_contains "already installed" "${output}"
  unset SHELLX_PLUGINS_MANIFEST
}

function test_plugins_sync_shows_summary_line() {
  export SHELLX_PLUGINS_MANIFEST="${SHELLX_PLUGINS_D}/.manifest-sync-summary"
  printf "https://github.com/0ghny/shellx-community-plugins\n" > "${SHELLX_PLUGINS_MANIFEST}"
  local output
  output=$(shellx plugins sync 2>/dev/null)
  assert_contains "Sync complete" "${output}"
  unset SHELLX_PLUGINS_MANIFEST
}
