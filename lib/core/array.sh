array::from_index() {
  local -n _array=$1
  local -n _array_from=${2:-1}
  result=()

  if shell::is_bash && shell::running_bash_script; then
    result=(${_array[@:$_array_from:$#]})
  elif shell::is_zsh && shell::running_zsh_script; then
    result=("${_array[@]:$_array_from+1}")
  else
    result=($_array[@])
  fi
  echo "${result[@]}"
}

array::except_first() {
  if shell::is_bash && shell::running_bash_script; then
    echo "${@:2}"
  elif shell::is_zsh && shell::running_zsh_script; then
    echo "${@:2}"
  else
    echo "$@"
  fi
}
