#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

# Stubs: config.sh uses log functions that are not loaded in unit tests
shellx::log_warn()  { :; }
shellx::log_info()  { :; }
shellx::log_debug() { :; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/config.sh"

set_up() {
  unset SHELLX_PLUGINS
  unset __shellx_config
}

tear_down() {
  unset SHELLX_PLUGINS
  unset __shellx_config
}

# -----------------------------------------------------------------------------
# shellx::config::reload
# -----------------------------------------------------------------------------

function test_config_reload_exits_successfully_with_valid_config() {
  SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config"
  export SHELLX_CONFIG
  shellx::config::reload
  assert_exit_code "0"
}

function test_config_reload_sets_config_path_from_env_var() {
  SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config"
  export SHELLX_CONFIG
  shellx::config::reload
  assert_same "${SHELLX_CONFIG}" "${__shellx_config}"
}

function test_config_reload_unsets_stale_shellx_plugins_before_sourcing() {
  export SHELLX_PLUGINS=(stale_value)
  SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config"
  export SHELLX_CONFIG
  shellx::config::reload
  # The value must differ from the stale one (config resets it)
  [[ "${SHELLX_PLUGINS[*]}" != "stale_value" ]]
  assert_exit_code "0"
}

function test_config_reload_exits_zero_when_no_config_file_exists() {
  local tmp_home
  tmp_home="$(mktemp -d)"
  unset SHELLX_CONFIG __shellx_config
  HOME="${tmp_home}" shellx::config::reload 2>/dev/null
  assert_exit_code "0"
  rm -rf "${tmp_home}"
}

function test_config_reload_does_not_set_config_path_when_file_not_found() {
  local tmp_home
  tmp_home="$(mktemp -d)"
  unset SHELLX_CONFIG __shellx_config
  HOME="${tmp_home}" shellx::config::reload 2>/dev/null
  # When no config file is found, __shellx_config should remain unset
  assert_empty "${__shellx_config}"
  rm -rf "${tmp_home}"
}

# -----------------------------------------------------------------------------
# shellx::config::print
# -----------------------------------------------------------------------------

function test_config_print_exits_successfully() {
  SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config" shellx::config::print > /dev/null
  assert_exit_code "0"
}

function test_config_print_includes_shellx_variables() {
  local output
  output=$(SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config" shellx::config::print)
  assert_contains "SHELLX_NO_BANNER" "${output}"
}

function test_config_print_does_not_include_non_shellx_variables() {
  export _UNIT_UNRELATED_VAR="nope"
  local output
  output=$(shellx::config::print)
  [[ ! "${output}" =~ "_UNIT_UNRELATED_VAR" ]]
  assert_exit_code "0"
  unset _UNIT_UNRELATED_VAR
}

# -----------------------------------------------------------------------------
# shellx::config::set
# -----------------------------------------------------------------------------

function test_config_set_fails_without_arguments() {
  shellx::config::set 2>/dev/null
  assert_exit_code "1"
}

function test_config_set_fails_with_disallowed_key() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  __shellx_config="${tmp_cfg}" shellx::config::set SOME_RANDOM_VAR yes 2>/dev/null
  assert_exit_code "1"
  rm -f "${tmp_cfg}"
}

function test_config_set_writes_key_to_config_file() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  __shellx_config="${tmp_cfg}" shellx::config::set SHELLX_DEBUG yes
  assert_contains "SHELLX_DEBUG=yes" "$(cat "${tmp_cfg}")"
  rm -f "${tmp_cfg}"
}

function test_config_set_replaces_existing_key() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  echo "SHELLX_DEBUG=no" > "${tmp_cfg}"
  __shellx_config="${tmp_cfg}" shellx::config::set SHELLX_DEBUG yes
  local count
  count=$(grep -c "^SHELLX_DEBUG=" "${tmp_cfg}")
  assert_same "1" "${count}"
  assert_contains "SHELLX_DEBUG=yes" "$(cat "${tmp_cfg}")"
  rm -f "${tmp_cfg}"
}

function test_config_set_no_banner_key() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  __shellx_config="${tmp_cfg}" shellx::config::set SHELLX_NO_BANNER yes
  assert_contains "SHELLX_NO_BANNER=yes" "$(cat "${tmp_cfg}")"
  rm -f "${tmp_cfg}"
}

function test_config_set_plugins_key() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  __shellx_config="${tmp_cfg}" shellx::config::set SHELLX_PLUGINS "( @all )"
  assert_contains "SHELLX_PLUGINS=( @all )" "$(cat "${tmp_cfg}")"
  rm -f "${tmp_cfg}"
}

# -----------------------------------------------------------------------------
# shellx::config::unset
# -----------------------------------------------------------------------------

function test_config_unset_fails_without_arguments() {
  shellx::config::unset 2>/dev/null
  assert_exit_code "1"
}

function test_config_unset_fails_with_disallowed_key() {
  shellx::config::unset SOME_RANDOM_VAR 2>/dev/null
  assert_exit_code "1"
}

function test_config_unset_removes_key_from_config_file() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  echo "SHELLX_DEBUG=yes" > "${tmp_cfg}"
  __shellx_config="${tmp_cfg}" shellx::config::unset SHELLX_DEBUG
  local count
  count=$(grep -c "^SHELLX_DEBUG=" "${tmp_cfg}" || true)
  assert_same "0" "${count}"
  rm -f "${tmp_cfg}"
}

function test_config_unset_is_idempotent_when_key_not_present() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  __shellx_config="${tmp_cfg}" shellx::config::unset SHELLX_DEBUG
  assert_exit_code "0"
  rm -f "${tmp_cfg}"
}

function test_config_unset_preserves_other_keys() {
  local tmp_cfg
  tmp_cfg="$(mktemp)"
  printf "SHELLX_NO_BANNER=yes\nSHELLX_DEBUG=yes\n" > "${tmp_cfg}"
  __shellx_config="${tmp_cfg}" shellx::config::unset SHELLX_DEBUG
  assert_contains "SHELLX_NO_BANNER=yes" "$(cat "${tmp_cfg}")"
  rm -f "${tmp_cfg}"
}
