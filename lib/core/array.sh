array::except_first() {
  if shell::is_bash && shell::running_bash_script; then
    echo "${@:2}"
  elif shell::is_zsh && shell::running_zsh_script; then
    echo "${@:2}"
  else
    echo "$@"
  fi
}
