# shellcheck shell=bash
os::get_platform(){
  local _platform=""
  case $(os::get_platform_Native) in
      *linux*) _platform="linux" ;;
      *darwin*) _platform="darwin" ;;
      *) _platform="Unknown" ;;
  esac
  echo "${_platform}"
}