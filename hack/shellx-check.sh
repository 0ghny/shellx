#!/bin/bash

this=$(git rev-parse --show-toplevel)

# Check shellx bootstrap
SHELLX_DEBUG=yes /usr/bin/bash --noprofile --norc -e -o pipefail "${this}/shellx.sh"
# Check shellx_update default plugin
SHELLX_DEBUG=yes /usr/bin/bash --noprofile --norc -e -o pipefail "${this}/plugins/shellx_update.sh"
