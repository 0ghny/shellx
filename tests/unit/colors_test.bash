#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/colors.sh"

# -----------------------------------------------------------------------------
# Color variables are defined
# -----------------------------------------------------------------------------

function test_color_reset_is_defined() {
  assert_not_empty "${_color_reset}"
}

function test_color_black_is_defined() {
  assert_not_empty "${_color_black}"
}

function test_color_red_is_defined() {
  assert_not_empty "${_color_red}"
}

function test_color_bold_red_is_defined() {
  assert_not_empty "${_color_bold_red}"
}

function test_color_green_is_defined() {
  assert_not_empty "${_color_green}"
}

function test_color_bold_green_is_defined() {
  assert_not_empty "${_color_bold_green}"
}

function test_color_yellow_is_defined() {
  assert_not_empty "${_color_yellow}"
}

function test_color_bold_yellow_is_defined() {
  assert_not_empty "${_color_bold_yellow}"
}

function test_color_blue_is_defined() {
  assert_not_empty "${_color_blue}"
}

function test_color_bold_blue_is_defined() {
  assert_not_empty "${_color_bold_blue}"
}

function test_color_cyan_is_defined() {
  assert_not_empty "${_color_cyan}"
}

function test_color_bold_cyan_is_defined() {
  assert_not_empty "${_color_bold_cyan}"
}

function test_color_white_is_defined() {
  assert_not_empty "${_color_white}"
}

function test_color_bold_white_is_defined() {
  assert_not_empty "${_color_bold_white}"
}
