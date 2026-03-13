#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs: capture calls made to the underlying log functions so tests can inspect them
_last_log_level=""
_last_log_message=""

shellx::log_info()  { _last_log_level="info";  _last_log_message="$*"; }
shellx::log_debug() { _last_log_level="debug"; _last_log_message="$*"; }
shellx::log_error() { _last_log_level="error"; _last_log_message="$*"; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/plugins/plugins.log.sh"

set_up() {
  _last_log_level=""
  _last_log_message=""
}

# -----------------------------------------------------------------------------
# shellx::plugins::log_info
# -----------------------------------------------------------------------------

function test_plugins_log_info_delegates_to_log_info() {
  shellx::plugins::log_info "myplugin" "hello"
  assert_same "info" "${_last_log_level}"
}

function test_plugins_log_info_prefixes_message_with_plugin_name() {
  shellx::plugins::log_info "myplugin" "hello"
  assert_contains "[PLUGIN myplugin]" "${_last_log_message}"
}

function test_plugins_log_info_includes_message_text() {
  shellx::plugins::log_info "myplugin" "custom message text"
  assert_contains "custom message text" "${_last_log_message}"
}

function test_plugins_log_info_uses_unknown_when_no_plugin_name() {
  shellx::plugins::log_info "" "some message"
  assert_contains "[PLUGIN unknown]" "${_last_log_message}"
}

function test_plugins_log_info_shows_default_message_when_no_message_given() {
  shellx::plugins::log_info "myplugin"
  assert_contains "Non specified message" "${_last_log_message}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::log_debug
# -----------------------------------------------------------------------------

function test_plugins_log_debug_delegates_to_log_debug() {
  shellx::plugins::log_debug "myplugin" "debug text"
  assert_same "debug" "${_last_log_level}"
}

function test_plugins_log_debug_prefixes_message_with_plugin_name() {
  shellx::plugins::log_debug "corepkg" "debug text"
  assert_contains "[PLUGIN corepkg]" "${_last_log_message}"
}

function test_plugins_log_debug_includes_message_text() {
  shellx::plugins::log_debug "myplugin" "specific debug info"
  assert_contains "specific debug info" "${_last_log_message}"
}

function test_plugins_log_debug_uses_unknown_when_no_plugin_name() {
  shellx::plugins::log_debug "" "msg"
  assert_contains "[PLUGIN unknown]" "${_last_log_message}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::log_error
# -----------------------------------------------------------------------------

function test_plugins_log_error_delegates_to_log_error() {
  shellx::plugins::log_error "myplugin" "something failed"
  assert_same "error" "${_last_log_level}"
}

function test_plugins_log_error_prefixes_message_with_plugin_name() {
  shellx::plugins::log_error "badplugin" "something failed"
  assert_contains "[PLUGIN badplugin]" "${_last_log_message}"
}

function test_plugins_log_error_includes_message_text() {
  shellx::plugins::log_error "myplugin" "error description"
  assert_contains "error description" "${_last_log_message}"
}

function test_plugins_log_error_uses_unknown_when_no_plugin_name() {
  shellx::plugins::log_error "" "error msg"
  assert_contains "[PLUGIN unknown]" "${_last_log_message}"
}

function test_plugins_log_error_shows_default_message_when_no_message_given() {
  shellx::plugins::log_error "myplugin"
  assert_contains "Non specified message" "${_last_log_message}"
}
