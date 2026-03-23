# shellcheck shell=bash
# ShellX CLI adapter for the 'plugins' command.
# Contains both the display/presentation functions (loaded, installed, list)
# and the subcommand dispatcher shellx::cli::plugins.
# Pure logic lives in lib/shellx/plugins/.

# =============================================================================
# Display functions
# =============================================================================

#######################################
# Lists all currently loaded plugins in a tree view grouped by package.
# Globals:
#   __shellx_plugins_loaded - Array of loaded plugin identifiers (@pkg/file.sh).
#   __shellx_plugins_d      - Base directory for user-installed plugins.
#   _color_*                - Color variables from lib/core/colors.sh.
# Outputs:
#   Writes formatted plugin tree to stdout.
#######################################
shellx::plugins::loaded() {
  # Declare all locals at top to avoid Bash/Zsh scoping differences in loops
  local _plug _group _g _plugin _parent _child_prefix _group_prefix _plugin_prefix
  local _found _total_groups _group_count _pcount _ppos _plugin_count
  local _pkg_dir _ref _ref_label
  local -a _groups _group_plugins

  _plugin_count=${#__shellx_plugins_loaded[@]}

  echo ""
  echo -e "${_color_bold_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_color_reset}"
  echo -e "${_color_bold_blue}  📦 ShellX Loaded Plugins${_color_reset}"
  echo -e "${_color_bold_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_color_reset}"

  if [ "${_plugin_count}" -eq 0 ]; then
    echo -e "  ${_color_yellow}No plugins loaded${_color_reset}"
    echo ""
    return
  fi

  # First pass: collect unique parent groups preserving order
  _groups=()
  for _plug in "${__shellx_plugins_loaded[@]}"; do
    _parent="${_plug%/*}"
    _found=0
    for _g in "${_groups[@]+"${_groups[@]}"}"; do
      [ "$_g" = "$_parent" ] && _found=1 && break
    done
    [ "$_found" -eq 0 ] && _groups+=("$_parent")
  done

  _total_groups=${#_groups[@]}
  _group_count=0

  # Second pass: for each group, print header then its plugins
  for _group in "${_groups[@]}"; do
    _group_count=$((_group_count + 1))

    if [ "$_group_count" -eq "$_total_groups" ]; then
      _group_prefix="└──"; _child_prefix="    "
    else
      _group_prefix="├──"; _child_prefix="│   "
    fi

    # Resolve git ref for this package (@name → strip @ → look up in plugins_d)
    # shellcheck disable=SC2154
    _pkg_dir="${__shellx_plugins_d}/${_group#@}"
    _ref_label=""
    if [ -d "${_pkg_dir}/.git" ]; then
      _ref=$(git -C "${_pkg_dir}" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "${_pkg_dir}" describe --tags --exact-match HEAD 2>/dev/null \
             || git -C "${_pkg_dir}" rev-parse --short HEAD 2>/dev/null \
             || true)
      [ -n "${_ref}" ] && _ref_label=" ${_color_yellow}(${_ref})${_color_reset}"
    fi

    echo -e "  ${_color_green}${_group_prefix}${_color_reset} ${_color_bold_white}${_group}${_color_reset}${_ref_label}"

    _group_plugins=()
    for _plug in "${__shellx_plugins_loaded[@]}"; do
      _parent="${_plug%/*}"
      [ "$_parent" = "$_group" ] && _group_plugins+=("$_plug")
    done

    _pcount=${#_group_plugins[@]}
    _ppos=0
    for _plugin in "${_group_plugins[@]}"; do
      _ppos=$((_ppos + 1))
      [ "$_ppos" -eq "$_pcount" ] && _plugin_prefix="└──" || _plugin_prefix="├──"
      echo -e "  ${_child_prefix}${_color_green}${_plugin_prefix}${_color_reset} ${_color_bold_white}${_plugin}${_color_reset}"
    done
  done

  echo -e "${_color_bold_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_color_reset}"
  echo -e "  ${_color_bold_yellow}Total: ${_plugin_count} plugin${_plugin_count:+s}${_color_reset}"
  echo ""
}

#######################################
# Prints a list of all installed plugin packages with their paths and git ref.
# Globals:
#   __shellx_plugins_locations - Array of known plugin package paths.
#   _color_*                   - Color variables from lib/core/colors.sh.
# Outputs:
#   Writes formatted plugin package tree to stdout.
#######################################
shellx::plugins::installed() {
  local _pkg _total _count _prefix _ref _ref_label

  # shellcheck disable=SC2154
  _total=${#__shellx_plugins_locations[@]}

  echo ""
  echo -e "${_color_bold_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_color_reset}"
  echo -e "${_color_bold_blue}  📂 ShellX Installed Plugin Packages${_color_reset}"
  echo -e "${_color_bold_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_color_reset}"

  if [ "${_total}" -eq 0 ]; then
    echo -e "  ${_color_yellow}No plugin packages installed${_color_reset}"
    echo ""
    return
  fi

  _count=0
  for _pkg in "${__shellx_plugins_locations[@]+"${__shellx_plugins_locations[@]}"}"; do
    _count=$((_count + 1))
    [ "${_count}" -eq "${_total}" ] && _prefix="└──" || _prefix="├──"

    # Resolve current git ref: branch → tag → short commit
    if [ -d "${_pkg}/.git" ]; then
      _ref=$(git -C "${_pkg}" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "${_pkg}" describe --tags --exact-match HEAD 2>/dev/null \
             || git -C "${_pkg}" rev-parse --short HEAD 2>/dev/null \
             || true)
    else
      _ref=""
    fi

    [ -n "${_ref}" ] && _ref_label=" ${_color_yellow}(${_ref})${_color_reset}" || _ref_label=""

    echo -e "  ${_color_green}${_prefix}${_color_reset} ${_color_bold_white}$(basename "${_pkg}")${_color_reset}${_ref_label}  ${_color_cyan}${_pkg}${_color_reset}"
  done

  echo -e "${_color_bold_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_color_reset}"
  echo -e "  ${_color_bold_yellow}Total: ${_total} package${_total:+s}${_color_reset}"
  echo ""
}

#######################################
# Lists available plugin packages from the registry file.
# Globals:
#   (resolved via shellx::plugins::config_file_path)
# Outputs:
#   Writes a formatted list of available packages to stdout.
# Returns:
#   0 on success, 1 if the registry file is not found.
#######################################
shellx::plugins::list() {
  local config_file _pkg_path _ref _ref_label

  config_file=$(shellx::plugins::config_file_path)

  if [ ! -r "${config_file}" ]; then
    shellx::log_error "Plugins configuration file not found: ${config_file}"
    return 1
  fi

  echo "Available Plugin Packages:"
  echo ""

  while IFS='|' read -r name url description || [ -n "$name" ]; do
    # Skip comments and empty lines
    [[ "${name}" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${name}" ]] && continue

    # Trim whitespace
    name="${name#"${name%%[![:space:]]*}"}"
    name="${name%"${name##*[![:space:]]}"}"
    url="${url#"${url%%[![:space:]]*}"}"
    url="${url%"${url##*[![:space:]]}"}"
    description="${description#"${description%%[![:space:]]*}"}"
    description="${description%"${description##*[![:space:]]}"}"

    # Show installed ref when the package is already cloned
    _pkg_path="$(shellx::plugins::path "$(basename "${url}" .git)")"
    _ref_label=""
    if [ -d "${_pkg_path}/.git" ]; then
      _ref=$(git -C "${_pkg_path}" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "${_pkg_path}" describe --tags --exact-match HEAD 2>/dev/null \
             || git -C "${_pkg_path}" rev-parse --short HEAD 2>/dev/null \
             || true)
      [ -n "${_ref}" ] && _ref_label=" (${_ref})"
    fi

    printf "  %-15s %s%s\n" "${name}:" "${url}" "${_ref_label}"
    if [ -n "${description}" ]; then
      printf "                  └─ %s\n" "${description}"
    fi
  done < "${config_file}"
}

# =============================================================================
# CLI dispatcher
# =============================================================================

#######################################
# CLI dispatcher for the 'plugins' command.
# Arguments:
#   list                      - List available plugin packages
#   installed                 - List installed plugin packages
#   install <name|url> [ref]  - Install a plugin by package name or URL, with optional git ref
#   uninstall <name>          - Uninstall a plugin package
#   update <name>             - Update an installed plugin package (git pull)
#   export                    - Print a manifest of installed plugins to stdout
#   sync                      - Install all plugins listed in the manifest file
#   reload                    - Reload plugins into current session
# Returns:
#   0 on success, 1 on unknown subcommand or error.
#######################################
shellx::cli::plugins() {
  local subcommand="${1:-}"

  case "${subcommand}" in
    list)
      shellx::plugins::list
      ;;
    installed)
      shellx::plugins::installed
      ;;
    install)
      shift
      shellx::plugins::install "$@"
      ;;
    uninstall)
      shift
      shellx::plugins::uninstall "$@"
      ;;
    update)
      shift
      shellx::plugins::update "$@"
      ;;
    export)
      shellx::plugins::export
      ;;
    sync)
      shellx::plugins::sync
      ;;
    reload)
      shellx::plugins::reload
      ;;
    *)
      echo "Usage: shellx plugins <subcommand> [args]" >&2
      echo "" >&2
      echo "Subcommands:" >&2
      echo "  list                      List available plugin packages" >&2
      echo "  installed                 List installed plugin packages" >&2
      echo "  install <name|url> [ref]  Install a plugin by package name or URL" >&2
      echo "  uninstall <name>          Uninstall a plugin package" >&2
      echo "  update <name>             Update an installed plugin (git pull)" >&2
      echo "  export                    Print manifest of installed plugins to stdout" >&2
      echo "  sync                      Install all plugins from the manifest file" >&2
      echo "  reload                    Reload plugins into current session" >&2
      return 1
      ;;
  esac
}
