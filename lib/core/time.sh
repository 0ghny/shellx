# shellcheck shell=bash

#######################################
# Captures the current Unix timestamp in seconds.
# Intended to be used with time::elapsed to measure elapsed time.
# Outputs:
#   Writes the current epoch timestamp (seconds) to stdout.
#######################################
time::capture() {
  date +%s
}

#######################################
# Calculates the elapsed time in seconds between two timestamps.
# Arguments:
#   $1 - Start timestamp (Unix epoch seconds, from time::capture).
#   $2 - End timestamp (Unix epoch seconds, from time::capture).
# Outputs:
#   Writes the difference in seconds to stdout.
#######################################
time::elapsed() {
  local __start="$1"
  local __end="$2"
  echo "$(( __end - __start ))"
}

#######################################
# Converts a duration in seconds to a human-readable HH hr MM min SS sec string.
# Pure POSIX arithmetic — no dependency on the 'date' command.
# Arguments:
#   $1 - Duration in seconds (default: 0).
# Outputs:
#   Writes a formatted string like "01 hr 02 min 03 sec" to stdout.
# Example:
#   start=$(time::capture)
#   sleep 5
#   end=$(time::capture)
#   elapsed=$(time::elapsed "$start" "$end")
#   time::to_human_readable "$elapsed"  # -> "00 hr 00 min 05 sec"
#######################################
time::to_human_readable() {
    local __input="${1:-0}"

    # Pure POSIX calculation - convert seconds to HH hr MM min SS sec format
    # No dependency on 'date' command or OS-specific parameters
    local hours=$((${__input} / 3600))
    local minutes=$(((${__input} % 3600) / 60))
    local seconds=$((${__input} % 60))

    printf "%02d hr %02d min %02d sec\n" "$hours" "$minutes" "$seconds"
}
