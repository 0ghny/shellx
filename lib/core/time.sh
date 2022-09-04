# shellcheck shell=bash

# from elapsed to human readable
# @usage_example
# start=$(stopwatch::capture)
# sleep 5
# end=start=$(stopwatch::capture)
# elapsed=$(stopwatch::elapsed "$start" "$end")
# echo Elapsed time: $(time::to_human_readable "$elapsed")
time::to_human_readable() {
    local __input="$1"

    # Make it compatible with POSIX and Non-POSIX date implementations
    if [[ "${OSTYPE}" == "linux"* ]]; then
      eval "echo $(date -ud "@$__input" +'%H hr %M min %S sec')"
    elif [[ "${OSTYPE}" == "darwin"* ]]; then
      eval "echo $(date -u -r "$__input" +'%H hr %M min %S sec')"
    fi
}
