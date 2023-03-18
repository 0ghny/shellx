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
@test "version should returns current version (branch-commit)" {
  # Arrange
  local current_branch="$(git rev-parse --abbrev-ref HEAD)"
  local current_commit="$(git rev-parse --short HEAD)"

  # Act
  run shellx version

  # Assert
  assert_success
  assert_output --partial "${current_branch}-${current_commit}"
}

@test "version info should returns release notes" {
  # Act
  run shellx version info

  # Assert
  assert_success
  assert_output --partial "Release Notes (last 5):"
}
