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
@test "info should returns shellx session information" {
  # Arrange
  # Act
  run shellx info
  
  # Assert
  assert_success
  assert_output --partial "Session information:"
  assert_output --partial "Plugins:"
  assert_output --regexp  'Applied\sfilter:\s\@shellx'
  assert_output --partial 'Packages:'
  assert_output --partial "[*] [@shellx] ${SHELLX_HOME}"
  assert_output --partial 'Loaded:'
  assert_output --partial '[*] @shellx/shellx_update.sh'
  assert_output --partial '[*] @shellx/wellcome.sh'
}
