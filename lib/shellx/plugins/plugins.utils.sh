# shellcheck shell=bash

#######################################
# Returns the full filesystem path for a given plugin name.
# Globals:
#   __shellx_plugins_d - Base directory for user-installed plugins.
# Arguments:
#   $1 - Plugin directory name.
# Outputs:
#   Writes the full path to stdout.
#######################################
shellx::plugins::path() {
  # shellcheck disable=SC2154
  echo "${__shellx_plugins_d}/${1}"
}

#######################################
# Returns the base name (directory name) of a plugin from its full path.
# Arguments:
#   $1 - Full path to the plugin directory.
# Outputs:
#   Writes the basename to stdout.
#######################################
shellx::plugins::name() {
  basename "${1}"
}

#######################################
# Checks whether a plugin package is installed (directory exists).
# Arguments:
#   $1 - Plugin package name.
# Returns:
#   0 if installed, 1 otherwise.
#######################################
shellx::plugins::is_installed() {
  io::exists "$(shellx::plugins::path "${1}")"
}

#######################################
# Internal helper: prints the raw list of installed plugin package paths.
# Globals:
#   __shellx_plugins_locations - Array of plugin package locations.
# Outputs:
#   Writes space-separated plugin location paths to stdout.
#######################################
shellx::plugins::internal::list_intalled(){
  echo "${__shellx_plugins_locations[*]}"
}

#######################################
# Updates an installed plugin package by running git pull inside its directory.
# The plugin directory must be a git repository (installed via git clone).
# Arguments:
#   $1 - Plugin package name (directory name under __shellx_plugins_d).
# Globals:
#   __shellx_plugins_d - Base directory for user-installed plugins.
# Outputs:
#   Writes status messages to stdout; errors to stderr.
# Returns:
#   0 on success, 1 if the plugin is not found or is not a git repository.
#######################################
shellx::plugins::update() {
  local name="${1:-}"

  if [ -z "${name}" ]; then
    echo "Usage: shellx update <plugin-name>" >&2
    return 1
  fi

  # shellcheck disable=SC2154
  local plugin_dir="${__shellx_plugins_d}/${name}"

  if [ ! -d "${plugin_dir}" ]; then
    shellx::log_error "Plugin '${name}' is not installed (${plugin_dir} not found)"
    return 1
  fi

  if [ ! -d "${plugin_dir}/.git" ]; then
    shellx::log_error "Plugin '${name}' is not a git repository — cannot update"
    return 1
  fi

  echo -n "Updating plugin '${name}'...   "
  if git -C "${plugin_dir}" pull --ff-only >/dev/null 2>&1; then
    echo "done."
  else
    echo "error." >&2
    shellx::log_error "Failed to update plugin '${name}'. Check git status in ${plugin_dir}"
    return 1
  fi
}

#######################################
# Lists all currently loaded plugins in a tree view grouped by package.
# Reads from __shellx_plugins_loaded and renders a colored tree structure
# using box-drawing characters.
# Globals:
#   __shellx_plugins_loaded - Array of loaded plugin identifiers (@pkg/file.sh).
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
  # Use parameter expansion ${_plug%/*} to extract group — zero subshells
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
# Checks whether a plugin package is installed (directory exists).
# Arguments:
#   $1 - Plugin package name.
# Returns:
#   0 if installed, 1 otherwise.
#######################################
shellx::plugins::is_installed() {
  io::exists "$(shellx::plugins::path "${1}")"
}

#######################################
# Prints a list of all installed plugin packages with their paths.
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
# Internal helper: prints the raw list of installed plugin package paths.
# Globals:
#   __shellx_plugins_locations - Array of plugin package locations.
# Outputs:
#   Writes space-separated plugin location paths to stdout.
#######################################
shellx::plugins::internal::list_intalled(){
  echo "${__shellx_plugins_locations[*]}"
}

#######################################
# Lists available plugin packages from the registry file.
# Reads the plugins.repositories file and prints package names, URLs,
# and optional descriptions in a formatted table.
# Globals:
#   (resolved via shellx::plugins::config_file_path)
# Outputs:
#   Writes a formatted list of available packages to stdout.
# Returns:
#   0 on success, 1 if the registry file is not found.
#######################################
shellx::plugins::list() {
  local config_file
  
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
    name="${name%% }"
    name="${name## }"
    url="${url%% }"
    url="${url## }"
    description="${description%% }"
    description="${description## }"
    
    printf "  %-15s %s\n" "${name}:" "${url}"
    if [ -n "${description}" ]; then
      printf "                  └─ %s\n" "${description}"
    fi
  done < "${config_file}"
}

#######################################
# Updates an installed plugin package by running git pull inside its directory.
# The plugin directory must be a git repository (installed via git clone).
# Arguments:
#   $1 - Plugin package name (directory name under __shellx_plugins_d).
# Globals:
#   __shellx_plugins_d - Base directory for user-installed plugins.
# Outputs:
#   Writes status messages to stdout; errors to stderr.
# Returns:
#   0 on success, 1 if the plugin is not found or is not a git repository.
#######################################
shellx::plugins::update() {
  local name="${1:-}"

  if [ -z "${name}" ]; then
    echo "Usage: shellx update <plugin-name>" >&2
    return 1
  fi

  # shellcheck disable=SC2154
  local plugin_dir="${__shellx_plugins_d}/${name}"

  if [ ! -d "${plugin_dir}" ]; then
    shellx::log_error "Plugin '${name}' is not installed (${plugin_dir} not found)"
    return 1
  fi

  if [ ! -d "${plugin_dir}/.git" ]; then
    shellx::log_error "Plugin '${name}' is not a git repository — cannot update"
    return 1
  fi

  echo -n "Updating plugin '${name}'...   "
  if git -C "${plugin_dir}" pull --ff-only >/dev/null 2>&1; then
    echo "done."
  else
    echo "error." >&2
    shellx::log_error "Failed to update plugin '${name}'. Check git status in ${plugin_dir}"
    return 1
  fi
}
