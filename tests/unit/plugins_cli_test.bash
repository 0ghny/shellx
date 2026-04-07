#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs for functions that live outside plugins.cli.sh
shellx::log_error() { :; }
shellx::plugins::config_file_path() { echo "${SHELLX_HOME}/plugins.repositories"; }
shellx::plugins::install()   { echo "install-called:$*"; }
shellx::plugins::uninstall() { echo "uninstall-called:$*"; }
shellx::plugins::update()    { echo "update-called:$*"; }
shellx::plugins::export()    { echo "export-called"; }
shellx::plugins::sync()      { echo "sync-called"; }
shellx::plugins::reload()    { echo "reload-called"; }

# Real dependencies needed by the display functions in plugins.cli.sh
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/colors.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/io.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/plugins/plugins.manager.sh"
# Keep list tests deterministic without requiring user-level config paths.
shellx::plugins::config_file_path() { echo "${SHELLX_HOME}/plugins.repositories"; }

# shellx::cli::plugins delegates install/uninstall/update to manager functions.
# Stub them to assert routing behavior only.
shellx::plugins::install()   { echo "install-called:$*"; }
shellx::plugins::uninstall() { echo "uninstall-called:$*"; }
shellx::plugins::update()    { echo "update-called:$*"; }
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/plugins.cli.sh"

set_up() {
  export __shellx_plugins_d="/tmp/shellx-unit-cli-plugins-d-$$"
  mkdir -p "${__shellx_plugins_d}"
  __shellx_plugins_loaded=()
  __shellx_plugins_locations=()
}

tear_down() {
  rm -rf "${__shellx_plugins_d}"
  unset __shellx_plugins_d
}

# =============================================================================
# Display functions (shellx::plugins::loaded, installed, list)
# — now defined in plugins.cli.sh
# =============================================================================

# --- shellx::plugins::loaded ---

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

# --- shellx::plugins::installed ---

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
  __shellx_plugins_locations=()
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

# --- shellx::plugins::list ---

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

# =============================================================================
# shellx::cli::plugins — subcommand routing
# =============================================================================

# --- list (calls real shellx::plugins::list defined above) ---

function test_plugins_cli_list_delegates_to_plugins_list() {
  local output
  output=$(shellx::cli::plugins list 2>/dev/null)
  assert_contains "Available Plugin Packages" "${output}"
}

function test_plugins_cli_list_exits_successfully() {
  shellx::cli::plugins list > /dev/null 2>&1
  assert_exit_code "0"
}

# --- installed (calls real shellx::plugins::installed defined above) ---

function test_plugins_cli_installed_delegates_to_plugins_installed() {
  local output
  output=$(shellx::cli::plugins installed 2>/dev/null)
  assert_contains "ShellX Installed Plugin Packages" "${output}"
}

function test_plugins_cli_installed_exits_successfully() {
  shellx::cli::plugins installed > /dev/null 2>&1
  assert_exit_code "0"
}

function test_plugins_cli_install_delegates_to_plugins_install() {
  local output
  output=$(shellx::cli::plugins install myplugin)
  assert_contains "install-called:myplugin" "${output}"
}

function test_plugins_cli_install_exits_successfully() {
  shellx::cli::plugins install myplugin > /dev/null
  assert_exit_code "0"
}

function test_plugins_cli_uninstall_delegates_to_plugins_uninstall() {
  local output
  output=$(shellx::cli::plugins uninstall myplugin)
  assert_contains "uninstall-called:myplugin" "${output}"
}

function test_plugins_cli_uninstall_exits_successfully() {
  shellx::cli::plugins uninstall myplugin > /dev/null
  assert_exit_code "0"
}

function test_plugins_cli_update_delegates_to_plugins_update() {
  local output
  output=$(shellx::cli::plugins update myplugin)
  assert_contains "update-called:myplugin" "${output}"
}

function test_plugins_cli_update_exits_successfully() {
  shellx::cli::plugins update myplugin > /dev/null
  assert_exit_code "0"
}

function test_plugins_cli_reload_delegates_to_plugins_reload() {
  local output
  output=$(shellx::cli::plugins reload)
  assert_contains "reload-called" "${output}"
}

function test_plugins_cli_reload_exits_successfully() {
  shellx::cli::plugins reload > /dev/null
  assert_exit_code "0"
}

# --- sync ---

function test_plugins_cli_sync_delegates_to_plugins_sync() {
  local output
  output=$(shellx::cli::plugins sync)
  assert_contains "sync-called" "${output}"
}

function test_plugins_cli_sync_exits_successfully() {
  shellx::cli::plugins sync > /dev/null
  assert_exit_code "0"
}

# --- export ---

function test_plugins_cli_export_delegates_to_plugins_export() {
  local output
  output=$(shellx::cli::plugins export)
  assert_contains "export-called" "${output}"
}

function test_plugins_cli_export_exits_successfully() {
  shellx::cli::plugins export > /dev/null
  assert_exit_code "0"
}

# --- install with ref ---

function test_plugins_cli_install_passes_ref_argument() {
  local output
  output=$(shellx::cli::plugins install myplugin main)
  assert_contains "install-called:myplugin main" "${output}"
}

# --- error cases ---

function test_plugins_cli_unknown_subcommand_returns_error() {
  shellx::cli::plugins totally_unknown 2>/dev/null
  assert_exit_code "1"
}

function test_plugins_cli_no_subcommand_returns_error() {
  shellx::cli::plugins 2>/dev/null
  assert_exit_code "1"
}

function test_plugins_cli_unknown_subcommand_prints_usage() {
  local output
  output=$(shellx::cli::plugins totally_unknown 2>&1)
  assert_contains "Usage:" "${output}"
}

function test_plugins_cli_help_includes_sync_subcommand() {
  local output
  output=$(shellx::cli::plugins totally_unknown 2>&1)
  assert_contains "sync" "${output}"
}

function test_plugins_cli_help_includes_export_subcommand() {
  local output
  output=$(shellx::cli::plugins totally_unknown 2>&1)
  assert_contains "export" "${output}"
}
