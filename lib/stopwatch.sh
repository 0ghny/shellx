# shellcheck shell=bash

stopwatch::capture() {
  date +%s
}

# param (1): start time
# param (2): end time
stopwatch::elapsed() {
  local __start="$1"
  local __end="$2"
  echo "$(( __end - __start ))"
}
