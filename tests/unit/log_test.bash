#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stub: env.sh calls shellx::log_error on invalid keys;
# log.sh will redefine it with the real implementation after being sourced.
shellx::log_error() { :; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/colors.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/string.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/env.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/debug.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/log.sh"

set_up() {
  unset SHELLX_NO_COLOR
  export SHELLX_DEBUG=no
}

tear_down() {
  unset SHELLX_NO_COLOR
  export SHELLX_DEBUG=no
}

# -----------------------------------------------------------------------------
# shellx::log_internal::get_slug
# -----------------------------------------------------------------------------

function test_log_slug_debug_returns_non_empty() {
  assert_not_empty "$(shellx::log_internal::get_slug debug)"
}

function test_log_slug_info_returns_non_empty() {
  assert_not_empty "$(shellx::log_internal::get_slug info)"
}

function test_log_slug_warn_returns_non_empty() {
  assert_not_empty "$(shellx::log_internal::get_slug warn)"
}

function test_log_slug_error_returns_non_empty() {
  assert_not_empty "$(shellx::log_internal::get_slug error)"
}

function test_log_slug_debug_contains_level_name_when_no_color() {
  SHELLX_NO_COLOR=1
  local slug
  slug=$(shellx::log_internal::get_slug debug)
  assert_contains "debug" "${slug}"
}

function test_log_slug_error_contains_level_name_when_no_color() {
  SHELLX_NO_COLOR=1
  local slug
  slug=$(shellx::log_internal::get_slug error)
  assert_contains "error" "${slug}"
}

function test_log_slug_warn_contains_level_name_when_no_color() {
  SHELLX_NO_COLOR=1
  local slug
  slug=$(shellx::log_internal::get_slug warn)
  assert_contains "warn" "${slug}"
}

function test_log_slug_info_contains_level_name_when_no_color() {
  SHELLX_NO_COLOR=1
  local slug
  slug=$(shellx::log_internal::get_slug info)
  assert_contains "info" "${slug}"
}

# -----------------------------------------------------------------------------
# shellx::log_internal::caller_info
# -----------------------------------------------------------------------------

function test_log_caller_info_returns_non_empty() {
  assert_not_empty "$(shellx::log_internal::caller_info)"
}

# -----------------------------------------------------------------------------
# Log functions: silent when debug disabled, active when debug enabled
# -----------------------------------------------------------------------------

function test_log_debug_emits_nothing_when_debug_disabled() {
  export SHELLX_DEBUG=no
  local output
  output=$(shellx::log_debug "test message" 2>&1)
  assert_empty "${output}"
}

function test_log_info_emits_nothing_when_debug_disabled() {
  export SHELLX_DEBUG=no
  local output
  output=$(shellx::log_info "test message" 2>&1)
  assert_empty "${output}"
}

function test_log_warn_emits_nothing_when_debug_disabled() {
  export SHELLX_DEBUG=no
  local output
  output=$(shellx::log_warn "test message" 2>&1)
  assert_empty "${output}"
}

function test_log_error_emits_nothing_when_debug_disabled() {
  export SHELLX_DEBUG=no
  local output
  output=$(shellx::log_error "test message" 2>&1)
  assert_empty "${output}"
}

function test_log_debug_emits_to_stderr_when_debug_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_debug "test message" 2>&1)
  assert_not_empty "${output}"
}

function test_log_debug_output_contains_message_when_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_debug "distinct_marker_xyz" 2>&1)
  assert_contains "distinct_marker_xyz" "${output}"
}

function test_log_error_output_contains_message_when_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_error "error_marker_abc" 2>&1)
  assert_contains "error_marker_abc" "${output}"
}

function test_log_info_emits_to_stderr_when_debug_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_info "info_marker_xyz" 2>&1)
  assert_not_empty "${output}"
}

function test_log_info_output_contains_message_when_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_info "info_distinct_marker" 2>&1)
  assert_contains "info_distinct_marker" "${output}"
}

function test_log_warn_emits_to_stderr_when_debug_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_warn "warn_marker_xyz" 2>&1)
  assert_not_empty "${output}"
}

function test_log_warn_output_contains_message_when_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_warn "warn_distinct_marker" 2>&1)
  assert_contains "warn_distinct_marker" "${output}"
}

function test_log_error_emits_to_stderr_when_debug_enabled() {
  export SHELLX_DEBUG=yes
  local output
  output=$(shellx::log_error "error_marker_xyz" 2>&1)
  assert_not_empty "${output}"
}
