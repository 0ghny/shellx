#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs for pure config functions (tested separately in config_test.bash)
shellx::log_warn()  { :; }
shellx::log_info()  { :; }
shellx::log_debug() { :; }
shellx::log_error() { :; }

shellx::config::reload()  { return 0; }
shellx::config::print()   { echo "SHELLX_NO_BANNER=1"; }
shellx::config::runtime() { echo "SHELLX_DEBUG=no"; }
shellx::config::set()     { return 0; }
shellx::config::unset()   { return 0; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/config.cli.sh"

set_up()    { :; }
tear_down() { :; }

# -----------------------------------------------------------------------------
# shellx::cli::config - subcommand routing
# -----------------------------------------------------------------------------

function test_config_cli_reload_delegates_to_config_reload() {
  shellx::config::reload() { echo "reload-called"; }
  local output
  output=$(shellx::cli::config reload)
  assert_contains "reload-called" "${output}"
}

function test_config_cli_print_delegates_to_config_print() {
  shellx::config::print() { echo "print-called"; }
  local output
  output=$(shellx::cli::config print)
  assert_contains "print-called" "${output}"
}

function test_config_cli_runtime_delegates_to_config_runtime() {
  shellx::config::runtime() { echo "runtime-called"; }
  local output
  output=$(shellx::cli::config runtime)
  assert_contains "runtime-called" "${output}"
}

function test_config_cli_set_delegates_to_config_set() {
  shellx::config::set() { echo "set-called:$1=$2"; }
  local output
  output=$(shellx::cli::config set SHELLX_DEBUG yes)
  assert_contains "set-called:SHELLX_DEBUG=yes" "${output}"
}

function test_config_cli_unset_delegates_to_config_unset() {
  shellx::config::unset() { echo "unset-called:$1"; }
  local output
  output=$(shellx::cli::config unset SHELLX_DEBUG)
  assert_contains "unset-called:SHELLX_DEBUG" "${output}"
}

function test_config_cli_unknown_subcommand_returns_error() {
  shellx::cli::config totally_unknown 2>/dev/null
  assert_exit_code "1"
}

function test_config_cli_no_subcommand_returns_error() {
  shellx::cli::config 2>/dev/null
  assert_exit_code "1"
}

function test_config_cli_unknown_subcommand_prints_usage() {
  local output
  output=$(shellx::cli::config totally_unknown 2>&1)
  assert_contains "Usage:" "${output}"
}

function test_config_cli_unknown_subcommand_lists_configurable_keys() {
  local output
  output=$(shellx::cli::config totally_unknown 2>&1)
  assert_contains "SHELLX_NO_BANNER" "${output}"
}
