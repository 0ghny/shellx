#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
SHELLX_PLUGINS_D=/tmp/shellx-bashunit-tests
SHELLX_CONFIG="${SHELLX_HOME}/tests/config/shellx_config"
SHELLX_DEBUG=no
SHELLX_NO_BANNER=1
export SHELLX_HOME SHELLX_PLUGINS_D SHELLX_DEBUG SHELLX_CONFIG SHELLX_NO_BANNER

set_up() {
  rm -rf "${SHELLX_PLUGINS_D}"
  mkdir -p "${SHELLX_PLUGINS_D}"
  # WHY this symlink is required:
  # The test config (tests/config/shellx_config) sets SHELLX_PLUGINS=( @.shellx ).
  # The plugin loader resolves @<name> tokens by scanning SHELLX_PLUGINS_D for entries
  # whose basename matches <name>. Without a directory/symlink called '.shellx' inside
  # SHELLX_PLUGINS_D, the token '@.shellx' never matches and no plugins are loaded,
  # causing all tests that depend on loaded plugins to fail.
  ln -s "${SHELLX_HOME}" "${SHELLX_PLUGINS_D}/.shellx"
  # shellcheck source=/dev/null
  source "${SHELLX_HOME}/shellx.sh"
}

tear_down() {
  rm -rf "${SHELLX_PLUGINS_D}"
}

# -----------------------------------------------------------------------------
# Core environment variables
# -----------------------------------------------------------------------------

function test_shellx_homedir_is_set() {
  assert_not_empty "${__shellx_homedir}"
}

function test_shellx_homedir_points_to_existing_directory() {
  assert_is_directory "${__shellx_homedir}"
}

function test_shellx_bindir_is_set() {
  assert_not_empty "${__shellx_bindir}"
}

function test_shellx_bindir_is_inside_homedir() {
  assert_contains "${__shellx_homedir}" "${__shellx_bindir}"
}

function test_shellx_libdir_is_set() {
  assert_not_empty "${__shellx_libdir}"
}

function test_shellx_libdir_points_to_existing_directory() {
  assert_is_directory "${__shellx_libdir}"
}

function test_shellx_libdir_is_inside_homedir() {
  assert_contains "${__shellx_homedir}" "${__shellx_libdir}"
}

function test_shellx_plugins_d_is_set() {
  assert_not_empty "${__shellx_plugins_d}"
}

function test_shellx_plugins_d_points_to_existing_directory() {
  assert_is_directory "${__shellx_plugins_d}"
}

function test_shellx_pluginsdir_is_set() {
  assert_not_empty "${__shellx_pluginsdir}"
}

function test_shellx_feature_loadtime_start_is_set() {
  assert_not_empty "${__shellx_feature_loadtime_start}"
}

function test_shellx_feature_loadtime_end_is_set() {
  assert_not_empty "${__shellx_feature_loadtime_end}"
}

# -----------------------------------------------------------------------------
# Libraries loaded
# -----------------------------------------------------------------------------

function test_at_least_one_library_is_loaded() {
  assert_not_empty "${__shellx_loaded_libraries[*]}"
}

function test_all_lib_files_are_loaded() {
  local lib missing=()
  while IFS= read -r lib; do
    local name
    name="$(basename "${lib}")"
    local found=0
    for loaded in "${__shellx_loaded_libraries[@]}"; do
      [ "${loaded}" = "${name}" ] && found=1 && break
    done
    [ "${found}" -eq 0 ] && missing+=("${name}")
  done < <(find "${SHELLX_HOME}/lib" -name '*.*sh' | sort)

  if [ "${#missing[@]}" -gt 0 ]; then
    bashunit::fail "Libraries not loaded: ${missing[*]}"
  fi
  assert_same "0" "0"
}

# -----------------------------------------------------------------------------
# Plugins loaded
# -----------------------------------------------------------------------------

function test_plugins_loaded_array_is_not_empty() {
  assert_not_empty "${__shellx_plugins_loaded[*]}"
}

function test_plugins_locations_array_is_not_empty() {
  assert_not_empty "${__shellx_plugins_locations[*]}"
}

function test_shellx_update_plugin_is_loaded() {
  assert_array_contains "@.shellx/shellx_update.sh" "${__shellx_plugins_loaded[@]}"
}

function test_wellcome_plugin_is_loaded() {
  assert_array_contains "@.shellx/wellcome.sh" "${__shellx_plugins_loaded[@]}"
}

function test_shellx_plugins_location_is_registered() {
  local found=0
  local loc
  for loc in "${__shellx_plugins_locations[@]}"; do
    case "${loc}" in *"${__shellx_homedir}"*) found=1 ;; esac
  done
  assert_same "1" "${found}"
}

# -----------------------------------------------------------------------------
# shellx function available
# -----------------------------------------------------------------------------

function test_shellx_function_is_defined() {
  declare -f shellx > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_version_function_is_defined() {
  declare -f shellx::version > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_info_function_is_defined() {
  declare -f shellx::info > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_debug_function_is_defined() {
  declare -f shellx::cli::debug > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_config_function_is_defined() {
  declare -f shellx::cli::config > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_plugins_reload_function_is_defined() {
  declare -f shellx::plugins::reload > /dev/null 2>&1
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# Sanity: basic commands exit 0
# -----------------------------------------------------------------------------

function test_shellx_version_command_exits_successfully() {
  shellx version > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_info_command_exits_successfully() {
  shellx info > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_list_command_exits_successfully() {
  shellx list > /dev/null 2>&1
  assert_exit_code "0"
}

function test_shellx_help_command_exits_successfully() {
  shellx help > /dev/null 2>&1
  assert_exit_code "0"
}
