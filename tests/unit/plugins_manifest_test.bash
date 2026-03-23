#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

export __shellx_homedir="${SHELLX_HOME}"
export __shellx_libdir="${SHELLX_HOME}/lib"

# Stubs
shellx::log_error() { :; }
shellx::log_warn()  { :; }
shellx::log_info()  { :; }
shellx::log_debug() { :; }

# Also source plugins.manager so shellx::plugins::is_installed is available
# for shellx::plugins::sync tests
shellx::plugins::is_installed() { return 1; }  # stub; overridden in tests that need it
shellx::plugins::install()      { echo "install-called:$*"; }  # stub
shellx::plugins::reload()       { :; }  # stub

# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/shellx/plugins/plugins.manifest.sh"

# Scratch directory shared per test (isolated via SHELLX_PLUGINS_MANIFEST override)
_MANIFEST_TMPDIR=""

set_up() {
  unset SHELLX_PLUGINS_MANIFEST
  _MANIFEST_TMPDIR="$(mktemp -d)"
  export SHELLX_PLUGINS_MANIFEST="${_MANIFEST_TMPDIR}/plugins.installed"
}

tear_down() {
  rm -rf "${_MANIFEST_TMPDIR}"
  unset SHELLX_PLUGINS_MANIFEST
}

# -----------------------------------------------------------------------------
# shellx::plugins::manifest::path
# -----------------------------------------------------------------------------

function test_manifest_path_returns_env_var_when_set() {
  local path
  path=$(shellx::plugins::manifest::path)
  assert_same "${_MANIFEST_TMPDIR}/plugins.installed" "${path}"
}

function test_manifest_path_uses_home_shellx_plugins_when_env_unset() {
  unset SHELLX_PLUGINS_MANIFEST
  local path
  path=$(shellx::plugins::manifest::path)
  assert_same "${HOME}/.shellx.plugins" "${path}"
}

function test_manifest_path_contains_shellx_plugins_filename() {
  unset SHELLX_PLUGINS_MANIFEST
  local path
  path=$(shellx::plugins::manifest::path)
  assert_contains ".shellx.plugins" "${path}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::manifest::save
# -----------------------------------------------------------------------------

function test_manifest_save_creates_file_if_missing() {
  shellx::plugins::manifest::save "https://github.com/user/plugin"
  assert_file_exists "${SHELLX_PLUGINS_MANIFEST}"
}

function test_manifest_save_writes_url_to_file() {
  shellx::plugins::manifest::save "https://github.com/user/plugin"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "https://github.com/user/plugin"
}

function test_manifest_save_writes_url_and_ref_when_provided() {
  shellx::plugins::manifest::save "https://github.com/user/plugin" "main"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "https://github.com/user/plugin | main"
}

function test_manifest_save_writes_url_without_separator_when_ref_empty() {
  shellx::plugins::manifest::save "https://github.com/user/plugin" ""
  local content
  # Strip comment lines before checking — the header contains '| ' by design
  content=$(grep -v '^#' "${SHELLX_PLUGINS_MANIFEST}")
  assert_not_contains "| " "${content}"
}

function test_manifest_save_creates_comment_header() {
  shellx::plugins::manifest::save "https://github.com/user/plugin"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "ShellX Plugins Manifest"
}

function test_manifest_save_is_idempotent_for_same_url() {
  shellx::plugins::manifest::save "https://github.com/user/plugin" "main"
  shellx::plugins::manifest::save "https://github.com/user/plugin" "main"
  local count
  count=$(grep -c "https://github.com/user/plugin" "${SHELLX_PLUGINS_MANIFEST}")
  assert_same "1" "${count}"
}

function test_manifest_save_updates_ref_for_existing_url() {
  shellx::plugins::manifest::save "https://github.com/user/plugin" "main"
  shellx::plugins::manifest::save "https://github.com/user/plugin" "v2.0"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "v2.0"
  local count
  count=$(grep -c "https://github.com/user/plugin" "${SHELLX_PLUGINS_MANIFEST}")
  assert_same "1" "${count}"
}

function test_manifest_save_appends_multiple_different_plugins() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a"
  shellx::plugins::manifest::save "https://github.com/user/plugin-b"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "plugin-a"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "plugin-b"
}

function test_manifest_save_creates_parent_directory_if_missing() {
  local deep_path="${_MANIFEST_TMPDIR}/deeply/nested/dir/plugins.installed"
  SHELLX_PLUGINS_MANIFEST="${deep_path}"
  shellx::plugins::manifest::save "https://github.com/user/plugin"
  assert_file_exists "${deep_path}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::manifest::remove
# -----------------------------------------------------------------------------

function test_manifest_remove_removes_entry_by_plugin_name() {
  shellx::plugins::manifest::save "https://github.com/user/myplugin"
  shellx::plugins::manifest::remove "myplugin"
  local content
  content=$(grep -v "^#" "${SHELLX_PLUGINS_MANIFEST}" | grep -v "^$" || true)
  assert_empty "${content}"
}

function test_manifest_remove_removes_entry_with_git_suffix() {
  shellx::plugins::manifest::save "https://github.com/user/myplugin.git"
  shellx::plugins::manifest::remove "myplugin"
  local content
  content=$(grep -v "^#" "${SHELLX_PLUGINS_MANIFEST}" | grep "myplugin" || true)
  assert_empty "${content}"
}

function test_manifest_remove_does_not_affect_other_plugins() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a"
  shellx::plugins::manifest::save "https://github.com/user/plugin-b"
  shellx::plugins::manifest::remove "plugin-a"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "plugin-b"
}

function test_manifest_remove_is_noop_when_manifest_missing() {
  rm -f "${SHELLX_PLUGINS_MANIFEST}"
  shellx::plugins::manifest::remove "nonexistent"
  assert_exit_code "0"
}

function test_manifest_remove_is_noop_for_unknown_plugin_name() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a"
  shellx::plugins::manifest::remove "totally-unknown-xyz"
  assert_file_contains "${SHELLX_PLUGINS_MANIFEST}" "plugin-a"
}

# -----------------------------------------------------------------------------
# shellx::plugins::sync
# -----------------------------------------------------------------------------

function test_sync_fails_when_manifest_missing() {
  rm -f "${SHELLX_PLUGINS_MANIFEST}"
  shellx::plugins::sync 2>/dev/null
  assert_exit_code "1"
}

function test_sync_prints_error_when_manifest_missing() {
  rm -f "${SHELLX_PLUGINS_MANIFEST}"
  local output
  output=$(shellx::plugins::sync 2>&1)
  assert_contains "Manifest not found" "${output}"
}

function test_sync_skips_already_installed_plugins() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a"
  shellx::plugins::is_installed() { return 0; }  # everything "installed"
  local output
  output=$(shellx::plugins::sync 2>/dev/null)
  assert_contains "already installed" "${output}"
}

function test_sync_calls_install_for_missing_plugins() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a"
  shellx::plugins::is_installed() { return 1; }  # nothing installed
  local output
  output=$(shellx::plugins::sync 2>/dev/null)
  assert_contains "install-called" "${output}"
}

function test_sync_passes_ref_to_install_when_set() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a" "v1.2"
  shellx::plugins::is_installed() { return 1; }
  local output
  output=$(shellx::plugins::sync 2>/dev/null)
  assert_contains "v1.2" "${output}"
}

function test_sync_prints_summary_line() {
  shellx::plugins::manifest::save "https://github.com/user/plugin-a"
  shellx::plugins::is_installed() { return 1; }
  local output
  output=$(shellx::plugins::sync 2>/dev/null)
  assert_contains "Sync complete" "${output}"
}

function test_sync_ignores_comment_lines_in_manifest() {
  printf "# This is a comment\n" > "${SHELLX_PLUGINS_MANIFEST}"
  printf "# Another comment\n" >> "${SHELLX_PLUGINS_MANIFEST}"
  shellx::plugins::is_installed() { return 1; }
  local install_called=0
  shellx::plugins::install() { install_called=1; }
  shellx::plugins::sync > /dev/null 2>&1
  assert_same "0" "${install_called}"
}

function test_sync_ignores_blank_lines_in_manifest() {
  printf "\n\n\n" > "${SHELLX_PLUGINS_MANIFEST}"
  shellx::plugins::is_installed() { return 1; }
  local install_called=0
  shellx::plugins::install() { install_called=1; }
  shellx::plugins::sync > /dev/null 2>&1
  assert_same "0" "${install_called}"
}

# -----------------------------------------------------------------------------
# shellx::plugins::export
# -----------------------------------------------------------------------------

function test_export_outputs_header_comment() {
  export __shellx_plugins_d="${_MANIFEST_TMPDIR}/plugins.d"
  mkdir -p "${__shellx_plugins_d}"
  local output
  output=$(shellx::plugins::export)
  assert_contains "ShellX Plugins Manifest" "${output}"
}

function test_export_outputs_nothing_for_empty_plugins_dir() {
  export __shellx_plugins_d="${_MANIFEST_TMPDIR}/plugins.d"
  mkdir -p "${__shellx_plugins_d}"
  local output
  output=$(shellx::plugins::export | grep -v '^#')
  assert_empty "${output}"
}

function test_export_outputs_nothing_when_plugins_dir_missing() {
  export __shellx_plugins_d="${_MANIFEST_TMPDIR}/no-such-dir"
  local output
  output=$(shellx::plugins::export | grep -v '^#')
  assert_empty "${output}"
}

function test_export_skips_non_git_directories() {
  export __shellx_plugins_d="${_MANIFEST_TMPDIR}/plugins.d"
  mkdir -p "${__shellx_plugins_d}/not-a-git-repo"
  local output
  output=$(shellx::plugins::export | grep -v '^#')
  assert_empty "${output}"
}

function test_export_includes_url_for_git_plugin() {
  export __shellx_plugins_d="${_MANIFEST_TMPDIR}/plugins.d"
  local repo_dir="${_MANIFEST_TMPDIR}/plugins.d/myplugin"
  mkdir -p "${repo_dir}"
  git -C "${repo_dir}" init -q
  git -C "${repo_dir}" remote add origin https://github.com/user/myplugin
  local output
  output=$(shellx::plugins::export)
  assert_contains "https://github.com/user/myplugin" "${output}"
}

function test_export_includes_branch_ref_for_git_plugin() {
  export __shellx_plugins_d="${_MANIFEST_TMPDIR}/plugins.d"
  local repo_dir="${_MANIFEST_TMPDIR}/plugins.d/myplugin"
  mkdir -p "${repo_dir}"
  git -C "${repo_dir}" init -q
  git -C "${repo_dir}" remote add origin https://github.com/user/myplugin
  # Create a commit so the branch is resolvable
  git -C "${repo_dir}" commit --allow-empty -q -m "init"
  local output
  output=$(shellx::plugins::export)
  # Should include a ref (branch name)
  assert_contains "|" "${output}"
}
