#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs for pure debug functions (tested separately in debug_test.bash)
shellx::log_error() { :; }

shellx::debug::enable()     { export SHELLX_DEBUG=yes; }
shellx::debug::disable()    { unset SHELLX_DEBUG; }
shellx::debug::is_enabled() { [ "${SHELLX_DEBUG:-}" = "yes" ]; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/debug.cli.sh"

set_up()    { export SHELLX_DEBUG=no; }
tear_down() { export SHELLX_DEBUG=no; }

# -----------------------------------------------------------------------------
# shellx::cli::debug - subcommand routing
# -----------------------------------------------------------------------------

function test_debug_cli_enabled_calls_debug_enable() {
  SHELLX_DEBUG=no
  shellx::cli::debug enabled
  assert_same "yes" "${SHELLX_DEBUG}"
}

function test_debug_cli_disabled_calls_debug_disable() {
  SHELLX_DEBUG=yes
  shellx::cli::debug disabled
  assert_empty "${SHELLX_DEBUG}"
}

function test_debug_cli_enabled_exits_successfully() {
  shellx::cli::debug enabled
  assert_exit_code "0"
}

function test_debug_cli_disabled_exits_successfully() {
  shellx::cli::debug disabled
  assert_exit_code "0"
}

function test_debug_cli_unknown_arg_returns_error() {
  shellx::cli::debug totally_unknown 2>/dev/null
  assert_exit_code "1"
}

function test_debug_cli_no_arg_returns_error() {
  shellx::cli::debug 2>/dev/null
  assert_exit_code "1"
}

function test_debug_cli_unknown_arg_prints_usage() {
  local output
  output=$(shellx::cli::debug totally_unknown 2>&1)
  assert_contains "Usage:" "${output}"
}

function test_debug_cli_status_shows_enabled_when_debug_active() {
  SHELLX_DEBUG=yes
  local output
  output=$(shellx::cli::debug totally_unknown 2>&1)
  assert_contains "enabled" "${output}"
}

function test_debug_cli_status_shows_disabled_when_debug_inactive() {
  SHELLX_DEBUG=no
  local output
  output=$(shellx::cli::debug totally_unknown 2>&1)
  assert_contains "disabled" "${output}"
}
