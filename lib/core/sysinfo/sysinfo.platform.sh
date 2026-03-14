# shellcheck shell=bash

#######################################
# Returns the raw platform identifier from the environment.
# Prefers the OSTYPE shell variable when available.
# Globals:
#   OSTYPE - Used when defined (set by bash/zsh).
# Outputs:
#   Writes the native platform string (e.g. "darwin23.0", "linux-gnu") to stdout.
#   Returns "Unknown" if OSTYPE is not defined.
#######################################
sysinfo::platform::native() {
  if env::is_defined "OSTYPE"; then
    echo "${OSTYPE}"
  else
    echo "Unknown"
  fi
}

#######################################
# Returns a normalized platform name.
# Maps native OSTYPE values to canonical names:
#   *linux*  -> linux
#   *darwin* -> darwin
# Outputs:
#   Writes the normalized platform name to stdout.
#   Returns "Unknown" for unrecognized platforms.
#######################################
sysinfo::platform::name() {
  local _platform=""
  case $(sysinfo::platform::native) in
    *linux*) _platform="linux" ;;
    *darwin*) _platform="darwin" ;;
    *) _platform="Unknown" ;;
  esac
  echo "${_platform}"
}

#######################################
# Returns a colloquial (user-friendly) short name for the current platform.
# Maps OSTYPE values to short names:
#   *linux*  -> linux
#   *darwin* -> mac
#   *win*    -> win
# Outputs:
#   Writes the short platform name to stdout.
#   Returns "Unknown" for unrecognized platforms.
#######################################
sysinfo::platform::short() {
  local _platform=""
  case $(sysinfo::platform::native) in
    *linux*) _platform="linux" ;;
    *darwin*) _platform="mac" ;;
    *win*) _platform="win" ;;
    *) _platform="Unknown" ;;
  esac
  echo "${_platform}"
}

#######################################
# Returns a normalized OS name derived from the kernel name.
# Maps kernel names to human-friendly OS labels:
#   Darwin           -> Darwin
#   Linux / GNU*     -> Linux
#   *BSD / DragonFly -> BSD
#   CYGWIN* / MSYS*  -> Windows
#   (others)         -> their own name, or Unknown
# Outputs:
#   Writes the OS name string to stdout.
#######################################
sysinfo::platform::os() {
  local _os
  case $(sysinfo::kernel::name) in
    Darwin)   _os=Darwin ;;
    SunOS)    _os=Solaris ;;
    Haiku)    _os=Haiku ;;
    MINIX)    _os=MINIX ;;
    AIX)      _os=AIX ;;
    IRIX*)    _os=IRIX ;;
    FreeMiNT) _os=FreeMiNT ;;
    Linux|GNU*) _os=Linux ;;
    *BSD|DragonFly|Bitrig) _os=BSD ;;
    CYGWIN*|MSYS*|MINGW*) _os=Windows ;;
    *) _os=Unknown ;;
  esac

  echo "${_os}"
}
