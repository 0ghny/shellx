#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stub: env.sh calls shellx::log_error on invalid keys
shellx::log_error() { :; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/env.sh"

# -----------------------------------------------------------------------------
# env::export
# -----------------------------------------------------------------------------

function test_env_export_sets_variable_value() {
  env::export "SHELLX_TEST_EXPORT_VAR" "hello"
  assert_same "hello" "${SHELLX_TEST_EXPORT_VAR}"
  unset SHELLX_TEST_EXPORT_VAR
}

function test_env_export_updates_existing_variable() {
  export SHELLX_TEST_UPDATE_VAR="original"
  env::export "SHELLX_TEST_UPDATE_VAR" "updated"
  assert_same "updated" "${SHELLX_TEST_UPDATE_VAR}"
  unset SHELLX_TEST_UPDATE_VAR
}

function test_env_export_clears_variable_with_empty_value() {
  export SHELLX_TEST_CLEAR_VAR="original"
  env::export "SHELLX_TEST_CLEAR_VAR" ""
  assert_empty "${SHELLX_TEST_CLEAR_VAR}"
  unset SHELLX_TEST_CLEAR_VAR
}

function test_env_export_rejects_key_with_spaces() {
  env::export "INVALID KEY" "value" 2>/dev/null
  assert_unsuccessful_code
}

function test_env_export_rejects_key_with_special_chars() {
  env::export "INVALID-KEY" "value" 2>/dev/null
  assert_unsuccessful_code
}

function test_env_export_accepts_key_with_underscores() {
  env::export "VALID_KEY_123" "ok"
  assert_same "ok" "${VALID_KEY_123}"
  unset VALID_KEY_123
}

# -----------------------------------------------------------------------------
# env::is_defined
# -----------------------------------------------------------------------------

function test_env_is_defined_returns_true_for_set_variable() {
  export SHELLX_TEST_DEFINED="yes"
  env::is_defined "SHELLX_TEST_DEFINED"
  assert_exit_code "0"
  unset SHELLX_TEST_DEFINED
}

function test_env_is_defined_returns_false_for_unset_variable() {
  unset SHELLX_TEST_NOT_DEFINED_XYZ
  env::is_defined "SHELLX_TEST_NOT_DEFINED_XYZ"
  assert_unsuccessful_code
}

function test_env_is_defined_returns_false_for_empty_variable() {
  export SHELLX_TEST_EMPTY_VAR=""
  env::is_defined "SHELLX_TEST_EMPTY_VAR"
  assert_unsuccessful_code
  unset SHELLX_TEST_EMPTY_VAR
}

function test_env_is_defined_rejects_name_with_spaces() {
  env::is_defined "INVALID NAME" 2>/dev/null
  assert_unsuccessful_code
}

function test_env_is_defined_rejects_name_with_special_chars() {
  env::is_defined "INVALID-NAME" 2>/dev/null
  assert_unsuccessful_code
}
