#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stub: env.sh calls shellx::log_error on invalid keys
shellx::log_error() { :; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/string.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/env.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/debug.sh"

set_up()    { export SHELLX_DEBUG=no; }
tear_down() { export SHELLX_DEBUG=no; }

# -----------------------------------------------------------------------------
# shellx::debug::is_enabled
# -----------------------------------------------------------------------------

function test_debug_is_enabled_returns_false_when_debug_is_no() {
  SHELLX_DEBUG=no
  shellx::debug::is_enabled
  assert_unsuccessful_code
}

function test_debug_is_enabled_returns_false_when_debug_is_empty() {
  SHELLX_DEBUG=
  shellx::debug::is_enabled
  assert_unsuccessful_code
}

function test_debug_is_enabled_returns_false_when_debug_is_unset() {
  unset SHELLX_DEBUG
  shellx::debug::is_enabled
  assert_unsuccessful_code
}

function test_debug_is_enabled_returns_true_when_debug_is_yes_lowercase() {
  SHELLX_DEBUG=yes
  shellx::debug::is_enabled
  assert_exit_code "0"
}

function test_debug_is_enabled_returns_true_when_debug_is_yes_uppercase() {
  SHELLX_DEBUG=YES
  shellx::debug::is_enabled
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# shellx::debug::enable
# -----------------------------------------------------------------------------

function test_debug_enable_sets_shellx_debug_to_yes() {
  SHELLX_DEBUG=no
  shellx::debug::enable
  assert_same "yes" "${SHELLX_DEBUG}"
}

function test_debug_enable_makes_is_enabled_return_true() {
  SHELLX_DEBUG=no
  shellx::debug::enable
  shellx::debug::is_enabled
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# shellx::debug::disable
# -----------------------------------------------------------------------------

function test_debug_disable_clears_shellx_debug() {
  SHELLX_DEBUG=yes
  shellx::debug::disable
  assert_empty "${SHELLX_DEBUG}"
}

function test_debug_disable_after_enable_makes_is_enabled_return_false() {
  shellx::debug::enable
  shellx::debug::disable
  shellx::debug::is_enabled
  assert_unsuccessful_code
}

function test_debug_is_enabled_returns_false_for_arbitrary_string_value() {
  SHELLX_DEBUG=enabled
  shellx::debug::is_enabled
  assert_unsuccessful_code
}

function test_debug_enable_is_idempotent() {
  shellx::debug::enable
  shellx::debug::enable
  assert_same "yes" "${SHELLX_DEBUG}"
}

function test_debug_disable_is_idempotent() {
  SHELLX_DEBUG=yes
  shellx::debug::disable
  shellx::debug::disable
  assert_empty "${SHELLX_DEBUG}"
}

function test_debug_disable_from_unset_state_exits_successfully() {
  unset SHELLX_DEBUG
  shellx::debug::disable
  assert_exit_code "0"
}
