# shellcheck shell=bash
# Shellx CLI
# Allows users to use cli-friendly commands instead of invoke bash functions
# that are more cryptical.
# Example:
#  instead of -> shellx::plugins::update plugin_name
#  do this    -> shellx plugins update plugin_name
#
# The idea behind is to transform parameter 1 and 2 to function namespace
# and name and rest of parameters as parameter function
#  shellx::$1::$2 ${3:}
# It also support simple function invokation just in case only 1 parameter
# is passed like "reset"
#  shellx::$1 --> shellx reset
# shellcheck disable=SC2145,SC2294
shellx::cli::run() {
  # It requires a minimum of 1 argument
  if [[ $# -lt 1 ]]; then
    shellx::help
    return 1
  fi

  # help command
  if [[ "${1}" == "help" ]]; then
    shellx::help
    return 0
  fi

  # shellcheck disable=SC2068,SC2086
  # Single or complex commmand
  if [[ $# -gt 1 ]]; then
    # commands like shellx plugins installed
    shellx::log_debug "shellx::cli:run params_count->$# | parameters->$* | first_param->$1 | second_param->$2 | rest_params->${@:3}"
    shellx::log_debug "calling complex command-> shellx::$1::$2 ${@:3}"
    eval "shellx::$1::$2 ${@:3}"
  else
    # commands like shellx info or update
    shellx::log_debug "shellx::cli:run params_count->$# | parameters->$* | first_param->$1 | rest_params->${@:2}"
    shellx::log_debug "calling simple command-> shellx::$1 ${@:2}"
    eval "shellx::$1 ${@:2}"
  fi
}

# Simulate an application with a function
# this is required, because if shellx were a shell script
# when invoked from the terminal it will create a new
# process and shellx::functions sourced from current environment
# wont be available to the script.
# It will make that modifications or operations running commands
# from this cli won't impact the current environment shell.
# NOTE: I'm not using aliases because aliases are not allowed in scripts
# they're only allowed in interactive shell, so a function it's a better choice
shellx() {
  shellx::log_debug "shellx() params_count->$# | parameters->$*"
  shellx::cli::run "${@}"
}
