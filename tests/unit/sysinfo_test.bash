#!/usr/bin/env bash

SHELLX_HOME="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"

shellx::log_error() { :; }
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/env.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/sysinfo/sysinfo.arch.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/sysinfo/sysinfo.kernel.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/sysinfo/sysinfo.platform.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/sysinfo/sysinfo.uptime.sh"
# shellcheck source=/dev/null
source "${SHELLX_HOME}/lib/core/sysinfo/sysinfo.host.sh"

# -----------------------------------------------------------------------------
# sysinfo::arch::native / sysinfo::arch::name
# -----------------------------------------------------------------------------

function test_sysinfo_arch_native_returns_non_empty() {
  assert_not_empty "$(sysinfo::arch::native)"
}

function test_sysinfo_arch_name_returns_known_value() {
  local arch
  arch="$(sysinfo::arch::name)"
  [[  "${arch}" =~ ^(386|amd64|arm64|arm|Unknown)$ ]]
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# sysinfo::platform::native / sysinfo::platform::name
# -----------------------------------------------------------------------------

function test_sysinfo_platform_native_returns_non_empty() {
  assert_not_empty "$(sysinfo::platform::native)"
}

function test_sysinfo_platform_name_returns_known_value() {
  local plat
  plat="$(sysinfo::platform::name)"
  [[  "${plat}" =~ ^(linux|darwin|Unknown)$ ]]
  assert_exit_code "0"
}

function test_sysinfo_platform_short_returns_known_value() {
  local name
  name="$(sysinfo::platform::short)"
  [[  "${name}" =~ ^(linux|mac|win|Unknown)$ ]]
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# sysinfo::kernel::*
# -----------------------------------------------------------------------------

function test_sysinfo_kernel_name_returns_non_empty() {
  assert_not_empty "$(sysinfo::kernel::name)"
}

function test_sysinfo_kernel_version_returns_non_empty() {
  assert_not_empty "$(sysinfo::kernel::version)"
}

function test_sysinfo_kernel_machine_returns_non_empty() {
  assert_not_empty "$(sysinfo::kernel::machine)"
}

function test_sysinfo_kernel_full_returns_name_and_version_combined() {
  local k
  k="$(sysinfo::kernel::full)"
  assert_not_empty "${k}"
  assert_contains "$(sysinfo::kernel::name)" "${k}"
}

function test_sysinfo_platform_os_returns_known_value() {
  local os
  os="$(sysinfo::platform::os)"
  [[  "${os}" =~ ^(Darwin|Linux|BSD|Windows|Solaris|Haiku|MINIX|AIX|IRIX|FreeMiNT|Unknown)$ ]]
  assert_exit_code "0"
}

# -----------------------------------------------------------------------------
# sysinfo::host::name / sysinfo::host::users
# -----------------------------------------------------------------------------

function test_sysinfo_host_name_returns_non_empty() {
  assert_not_empty "$(sysinfo::host::name)"
}

function test_sysinfo_host_users_returns_non_empty() {
  assert_not_empty "$(sysinfo::host::users)"
}

# -----------------------------------------------------------------------------
# sysinfo::uptime
# -----------------------------------------------------------------------------

function test_sysinfo_uptime_returns_non_empty() {
  assert_not_empty "$(sysinfo::uptime)"
}

function test_sysinfo_uptime_output_contains_time_unit() {
  local s
  s="$(sysinfo::uptime)"
  # Output is human-readable, e.g. "3 days, 2 hours, 30 mins" or "45 secs"
  [[  "${s}" =~ (day|hour|min|sec) ]]
  assert_exit_code "0"
}
