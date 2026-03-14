#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs for functions called by shellx::cli::reload
shellx::plugins::reload() { echo "plugins-reload-called"; }
shellx::config::reload()  { echo "config-reload-called"; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/system.cli.sh"

set_up()    { :; }
tear_down() { :; }

# -----------------------------------------------------------------------------
# shellx::cli::reset
# -----------------------------------------------------------------------------

function test_system_cli_reset_function_is_defined() {
  declare -f shellx::cli::reset > /dev/null 2>&1
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# shellx::cli::reload
# -----------------------------------------------------------------------------

function test_system_cli_reload_calls_plugins_reload() {
  local output
  output=$(shellx::cli::reload)
  assert_contains "plugins-reload-called" "${output}"
}

function test_system_cli_reload_calls_config_reload() {
  local output
  output=$(shellx::cli::reload)
  assert_contains "config-reload-called" "${output}"
}

function test_system_cli_reload_exits_successfully_when_both_succeed() {
  shellx::cli::reload > /dev/null
  assert_exit_code "0"
}

function test_system_cli_reload_fails_when_plugins_reload_fails() {
  shellx::plugins::reload() { return 1; }
  shellx::cli::reload > /dev/null 2>&1
  assert_exit_code "1"
}

function test_system_cli_reload_does_not_call_config_reload_when_plugins_reload_fails() {
  local config_called=0
  shellx::plugins::reload() { return 1; }
  shellx::config::reload()  { config_called=1; return 0; }
  shellx::cli::reload > /dev/null 2>&1
  assert_same "0" "${config_called}"
}
