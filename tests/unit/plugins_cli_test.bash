#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs for pure plugin functions (tested separately in plugins_*_test.bash)
shellx::log_error() { :; }

shellx::plugins::list()      { echo "list-called"; }
shellx::plugins::installed() { echo "installed-called"; }
shellx::plugins::install()   { echo "install-called:$*"; }
shellx::plugins::uninstall() { echo "uninstall-called:$*"; }
shellx::plugins::update()    { echo "update-called:$*"; }
shellx::plugins::reload()    { echo "reload-called"; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/plugins.cli.sh"

set_up()    { :; }
tear_down() { :; }

# -----------------------------------------------------------------------------
# shellx::cli::plugins - subcommand routing
# -----------------------------------------------------------------------------

function test_plugins_cli_list_delegates_to_plugins_list() {
  local output
  output=$(shellx::cli::plugins list)
  assert_contains "list-called" "${output}"
}

function test_plugins_cli_list_exits_successfully() {
  shellx::cli::plugins list > /dev/null
  assert_exit_code "0"
}

function test_plugins_cli_installed_delegates_to_plugins_installed() {
  local output
  output=$(shellx::cli::plugins installed)
  assert_contains "installed-called" "${output}"
}

function test_plugins_cli_installed_exits_successfully() {
  shellx::cli::plugins installed > /dev/null
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
