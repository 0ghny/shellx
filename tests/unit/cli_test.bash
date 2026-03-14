#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

export __shellx_libdir="${SHELLX_HOME}/lib"
export __shellx_homedir="${SHELLX_HOME}"

# Stubs: log functions (lib/shellx/log.sh is not loaded in unit tests)
shellx::log_debug() { :; }
shellx::log_warn()  { :; }
shellx::log_error() { :; }
shellx::log_info()  { :; }

# Stubs: functions mapped in the registry that are not defined in cli.sh itself
# CLI adapter stubs (defined in lib/shellx/cli/*.cli.sh, not sourced here)
shellx::cli::version()  { echo "vTEST"; }
shellx::cli::config()   { return 0; }
shellx::cli::debug()    { return 0; }
shellx::cli::reset()    { return 0; }
shellx::cli::reload()   { return 0; }
shellx::cli::plugins()  { return 0; }
# Pure function stubs
shellx::session::status()  { echo "status-output"; }
shellx::info()              { echo "info-output"; }
shellx::plugins::loaded()  { echo "loaded-output"; }
shellx::update()            { return 0; }
shellx::update::info()      { return 0; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/cli/cli.sh"

# -----------------------------------------------------------------------------
# shellx::cli::command_exists
# -----------------------------------------------------------------------------

function test_cli_command_exists_returns_true_for_version() {
  shellx::cli::command_exists "version"
  assert_exit_code "0"
}

function test_cli_command_exists_returns_true_for_plugins() {
  shellx::cli::command_exists "plugins"
  assert_exit_code "0"
}

function test_cli_command_exists_returns_true_for_help() {
  shellx::cli::command_exists "help"
  assert_exit_code "0"
}

function test_cli_command_exists_returns_false_for_unknown_command() {
  shellx::cli::command_exists "totally_nonexistent_xyz"
  assert_unsuccessful_code
}

function test_cli_command_exists_returns_false_for_empty_string() {
  shellx::cli::command_exists ""
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# shellx::cli::get_function
# -----------------------------------------------------------------------------

function test_cli_get_function_returns_mapped_function_for_version() {
  local fn
  fn=$(shellx::cli::get_function "version")
  assert_same "shellx::cli::version" "${fn}"
}

function test_cli_get_function_returns_mapped_function_for_plugins() {
  local fn
  fn=$(shellx::cli::get_function "plugins")
  assert_same "shellx::cli::plugins" "${fn}"
}

function test_cli_get_function_returns_empty_for_unknown_command() {
  local fn
  fn=$(shellx::cli::get_function "totally_nonexistent_xyz")
  assert_empty "${fn}"
}

# -----------------------------------------------------------------------------
# shellx::cli::get_description
# -----------------------------------------------------------------------------

function test_cli_get_description_returns_non_empty_for_version() {
  local desc
  desc=$(shellx::cli::get_description "version")
  assert_not_empty "${desc}"
}

function test_cli_get_description_returns_non_empty_for_debug() {
  local desc
  desc=$(shellx::cli::get_description "debug")
  assert_not_empty "${desc}"
}

function test_cli_get_description_returns_empty_for_unknown_command() {
  local desc
  desc=$(shellx::cli::get_description "totally_nonexistent_xyz")
  assert_empty "${desc}"
}

# -----------------------------------------------------------------------------
# shellx::cli::get_category
# -----------------------------------------------------------------------------

function test_cli_get_category_returns_correct_category_for_version() {
  local cat
  cat=$(shellx::cli::get_category "version")
  assert_same "System Commands" "${cat}"
}

function test_cli_get_category_returns_correct_category_for_plugins() {
  local cat
  cat=$(shellx::cli::get_category "plugins")
  assert_same "Plugin Management" "${cat}"
}

function test_cli_get_category_returns_correct_category_for_list() {
  local cat
  cat=$(shellx::cli::get_category "list")
  assert_same "Session Commands" "${cat}"
}

function test_cli_get_category_returns_correct_category_for_status() {
  local cat
  cat=$(shellx::cli::get_category "status")
  assert_same "Session Commands" "${cat}"
}

function test_cli_get_category_returns_correct_category_for_debug() {
  local cat
  cat=$(shellx::cli::get_category "debug")
  assert_same "Debug Commands" "${cat}"
}

function test_cli_get_category_returns_empty_for_unknown_command() {
  local cat
  cat=$(shellx::cli::get_category "totally_nonexistent_xyz")
  assert_empty "${cat}"
}

# -----------------------------------------------------------------------------
# shellx::cli::help
# -----------------------------------------------------------------------------

function test_cli_help_no_args_exits_successfully() {
  shellx::cli::help > /dev/null 2>&1
  assert_exit_code "0"
}

function test_cli_help_no_args_output_is_not_empty() {
  local output
  output=$(shellx::cli::help 2>/dev/null)
  assert_not_empty "${output}"
}

function test_cli_help_no_args_contains_shellx() {
  local output
  output=$(shellx::cli::help 2>/dev/null)
  assert_contains "ShellX" "${output}"
}

function test_cli_help_no_args_contains_usage_line() {
  local output
  output=$(shellx::cli::help 2>/dev/null)
  assert_contains "Usage:" "${output}"
}

function test_cli_help_no_args_contains_run_help_line() {
  local output
  output=$(shellx::cli::help 2>/dev/null)
  assert_contains "shellx help COMMAND" "${output}"
}

function test_cli_help_specific_command_exits_successfully() {
  shellx::cli::help "version" > /dev/null 2>&1
  assert_exit_code "0"
}

function test_cli_help_specific_command_shows_command_name() {
  local output
  output=$(shellx::cli::help "version" 2>/dev/null)
  assert_contains "version" "${output}"
}

function test_cli_help_specific_command_shows_description() {
  local output
  output=$(shellx::cli::help "version" 2>/dev/null)
  assert_contains "Description:" "${output}"
}

function test_cli_help_specific_command_shows_category() {
  local output
  output=$(shellx::cli::help "version" 2>/dev/null)
  assert_contains "Category:" "${output}"
}

function test_cli_help_unknown_command_returns_error() {
  shellx::cli::help "totally_nonexistent_xyz" > /dev/null 2>&1
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# shellx::cli::execute
# -----------------------------------------------------------------------------

function test_cli_execute_calls_mapped_function() {
  local output
  output=$(shellx::cli::execute "version" 2>/dev/null)
  assert_contains "vTEST" "${output}"
}

function test_cli_execute_unknown_command_returns_error() {
  shellx::cli::execute "totally_nonexistent_xyz" > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_cli_execute_unknown_command_shows_error_message() {
  local output
  output=$(shellx::cli::execute "totally_nonexistent_xyz" 2>&1)
  assert_contains "Unknown command" "${output}"
}

# -----------------------------------------------------------------------------
# shellx::cli::run
# -----------------------------------------------------------------------------

function test_cli_run_no_args_exits_successfully() {
  shellx::cli::run > /dev/null 2>&1
  assert_exit_code "0"
}

function test_cli_run_no_args_shows_help() {
  local output
  output=$(shellx::cli::run 2>/dev/null)
  assert_contains "ShellX" "${output}"
}

function test_cli_run_help_exits_successfully() {
  shellx::cli::run help > /dev/null 2>&1
  assert_exit_code "0"
}

function test_cli_run_help_with_unknown_command_returns_error() {
  shellx::cli::run help totally_nonexistent_xyz > /dev/null 2>&1
  assert_unsuccessful_code
}

function test_cli_run_version_exits_successfully() {
  shellx::cli::run version > /dev/null 2>&1
  assert_exit_code "0"
}

function test_cli_run_unknown_command_returns_error() {
  shellx::cli::run totally_nonexistent_xyz > /dev/null 2>&1
  assert_unsuccessful_code
}
