# shellcheck shell=bash

#######################################
# Returns the raw machine architecture string from the environment or 'uname -m'.
# Prefers the MACHTYPE shell variable when available.
# Globals:
#   MACHTYPE - Used when defined (set by bash).
# Outputs:
#   Writes the native architecture string (e.g. "x86_64", "arm64") to stdout.
#######################################
sysinfo::arch::native() {
  if env::is_defined "MACHTYPE"; then
    echo "${MACHTYPE}"
  else
    echo "$(uname -m)"
  fi
}

#######################################
# Returns a normalized architecture identifier.
# Maps native architecture strings to canonical values:
#   i386/i686  -> 386
#   x86_64     -> amd64
#   arm64      -> arm64
#   arm*       -> arm
# Outputs:
#   Writes the normalized architecture name to stdout (e.g. "amd64", "arm64").
#   Returns "Unknown" for unrecognized architectures.
#######################################
sysinfo::arch::name() {
  local _arch=""
  case "$(sysinfo::arch::native)" in
    *i386*)   _arch="386" ;;
    *i686*)   _arch="386" ;;
    *x86_64*) _arch="amd64" ;;
    *arm*)    dpkg --print-architecture | grep -q "arm64" && _arch="arm64" || _arch="arm" ;;
    *) _arch="Unknown" ;;
  esac
  echo "${_arch}"
}
