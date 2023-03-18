#!/usr/bin/env bats

# .............................................................................
# PRE-POST hooks
# .............................................................................
setup() {
  load test_helper.bash
  load_lib bats-support
  load_lib bats-assert
  shellx::tests::session_start
}

teardown() {
  shellx::tests::session_end
}

# .............................................................................
# TESTS
# .............................................................................
@test "install valid plugin url should returns OK" {
  run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
  assert_success
}

@test "install plugin allready installed should not install it and returns a message saying it's already installed" {
  run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
  run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
  assert_success
  assert_output --partial "[PLUGIN] It's already installed"
}

@test "install invalid plugin url should fail and returns KO" {
  run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins2
  assert_failure
}

@test "uninstall a plugin" {
  run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
  assert_success
  run shellx::plugins::is_installed shellx-community-plugins
  assert_success
  run shellx::plugins::uninstall shellx-community-plugins
  assert_success
  run shellx::plugins::is_installed shellx-community-plugins
  assert_failure
}

@test "is_installed should return 0 if plugin is installed" {
  run shellx::plugins::install https://github.com/0ghny/shellx-community-plugins
  run shellx::plugins::is_installed shellx-community-plugins
  assert_success
}

@test "is_installed should return 1 if plugin is not installed" {
  run shellx::plugins::is_installed not-installed-plugin
  assert_failure
}

@test "installed should returns plugins installed" {
  run shellx::plugins::installed
  assert_success
  assert_output --partial "[*] plugins (${SHELLX_HOME}/plugins)"
}
