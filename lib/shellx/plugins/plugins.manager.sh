# shellcheck shell=bash

#######################################
# Checks whether the given string looks like a URL.
# Recognized schemes: http://, https://, git@, file://
# Arguments:
#   $1 - String to test.
# Returns:
#   0 if the string appears to be a URL, 1 otherwise.
#######################################
shellx::plugins::is_url() {
  local input="${1}"
  
  # Check if it looks like a URL
  if [[ "${input}" =~ ^(https?://|git@|file://) ]]; then
    return 0
  fi
  
  return 1
}

#######################################
# Resolves the path to the plugins registry (repositories) file.
# Search priority:
#   1. $SHELLX_PLUGINS_REGISTRY environment variable
#   2. ~/.config/shellx/plugins.repositories (user config)
#   3. $__shellx_homedir/plugins.repositories (repo root)
#   4. $__shellx_libdir/shellx/plugins.repositories (bundled fallback)
# Globals:
#   SHELLX_PLUGINS_REGISTRY - Optional override path.
#   SHELLX_CONFIG_DIR        - Optional base directory (default: .config/shellx).
#   __shellx_homedir         - ShellX install directory.
#   __shellx_libdir          - ShellX lib directory.
# Outputs:
#   Writes the resolved registry file path to stdout.
#######################################
shellx::plugins::config_file_path() {
  # Check environment variable first
  if [ -n "${SHELLX_PLUGINS_REGISTRY}" ] && [ -r "${SHELLX_PLUGINS_REGISTRY}" ]; then
    echo "${SHELLX_PLUGINS_REGISTRY}"
    return 0
  fi
  
  local config_dir="${SHELLX_CONFIG_DIR:-.config/shellx}"
  
  # Check user config
  if [ -r "${HOME}/${config_dir}/plugins.repositories" ]; then
    echo "${HOME}/${config_dir}/plugins.repositories"
    return 0
  fi
  
  # Check repository root
  # shellcheck disable=SC2154
  if [ -r "${__shellx_homedir}/plugins.repositories" ]; then
    echo "${__shellx_homedir}/plugins.repositories"
    return 0
  fi
  
  # Use bundled plugins.repositories (backwards compatibility)
  echo "${__shellx_libdir}/shellx/plugins.repositories"
}

#######################################
# Looks up and returns the clone URL for a package by name from the registry.
# Arguments:
#   $1 - Package name to look up.
# Outputs:
#   Writes the URL to stdout if found.
# Returns:
#   0 if found, 1 if not found or registry is unavailable.
#######################################
shellx::plugins::get_url() {
  local pkg_name="${1}"
  local config_file
  
  config_file=$(shellx::plugins::config_file_path)
  
  if [ ! -r "${config_file}" ]; then
    shellx::log_error "Plugins configuration file not found: ${config_file}"
    return 1
  fi
  
  # Parse repositories: NAME|URL|DESCRIPTION
  while IFS='|' read -r name url description || [ -n "$name" ]; do
    # Skip comments and empty lines
    [[ "${name}" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${name}" ]] && continue
    
    # Trim whitespace
    name="${name%% }"
    name="${name## }"
    
    if [ "${name}" = "${pkg_name}" ]; then
      echo "${url}"
      return 0
    fi
  done < "${config_file}"
  
  return 1
}

#######################################
# Returns true if a plugin package name is registered in the registry.
# Arguments:
#   $1 - Package name to check.
# Returns:
#   0 if it exists in the registry, 1 otherwise.
#######################################
shellx::plugins::exists() {
  local pkg_name="${1}"
  shellx::plugins::get_url "${pkg_name}" > /dev/null 2>&1
}

#######################################
# Resolves a package name or URL to a clone URL.
# If the input is already a URL it is returned unchanged.
# If the input is a known package name it is looked up in the registry.
# Arguments:
#   $1 - Package name (from registry) or direct URL.
# Outputs:
#   Writes the resolved URL to stdout.
# Returns:
#   0 on success, 1 if the input is neither a URL nor a known package.
#######################################
shellx::plugins::manager::resolve_url() {
  local input="${1}"
  
  # If it's a URL already, return it
  if shellx::plugins::is_url "${input}"; then
    echo "${input}"
    return 0
  fi
  
  # Try to resolve as package name from repositories
  if shellx::plugins::exists "${input}"; then
    shellx::plugins::get_url "${input}"
    return 0
  fi
  
  # Not found in repositories and not a URL
  return 1
}

#######################################
# Installs a plugin package by cloning its git repository.
# Accepts either a registered package name or a direct git URL.
# After a successful clone, saves the entry to the manifest and reloads plugins.
# Arguments:
#   $1 - Package name from the registry, or a direct repository URL.
#   $2 - (Optional) Git ref (branch, tag, or commit) to check out.
# Returns:
#   0 on success, 1 if already installed, invalid input, or clone fails.
#######################################
# shellcheck disable=SC2154
shellx::plugins::install() {
  local input="${1}"
  local ref="${2:-}"
  local plugin_url
  local plugin_name

  # Validate input
  if [ -z "${input}" ]; then
    echo "[PLUGIN] Usage: shellx::plugins::install <package-name|url> [ref]"
    echo "[PLUGIN] Available packages: $(shellx::plugins::list | tr '\n' ' ')"
    return 1
  fi

  # Resolve package name to URL or use direct URL
  if plugin_url=$(shellx::plugins::manager::resolve_url "${input}"); then
    plugin_name=$(basename "${plugin_url}" .git)
  else
    echo "[PLUGIN] Package '${input}' not found in repositories and not a valid URL"
    echo "[PLUGIN] Available packages: $(shellx::plugins::list | tr '\n' ' ')"
    return 1
  fi

  # check if it's already installed
  if [ -d "${__shellx_plugins_d}/${plugin_name}" ]; then
    echo "[PLUGIN] ${plugin_name} is already installed!"
    return 1 # Return failure to indicate it's already installed
  fi

  # Build clone arguments, adding --branch only when a ref is specified
  local clone_args=( "${plugin_url}" "${__shellx_plugins_d}/${plugin_name}" )
  if [ -n "${ref}" ]; then
    clone_args=( --branch "${ref}" "${plugin_url}" "${__shellx_plugins_d}/${plugin_name}" )
  fi

  echo -n "[PLUGIN] Installing ${plugin_name} from ${plugin_url}..."
  git clone "${clone_args[@]}" 2>/dev/null 1>&2 \
    && {
      echo -e " ${_color_green}OK${_color_reset}"

      shellx::plugins::manifest::save "${plugin_url}" "${ref}"
      echo "[PLUGIN] Reloading plugins..."
      shellx::plugins::reload
    } || (echo -e " ${_color_red}KO${_color_reset}"; return 1)
}

#######################################
# Uninstalls a plugin package by removing its directory from plugins.d.
# Triggers a directory reload after successful removal.
# Arguments:
#   $1 - Plugin package name to uninstall.
# Returns:
#   0 on success, 1 if the plugin is not installed or removal fails.
#######################################
shellx::plugins::uninstall() {
  local plugin_name="${1}"

  if ! shellx::plugins::is_installed "${plugin_name}"; then
    echo "[PLUGIN] ${plugin_name} not installed"
  else
    echo -n "[PLUGIN] ${plugin_name} uninstalling..."
    rm -rfv "$(shellx::plugins::path "${plugin_name}")" \
      2>/dev/null 1>&2 \
    && {
      echo -e " ${_color_green}OK${_color_reset}"
      shellx::plugins::manifest::remove "${plugin_name}"
      shellx::plugins::internal::dir_reload
    } || echo -e " ${_color_red}KO${_color_reset}"
  fi
}

#######################################
# Updates one or all installed plugin packages via 'git pull'.
# If a plugin name is given, only that plugin is updated.
# If no argument is given, all known plugin locations are updated.
# Reloads all plugins after a successful update.
# Arguments:
#   $1 - (Optional) Plugin package name. Omit to update all.
# Returns:
#   0 on success per plugin; logs warnings for missing plugins.
#######################################
# shellcheck disable=SC2206
shellx::plugins::update() {
  local plugin_name="${1}"
  local list_to_update
  local plugin_location

  # Calculate list of plugins to update
  if [ -n "${plugin_name}" ]; then
    shellx::log_debug "specified plugin to update ${plugin_name}"
    list_to_update=( "$(shellx::plugins::path "${plugin_name}")" )
    shellx::log_debug "list of plugins locations to update ${list_to_update[*]}"
  else
    list_to_update=( ${__shellx_plugins_locations[*]} )
  fi

  for plugin_location in "${list_to_update[@]}"; do
    if io::exists "${plugin_location}" && io::exists "${plugin_location}/.git"; then
      echo -n "[+] Updating $(shellx::plugins::name "${plugin_location}")..."
      echo git -C "${plugin_location}" pull 2>/dev/null 1>&2 \
    && {
      echo -e " ${_color_green}OK${_color_reset}"

      shellx::log_debug "Reloading plugins..."
      shellx::plugins::reload
    } || echo -e " ${_color_red}KO${_color_reset}"
    else
      echo -n "[-] Plugin $(shellx::plugins::name "${plugin_location}") ${_color_red}NOT INSTALLED${_color_reset}"
      shellx::log_warn \
        "Plugin $(shellx::plugins::name "${plugin_location}") not installed, skipping"
    fi
    unset plugin_location
  done
}
#######################################
# Adds a new plugin repository entry to the user's registry file.
# Creates the registry file (copying the bundled one) if it does not exist.
# Arguments:
#   $1 - Repository name (identifier).
#   $2 - Repository clone URL.
#   $3 - (Optional) Human-readable description.
# Returns:
#   0 on success, 1 if name or URL is missing.
#######################################
shellx::plugins::add() {
  local pkg_name="${1}"
  local pkg_url="${2}"
  local description="${3:-}"
  local config_file
  
  shellx::log_debug "Adding repository with name '${pkg_name}' and url '${pkg_url}'"
  # Validate inputs
  if [ -z "${pkg_name}" ] || [ -z "${pkg_url}" ]; then
    shellx::log_error "Usage: shellx::plugins::add <name> <url> [description]"
    return 1
  fi
  
  config_file="${HOME}/.config/shellx/plugins.repositories"
  
  # Create directory if it doesn't exist
  if [ ! -d "${HOME}/.config/shellx" ]; then
    mkdir -p "${HOME}/.config/shellx"
  fi
  
  # Copy default repositories if user config doesn't exist
  if [ ! -f "${config_file}" ]; then
    cp "${__shellx_libdir}/shellx/plugins.repositories" "${config_file}"
  fi
  
  # Add new repository
  echo "${pkg_name}|${pkg_url}|${description}" >> "${config_file}"
  shellx::log_info "Repository '${pkg_name}' added successfully at ${config_file}"
}
