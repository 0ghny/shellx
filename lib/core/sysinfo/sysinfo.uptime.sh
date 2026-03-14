# shellcheck shell=bash

#######################################
# Returns the system uptime as a human-readable string.
# Supports Linux, macOS, BSD, Solaris, AIX, IRIX, and Haiku.
# The output omits zero-valued fields (e.g. does not show "0 hours").
# Adaptation from neofetch (MIT License): https://github.com/dylanaraps/neofetch
# Globals:
#   (none - reads from OS-specific interfaces)
# Outputs:
#   Writes a string such as "3 days, 2 hours, 14 mins" to stdout.
#   Falls back to "<N> secs" for very short uptimes.
#######################################
sysinfo::uptime() {
  local _uptime
  # shellcheck disable=SC2155
  local _os=$(sysinfo::platform::os)
  # Get uptime in seconds.
  case $_os in
      Linux|Windows|MINIX)
          if [ -r /proc/uptime ]; then
              s=$(< /proc/uptime)
              s=${s/.*}
          else
              boot=$(date -d"$(uptime -s)" +%s)
              now=$(date +%s)
              s=$((now - boot))
          fi
      ;;

      Darwin|"Mac OS X"|"macOS"|"iPhone OS"|BSD|FreeMiNT)
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

          case "$t" in
            *-*) d="${t%%-*}"; t="${t#*-}" ;;
          esac
          case "$t" in
            *:*:*) h="${t%%:*}"; t="${t#*:}" ;;
          esac

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
