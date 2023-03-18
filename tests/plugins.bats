#!/usr/bin/env bats

# .............................................................................
# PRE-POST hooks
# .............................................................................
setup() {
  bats_require_minimum_version 1.5.0
  echo "Sets shellx plugins directory to a temporary location"
  export SHELLX_PLUGINS_D=/tmp/shellx-bats-tests
  rm -rf "${SHELLX_PLUGINS_D}"
  mkdir "${SHELLX_PLUGINS_D}"

  export SHELLX_HOME=$(git rev-parse --show-toplevel)
  export SHELLX_DEBUG=NO
  export SHELLX_CONFIG=${SHELLX_HOME}/tests/shellx_config_tests
  load ${SHELLX_HOME}/shellx.sh
  load ${SHELLX_HOME}/tests/test_utils.sh
}

teardown() {
    echo "Cleaning testing resources"
    rm -rf "${SHELLX_PLUGINS_D}"
}

# .............................................................................
# TESTS
# .............................................................................
@test "install valid plugin url should returns OK" {
    run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
    [[ "${status}" -eq 0 ]]
}

@test "install plugin allready installed should not install it and returns a message saying it's already installed" {
    run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
    run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
    [[ "${status}" -eq 0 ]]
    [[ "${output}" =~ "[PLUGIN] It's already installed" ]]
}

@test "install invalid plugin url should fail and returns KO" {
    run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins2
    [[ "${status}" -ne 0 ]]
}

@test "uninstall a plugin" {
    run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
    [[ "${status}" -eq 0 ]]
    run shellx::plugins::is_installed shellx-community-plugins
    [[ "${status}" -eq 0 ]]
    run shellx::plugins::uninstall shellx-community-plugins
    [[ "${status}" -eq 0 ]]
    run shellx::plugins::is_installed shellx-community-plugins
    [[ "${status}" -eq 1 ]]
}

@test "is_installed should return 0 if plugin is installed" {
    run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
    run shellx::plugins::is_installed shellx-community-plugins
    [[ "${status}" -eq 0 ]]
}

@test "is_installed should return 1 if plugin is not installed" {
    run shellx::plugins::is_installed not-installed-plugin
    [[ "${status}" -eq 1 ]]
}

@test "installed should returns plugins installed" {
    run shellx::plugins::installed
    [[ "${status}" -eq 0 ]]
    [[ "${output}" =~ "[*] plugins (${SHELLX_HOME}/plugins)" ]]
}
