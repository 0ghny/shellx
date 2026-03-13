#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs for pure version/update functions (tested separately in version_test.bash)
shellx::version()           { echo "vTEST"; }
shellx::version::info()     { echo "version-info-output"; }
shellx::version::notes()    { echo "notes-output"; }
shellx::update::available() { return 0; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/version.cli.sh"

set_up()    { :; }
tear_down() { :; }

# -----------------------------------------------------------------------------
# shellx::cli::version - subcommand routing
# -----------------------------------------------------------------------------

function test_version_cli_no_subcommand_prints_version_string() {
  local output
  output=$(shellx::cli::version)
  assert_contains "vTEST" "${output}"
}

function test_version_cli_no_subcommand_exits_successfully() {
  shellx::cli::version > /dev/null
  assert_exit_code "0"
}

function test_version_cli_info_delegates_to_version_info() {
  shellx::version::info() { echo "info-called"; }
  local output
  output=$(shellx::cli::version info)
  assert_contains "info-called" "${output}"
}

function test_version_cli_info_exits_successfully() {
  shellx::cli::version info > /dev/null
  assert_exit_code "0"
}

function test_version_cli_notes_delegates_to_version_notes() {
  shellx::version::notes() { echo "notes-called"; }
  local output
  output=$(shellx::cli::version notes)
  assert_contains "notes-called" "${output}"
}

function test_version_cli_notes_exits_successfully() {
  shellx::cli::version notes > /dev/null
  assert_exit_code "0"
}

function test_version_cli_check_delegates_to_update_available() {
  shellx::update::available() { return 0; }
  shellx::cli::version check
  assert_exit_code "0"
}

function test_version_cli_unknown_subcommand_returns_error() {
  shellx::cli::version totally_unknown 2>/dev/null
  assert_exit_code "1"
}

function test_version_cli_unknown_subcommand_prints_usage() {
  local output
  output=$(shellx::cli::version totally_unknown 2>&1)
  assert_contains "Usage:" "${output}"
}
