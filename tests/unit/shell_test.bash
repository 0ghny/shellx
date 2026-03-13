#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/shell.sh"

# -----------------------------------------------------------------------------
# shell::command_type
# -----------------------------------------------------------------------------

function test_shell_command_type_returns_builtin_for_echo() {
  assert_same "builtin" "$(shell::command_type "echo")"
}

function test_shell_command_type_returns_builtin_for_cd() {
  assert_same "builtin" "$(shell::command_type "cd")"
}

function test_shell_command_type_returns_function_for_defined_function() {
  _shellx_unit_test_fn() { :; }
  assert_same "function" "$(shell::command_type "_shellx_unit_test_fn")"
  unset -f _shellx_unit_test_fn
}

function test_shell_command_type_returns_empty_for_unknown_command() {
  assert_empty "$(shell::command_type "_shellx_nonexistent_cmd_xyz_abc")"
}

function test_shell_command_type_returns_file_for_external_program() {
  assert_same "file" "$(shell::command_type "git")"
}

# -----------------------------------------------------------------------------
# shell::exists
# -----------------------------------------------------------------------------

function test_shell_exists_returns_true_for_builtin() {
  shell::exists "echo"
  assert_exit_code "0"
}

function test_shell_exists_returns_true_for_defined_function() {
  _shellx_unit_test_fn2() { :; }
  shell::exists "_shellx_unit_test_fn2"
  assert_exit_code "0"
  unset -f _shellx_unit_test_fn2
}

function test_shell_exists_returns_true_for_external_program() {
  shell::exists "git"
  assert_exit_code "0"
}

function test_shell_exists_returns_false_for_unknown_command() {
  shell::exists "_shellx_nonexistent_cmd_xyz_abc"
  assert_unsuccessful_code
}

function test_shell_exists_returns_true_for_defined_alias() {
  shopt -s expand_aliases
  alias _shellx_unit_test_alias="echo test"
  shell::exists "_shellx_unit_test_alias"
  assert_exit_code "0"
  unalias _shellx_unit_test_alias
  shopt -u expand_aliases
}

# -----------------------------------------------------------------------------
# shell::alias_exists
# -----------------------------------------------------------------------------

function test_shell_alias_exists_returns_false_for_nonexistent_alias() {
  shell::alias_exists "_shellx_no_such_alias_xyz_abc"
  assert_unsuccessful_code
}

function test_shell_alias_exists_returns_false_for_empty_name() {
  shell::alias_exists ""
  assert_unsuccessful_code
}

function test_shell_alias_exists_returns_true_for_defined_alias() {
  # shellcheck disable=SC2139
  alias _shellx_unit_test_alias="echo shellx_test"
  shell::alias_exists "_shellx_unit_test_alias"
  assert_exit_code "0"
  unalias _shellx_unit_test_alias
}

function test_shell_alias_exists_returns_false_after_unalias() {
  # shellcheck disable=SC2139
  alias _shellx_unit_alias_del="echo del"
  unalias _shellx_unit_alias_del
  shell::alias_exists "_shellx_unit_alias_del"
  assert_unsuccessful_code
}
