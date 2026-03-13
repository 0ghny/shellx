#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/io.sh"

_tmp_dir=""

set_up() {
  _tmp_dir="$(mktemp -d)"
}

tear_down() {
  rm -rf "${_tmp_dir}"
}

# -----------------------------------------------------------------------------
# io::exists
# -----------------------------------------------------------------------------

function test_io_exists_returns_true_for_existing_file() {
  local f="${_tmp_dir}/test_file.txt"
  touch "${f}"
  io::exists "${f}"
  assert_exit_code "0"
}

function test_io_exists_returns_true_for_existing_directory() {
  io::exists "${_tmp_dir}"
  assert_exit_code "0"
}

function test_io_exists_returns_false_for_nonexistent_path() {
  io::exists "${_tmp_dir}/this_does_not_exist_xyz"
  assert_unsuccessful_code
}

function test_io_exists_returns_false_for_empty_path() {
  io::exists ""
  assert_unsuccessful_code
}

function test_io_exists_returns_true_after_creating_file() {
  local f="${_tmp_dir}/created_later.txt"
  io::exists "${f}"
  assert_unsuccessful_code
  touch "${f}"
  io::exists "${f}"
  assert_exit_code "0"
}
