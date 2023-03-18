shellx::tests::session_start() {
  shellx::tests::log "[setup] configure shellx variables for testing"
  SHELLX_HOME="$(git rev-parse --show-toplevel)"
  SHELLX_PLUGINS_D=/tmp/shellx-bats-tests
  SHELLX_CONFIG=${SHELLX_HOME}/tests/shellx_config_tests
  SHELLX_DEBUG=NO
  # Ensure directories exists
  rm -rf "${SHELLX_PLUGINS_D}"
  mkdir "${SHELLX_PLUGINS_D}"
  # Exporting variables so they exists on tests
  export SHELLX_HOME SHELLX_PLUGINS_D SHELLX_DEBUG SHELLX_CONFIG
  load "${SHELLX_HOME}/shellx.sh"
}

shellx::tests::session_end() {
  shellx::tests::log "[teardown] cleaning testing resources"
  rm -rf "${SHELLX_PLUGINS_D}"
}

shellx::tests::log() {
  if [[ -n "${SHELLX_TESTS_DEBUG}" ]]; then
    echo "$(date "+%Y/%m/%d %H:%M:%S") [DEBUG] ${*}" >&3
  fi
}

# Load a library from the `${BATS_TEST_DIRNAME}/test_helper' directory.
#
# Globals:
#   none
# Arguments:
#   $1 - name of library to load
# Returns:
#   0 - on success
#   1 - otherwise
load_lib() {
  local name="$1"
  load "test_helper/${name}/load"
}
