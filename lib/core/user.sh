# shellcheck shell=bash

user::current() {
  echo "${USER:-$(id -un || printf %s "${HOME/*\/}")}"
}
