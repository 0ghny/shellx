#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/feature.sh"

# -----------------------------------------------------------------------------
# shellx::feature_enabled
# -----------------------------------------------------------------------------

function test_feature_enabled_returns_true_for_named_feature() {
  shellx::feature_enabled "plugins"
  assert_exit_code "0"
}

function test_feature_enabled_returns_true_with_no_argument() {
  shellx::feature_enabled
  assert_exit_code "0"
}

function test_feature_enabled_returns_true_for_unknown_feature_name() {
  shellx::feature_enabled "nonexistent-feature-xyz"
  assert_exit_code "0"
}

function test_feature_enabled_returns_true_for_empty_string() {
  shellx::feature_enabled ""
  assert_exit_code "0"
}
