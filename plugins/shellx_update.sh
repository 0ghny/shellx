#!/bin/bash

# @description
# Include env functions to update shellx. It also include an auto-check
# feature which check for updates on shell session init.
# Since shellx SHOULD be installed using git, it will rely on git check
# commands to check for new versions.
# @configuration
#  SHELLX_AUTO_UPDATE variable if defined will execute
# auto-update feature, otherwise, has to be checked manually, either
# using git pull on SHELLX_HOME or using shellx-update function alias

# .............................................................................
#                                                        [FEATURE: AUTO-UPDATE]
# .............................................................................
[[ -n "$SHELLX_AUTO_UPDATE" ]] && shellx update
