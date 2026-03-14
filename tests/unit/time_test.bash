#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/time.sh"

# -----------------------------------------------------------------------------
# time::to_human_readable
# -----------------------------------------------------------------------------

function test_time_to_human_readable_zero_seconds() {
  assert_same "00 hr 00 min 00 sec" "$(time::to_human_readable 0)"
}

function test_time_to_human_readable_one_minute() {
  assert_same "00 hr 01 min 00 sec" "$(time::to_human_readable 60)"
}

function test_time_to_human_readable_one_hour() {
  assert_same "01 hr 00 min 00 sec" "$(time::to_human_readable 3600)"
}

function test_time_to_human_readable_complex_value() {
  assert_same "01 hr 01 min 01 sec" "$(time::to_human_readable 3661)"
}

function test_time_to_human_readable_only_seconds() {
  assert_same "00 hr 00 min 45 sec" "$(time::to_human_readable 45)"
}

function test_time_to_human_readable_large_value() {
  assert_same "02 hr 46 min 40 sec" "$(time::to_human_readable 10000)"
}

# -----------------------------------------------------------------------------
# time::capture
# -----------------------------------------------------------------------------

function test_time_capture_returns_non_empty_value() {
  assert_not_empty "$(time::capture)"
}

function test_time_capture_returns_numeric_value() {
  local ts
  ts="$(time::capture)"
  [[  "${ts}" =~ ^[0-9]+$ ]]
  assert_exit_code "0"
}

function test_time_capture_increases_over_time() {
  local t1 t2
  t1="$(time::capture)"
  sleep 1
  t2="$(time::capture)"
  [ "${t2}" -gt "${t1}" ]
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# time::elapsed
# -----------------------------------------------------------------------------

function test_time_elapsed_returns_difference() {
  assert_same "10" "$(time::elapsed 100 110)"
}

function test_time_elapsed_returns_zero_for_same_timestamps() {
  assert_same "0" "$(time::elapsed 100 100)"
}

function test_time_elapsed_returns_correct_value_for_one_second() {
  assert_same "1" "$(time::elapsed 999 1000)"
}

function test_time_elapsed_returns_large_difference() {
  assert_same "3600" "$(time::elapsed 0 3600)"
}
