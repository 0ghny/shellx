# shellcheck shell=bash

# @description
# Include env functions to update shellx. It also include an auto-check
# feature which check for updates on shell session init.
# Since shellx SHOULD be installed using git, it will rely on git check
# commands to check for new versions.
# @configuration
#  SHELLX_PLUGIN_UPDATE_LOCK_FILE defines the file used to check if
#   a check for new version is required or not
#  SHELLX_AUTO_UPDATE variable if defined will execute
# auto-update feature, otherwise, has to be checked manually, either
# using git pull on SHELLX_HOME or using shellx-update function alias

SHELLX_PLUGIN_UPDATE_LOCK_FILE="${SHELLX_PLUGIN_UPDATE_LOCK_FILE:-/tmp/.shellx_update_check.lock}"

# @feature check
# @description Check if there's a new version of shellx available.
if [[ ! -f "${SHELLX_PLUGIN_UPDATE_LOCK_FILE}" ]]; then
  shellx::plugins::log_debug "UPDATER" "shellx version hasnt been checked yet, doing it now"
  if shellx::update::available; then
    echo "There's a new shellx version available."
  else
    shellx::plugins::log_debug "UPDATER" "you're running latest shellx version"
  fi
  shellx::plugins::log_debug "UPDATER" "creating shellx update check lock file at ${SHELLX_PLUGIN_UPDATE_LOCK_FILE}"
  touch "${SHELLX_PLUGIN_UPDATE_LOCK_FILE}"

  # @feature auto-update
  # @description Auto-update shellx if SHELLX_AUTO_UPDATE is set to YES
  if [[ -n "${SHELLX_AUTO_UPDATE}" ]] && \
    [[ "$(echo "${SHELLX_AUTO_UPDATE}" | tr '[:lower:]' '[:upper:]')" == "YES" ]]; then
    shellx::plugins::log_debug "UPDATER" "Auto update enabled, updating it now"
    shellx::update
  else
    shellx::plugins::log_debug "UPDATER" "Auto update disabled"
  fi
fi
