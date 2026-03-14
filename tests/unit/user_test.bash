#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/user.sh"

# -----------------------------------------------------------------------------
# user::current
# -----------------------------------------------------------------------------

function test_user_current_returns_non_empty_value() {
  assert_not_empty "$(user::current)"
}

function test_user_current_matches_whoami() {
  assert_same "$(whoami)" "$(user::current)"
}

function test_user_current_returns_same_value_as_USER_env_var() {
  assert_same "${USER}" "$(user::current)"
}
