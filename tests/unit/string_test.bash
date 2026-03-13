#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/string.sh"

# -----------------------------------------------------------------------------
# string::length
# -----------------------------------------------------------------------------

function test_string_length_returns_correct_length() {
  assert_same "5" "$(string::length "hello")"
}

function test_string_length_returns_zero_for_empty() {
  assert_same "0" "$(string::length "")"
}

function test_string_length_counts_spaces() {
  assert_same "3" "$(string::length "a b")"
}

# -----------------------------------------------------------------------------
# string::is_null_or_empty
# -----------------------------------------------------------------------------

function test_string_is_null_or_empty_returns_true_for_empty_string() {
  string::is_null_or_empty ""
  assert_exit_code "0"
}

function test_string_is_null_or_empty_returns_false_for_non_empty() {
  string::is_null_or_empty "hello"
  assert_unsuccessful_code
}

function test_string_is_null_or_empty_returns_false_for_whitespace() {
  string::is_null_or_empty "   "
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# string::is_null_or_whitespace
# -----------------------------------------------------------------------------

function test_string_is_null_or_whitespace_returns_true_for_empty() {
  string::is_null_or_whitespace ""
  assert_exit_code "0"
}

function test_string_is_null_or_whitespace_returns_true_for_spaces() {
  string::is_null_or_whitespace "   "
  assert_exit_code "0"
}

function test_string_is_null_or_whitespace_returns_false_for_text() {
  string::is_null_or_whitespace "hello"
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# string::trim
# -----------------------------------------------------------------------------

function test_string_trim_removes_leading_and_trailing_spaces() {
  assert_same "hello" "$(string::trim "  hello  ")"
}

function test_string_trim_collapses_multiple_internal_spaces() {
  # string::trim trims leading/trailing and collapses words but preserves single space between them
  assert_same "hello world" "$(string::trim "hello   world")"
}

function test_string_trim_no_change_on_clean_string() {
  assert_same "hello" "$(string::trim "hello")"
}

# -----------------------------------------------------------------------------
# string::to_lower
# -----------------------------------------------------------------------------

function test_string_to_lower_converts_uppercase() {
  assert_same "hello" "$(string::to_lower "HELLO")"
}

function test_string_to_lower_no_change_on_lowercase() {
  assert_same "hello" "$(string::to_lower "hello")"
}

function test_string_to_lower_converts_mixed_case() {
  assert_same "hello world" "$(string::to_lower "Hello World")"
}

# -----------------------------------------------------------------------------
# string::to_upper
# -----------------------------------------------------------------------------

function test_string_to_upper_converts_lowercase() {
  assert_same "HELLO" "$(string::to_upper "hello")"
}

function test_string_to_upper_no_change_on_uppercase() {
  assert_same "HELLO" "$(string::to_upper "HELLO")"
}

function test_string_to_upper_converts_mixed_case() {
  assert_same "HELLO WORLD" "$(string::to_upper "Hello World")"
}

# -----------------------------------------------------------------------------
# string::equals
# -----------------------------------------------------------------------------

function test_string_equals_returns_true_for_identical_strings() {
  string::equals "foo" "foo"
  assert_exit_code "0"
}

function test_string_equals_returns_false_for_different_strings() {
  string::equals "foo" "bar"
  assert_unsuccessful_code
}

function test_string_equals_is_case_sensitive() {
  string::equals "Hello" "hello"
  assert_unsuccessful_code
}

function test_string_equals_returns_true_for_empty_strings() {
  string::equals "" ""
  assert_exit_code "0"
}
