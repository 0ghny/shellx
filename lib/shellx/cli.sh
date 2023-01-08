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

shellx::cli::usage() {
  echo "Usage: shellx [COMMAND] [ARGS]...
Executes a shellx functionality.
Below you'll find the list of available commands and options

  MANAGE SESSION
  -----------------------------------------------------------------------------
  shellx reset                            Resets current shell session
                                          it does a $SHELL reset or exec $SHELL
  shellx info                             Print Shell,OS and Host information
                                          current session info
                                          (start time, load time, plugins, etc)

  MANAGE VERSION
  -----------------------------------------------------------------------------
  shellx version                          Prints current shellx version
  shellx version info                     Prints a nice message with
                                          version and release notes
  shellx update                           Updates (if newer) shellx version
                                          is available to latest release
  shellx check                            Checks if a new version is available
                                          and print new changes
  shellx update available                 Checks if a new version is available
                                          useful for scripting (returns 1 in
                                          case of no new version) so you can
                                          > shellx check && shellx update

  TOOLS
  -----------------------------------------------------------------------------
  shellx debug enabled                    Enabled shellx debug output to stdout
  shellx debug disabled                   Disable shellx debug output to stdout
  shellx config reload                    Reloads shellxrc file into session


  MANAGE PLUGINS
  -----------------------------------------------------------------------------
  shellx plugins install <git-url>        Installs a plugins package from
                                          git repo url
  shellx plugins installed                List installed plugin packages
  shellx plugins uninstall <plugin_name>  Uninstall specified plugins package
  shellx plugins reload                   Reloads plugins into current session
  shellx plugins loaded                   List of loaded plugins in current
                                          current session

  RESOURCES
  -----------------------------------------------------------------------------
  GitHub: https://github.com/0ghny/shellx
  Docs:   https://0ghny.github.io/shellx
  "
}

shellx::cli::run() {
  # It requires a minimum of 1 argument
  if [[ $# -lt 1 ]]; then
    shellx::cli::usage
    return 1
  fi

  # help command
  if [[ "${1}" == "help" ]]; then
    shellx::cli::usage
    return 0
  fi

  # shellcheck disable=SC2068,SC2086
  # Single or complex commmand
  if [[ $# -gt 1 ]]; then
    # commands like shellx plugins installed
    shellx::log_debug "calling -> shellx::$1::$2 ${*:3}"
    eval "shellx::$1::$2 ${*:3}"
  else
    # commands like shellx info or update
    shellx::log_debug "calling -> shellx::$1 ${*:2}"
    eval "shellx::$1 ${*:2}"
  fi
}

# Simulate an application with an alias
# this is required, because if shellx were a shell script
# when invoked from the terminal it will create a new
# process and shellx::functions sourced from current environment
# wont be available to the script.
# It will make that modifications or operations running commands
# from this cli won't impact the current environment shell.
alias shellx='shellx::cli::run'
