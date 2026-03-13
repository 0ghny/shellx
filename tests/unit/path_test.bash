#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

shellx::log_error() { :; }
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/env.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/path.sh"

_original_path=""

set_up() {
  _original_path="${PATH}"
}

tear_down() {
  PATH="${_original_path}"
  export PATH
}

# -----------------------------------------------------------------------------
# path::exists
# -----------------------------------------------------------------------------

function test_path_exists_returns_true_for_path_in_PATH() {
  PATH="/usr/bin:${PATH}"
  export PATH
  path::exists "/usr/bin"
  assert_exit_code "0"
}

function test_path_exists_returns_false_for_path_not_in_PATH() {
  path::exists "/shellx/this/does/not/exist/in/path"
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# path::add
# -----------------------------------------------------------------------------

function test_path_add_adds_directory_to_PATH() {
  path::add "/tmp/shellx-unit-test-path-add"
  path::exists "/tmp/shellx-unit-test-path-add"
  assert_exit_code "0"
}

function test_path_add_does_not_duplicate_existing_entry() {
  PATH="/tmp/shellx-unit-path-dedup:${PATH}"
  export PATH
  local before="${PATH}"
  path::add "/tmp/shellx-unit-path-dedup"
  assert_same "${before}" "${PATH}"
}

# -----------------------------------------------------------------------------
# path::backup
# -----------------------------------------------------------------------------

function test_path_backup_saves_current_PATH_to_given_variable() {
  path::backup "SHELLX_TEST_PATH_BAK"
  assert_same "${PATH}" "${SHELLX_TEST_PATH_BAK}"
  unset SHELLX_TEST_PATH_BAK
}

function test_path_backup_default_variable_is_PATH_BAK() {
  path::backup "PATH_BAK"
  assert_same "${PATH}" "${PATH_BAK}"
  unset PATH_BAK
}
