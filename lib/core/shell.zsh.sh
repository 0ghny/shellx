# shellcheck shell=bash
shell::is_zsh() {
  [[ -n "${ZSH_VERSION}" ]]
}

shell::running_zsh_script() {
  [[ -n "${funcfiletrace}" ]]
}

shell::zsh::array_first_index() {
  return 1
}
