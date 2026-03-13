#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

export __shellx_homedir="${SHELLX_HOME}"
export __shellx_libdir="${SHELLX_HOME}/lib"

# Stubs: log functions are not loaded in unit tests
shellx::log_error() { :; }
shellx::log_warn()  { :; }
shellx::log_info()  { :; }
shellx::log_debug() { :; }

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/plugins/plugins.manager.sh"

set_up() {
  unset SHELLX_PLUGINS_REGISTRY
  export __shellx_homedir="${SHELLX_HOME}"
  export __shellx_libdir="${SHELLX_HOME}/lib"
}

tear_down() {
  unset SHELLX_PLUGINS_REGISTRY
}

# -----------------------------------------------------------------------------
# shellx::plugins::is_url
# -----------------------------------------------------------------------------

function test_plugins_is_url_returns_true_for_https_url() {
  shellx::plugins::is_url "https://github.com/example/plugin"
  assert_exit_code "0"
}

function test_plugins_is_url_returns_true_for_http_url() {
  shellx::plugins::is_url "http://example.com/plugin"
  assert_exit_code "0"
}

function test_plugins_is_url_returns_true_for_git_at_url() {
  shellx::plugins::is_url "git@github.com:user/repo"
  assert_exit_code "0"
}

function test_plugins_is_url_returns_true_for_file_url() {
  shellx::plugins::is_url "file:///local/path/plugin"
  assert_exit_code "0"
}

function test_plugins_is_url_returns_false_for_plain_package_name() {
  shellx::plugins::is_url "community"
  assert_unsuccessful_code
}

function test_plugins_is_url_returns_false_for_empty_string() {
  shellx::plugins::is_url ""
  assert_unsuccessful_code
}

function test_plugins_is_url_returns_false_for_relative_path() {
  shellx::plugins::is_url "./local/plugin"
  assert_unsuccessful_code
}

function test_plugins_is_url_returns_false_for_bare_hostname() {
  shellx::plugins::is_url "github.com/user/repo"
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# shellx::plugins::config_file_path
# -----------------------------------------------------------------------------

function test_plugins_config_file_path_uses_env_var_when_set() {
  SHELLX_PLUGINS_REGISTRY="${SHELLX_HOME}/plugins.repositories"
  export SHELLX_PLUGINS_REGISTRY
  local path
  path=$(shellx::plugins::config_file_path)
  assert_same "${SHELLX_HOME}/plugins.repositories" "${path}"
}

function test_plugins_config_file_path_returns_non_empty_path() {
  local path
  path=$(shellx::plugins::config_file_path)
  assert_not_empty "${path}"
}

function test_plugins_config_file_path_contains_plugins_repositories_filename() {
  local path
  path=$(shellx::plugins::config_file_path)
  assert_contains "plugins.repositories" "${path}"
}

function test_plugins_config_file_path_falls_back_to_homedir_bundled_registry() {
  unset SHELLX_PLUGINS_REGISTRY
  local path
  path=$(shellx::plugins::config_file_path)
  # The bundled file at $__shellx_homedir/plugins.repositories should be found
  assert_contains "${SHELLX_HOME}" "${path}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::get_url
# -----------------------------------------------------------------------------

function test_plugins_get_url_returns_url_for_known_package() {
  local url
  url=$(shellx::plugins::get_url "community")
  assert_not_empty "${url}"
}

function test_plugins_get_url_returns_github_url_for_community() {
  local url
  url=$(shellx::plugins::get_url "community")
  assert_contains "https://github.com" "${url}"
}

function test_plugins_get_url_fails_for_unknown_package() {
  shellx::plugins::get_url "totally-unknown-pkg-xyz-123" 2>/dev/null
  assert_unsuccessful_code
}

function test_plugins_get_url_fails_for_empty_package_name() {
  shellx::plugins::get_url "" 2>/dev/null
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# shellx::plugins::exists
# -----------------------------------------------------------------------------

function test_plugins_exists_returns_true_for_registered_package() {
  shellx::plugins::exists "community"
  assert_exit_code "0"
}

function test_plugins_exists_returns_true_for_dotfiles_package() {
  shellx::plugins::exists "dotfiles"
  assert_exit_code "0"
}

function test_plugins_exists_returns_false_for_unknown_package() {
  shellx::plugins::exists "totally-unknown-pkg-xyz-123"
  assert_unsuccessful_code
}

function test_plugins_exists_returns_false_for_empty_name() {
  shellx::plugins::exists ""
  assert_unsuccessful_code
}

# -----------------------------------------------------------------------------
# shellx::plugins::manager::resolve_url
# -----------------------------------------------------------------------------

function test_plugins_resolve_url_returns_https_url_unchanged() {
  local result
  result=$(shellx::plugins::manager::resolve_url "https://github.com/example/plugin")
  assert_same "https://github.com/example/plugin" "${result}"
}

function test_plugins_resolve_url_returns_git_url_unchanged() {
  local result
  result=$(shellx::plugins::manager::resolve_url "git@github.com:user/repo")
  assert_same "git@github.com:user/repo" "${result}"
}

function test_plugins_resolve_url_resolves_known_package_name_to_url() {
  local result
  result=$(shellx::plugins::manager::resolve_url "community")
  assert_contains "https://github.com" "${result}"
}

function test_plugins_resolve_url_fails_for_unknown_package_name() {
  shellx::plugins::manager::resolve_url "totally-unknown-pkg-xyz-123" 2>/dev/null
  assert_unsuccessful_code
}

function test_plugins_resolve_url_fails_for_empty_input() {
  shellx::plugins::manager::resolve_url "" 2>/dev/null
  assert_unsuccessful_code
}
