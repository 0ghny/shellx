# shellcheck shell=bash
sysinfo::arch_native() {
  if env::is_defined "MACHTYPE"; then
    echo "${MACHTYPE}"
  else
    echo" $(uname -m)"
  fi
}

sysinfo::arch(){
  local _arch=""
  case "$(sysinfo::arch_native)" in
    *i386*)   _arch="386" ;;
    *i686*)   _arch="386" ;;
    *x86_64*) _arch="amd64" ;;
    *arm*)    dpkg --print-architecture | grep -q "arm64" && _arch="arm64" || _arch="arm" ;;
    *) _arch="Unknown" ;;
  esac
  echo "${_arch}"
}

sysinfo::platform_native(){
  if env::is_defined "OSTYPE"; then
    echo "${OSTYPE}"
  else
    echo Unknown
  fi
}

sysinfo::platform(){
  local _platform=""
  case $(sysinfo::platform_native) in
    *linux*) _platform="linux" ;;
    *darwin*) _platform="darwin" ;;
    *) _platform="Unknown" ;;
  esac
  echo "${_platform}"
}

# Returns mac instead of darwin as example
sysinfo::platform_colloquial_name(){
  local _platform=""
  case $(sysinfo::platform_native) in
    *linux*) _platform="linux" ;;
    *darwin*) _platform="mac" ;;
    *win*) _platform="win" ;;
    *) _platform="Unknown" ;;
  esac
  echo "${_platform}"
}

sysinfo::os_name() {
  local _os
  case $(sysinfo::kernel_name) in
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

sysinfo::connected_users() {
  local _users="$(who | awk '!seen[$1]++ {printf $1 ", "}')"
  _users="${_users%\,*}"
  echo "${_users}"
}

sysinfo::hostname() {
  echo "${HOSTNAME:-$(hostname)}"
}

sysinfo::kernel_name() {
  uname -s
}
sysinfo::kernel_version() {
  uname -r
}
sysinfo::kernel_machine() {
  uname -m
}
sysinfo::kernel() {
  echo "$(sysinfo::kernel_name) $(sysinfo_kernel_version)"
}

# Adaptation from (MIT License): https://github.com/dylanaraps/neofetch
sysinfo::uptime() {
  local _uptime
  local _os=$(sysinfo::os_name)
  # Get uptime in seconds.
  case $_os in
      Linux|Windows|MINIX)
          if [[ -r /proc/uptime ]]; then
              s=$(< /proc/uptime)
              s=${s/.*}
          else
              boot=$(date -d"$(uptime -s)" +%s)
              now=$(date +%s)
              s=$((now - boot))
          fi
      ;;

      "Mac OS X"|"macOS"|"iPhone OS"|BSD|FreeMiNT)
          boot=$(sysctl -n kern.boottime)
          boot=${boot/\{ sec = }
          boot=${boot/,*}

          # Get current date in seconds.
          now=$(date +%s)
          s=$((now - boot))
      ;;

      Solaris)
          s=$(kstat -p unix:0:system_misc:snaptime | awk '{print $2}')
          s=${s/.*}
      ;;

      AIX|IRIX)
          t=$(LC_ALL=POSIX ps -o etime= -p 1)

          [[ $t == *-*   ]] && { d=${t%%-*}; t=${t#*-}; }
          [[ $t == *:*:* ]] && { h=${t%%:*}; t=${t#*:}; }

          h=${h#0}
          t=${t#0}

          s=$((${d:-0}*86400 + ${h:-0}*3600 + ${t%%:*}*60 + ${t#*:}))
      ;;

      Haiku)
          s=$(($(system_time) / 1000000))
      ;;
  esac

  d="$((s / 60 / 60 / 24)) days"
  h="$((s / 60 / 60 % 24)) hours"
  m="$((s / 60 % 60)) mins"

  # Remove plural if < 2.
  ((${d/ *} == 1)) && d=${d/s}
  ((${h/ *} == 1)) && h=${h/s}
  ((${m/ *} == 1)) && m=${m/s}

  # Hide empty fields.
  ((${d/ *} == 0)) && unset d
  ((${h/ *} == 0)) && unset h
  ((${m/ *} == 0)) && unset m

  _uptime=${d:+$d, }${h:+$h, }$m
  _uptime=${_uptime%', '}
  _uptime=${_uptime:-$s secs}

  echo "${_uptime}"
}
