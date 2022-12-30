#!/bin/bash

set -eu

repo_root() {
  git rev-parse --show-toplevel
}

needs_lint() {
  [[ $1 == *.sh ]] && return 0
  [[ $1 == *.bash ]] && return 0
  [[ $1 == */bash-completion/* ]] && return 0
  [[ $(file -b --mime-type "$1") == text/x-shellscript ]] && return 0
  return 1
}

while IFS= read -r -d $'' file; do
  if needs_lint "$file"; then
    shellcheck -W0 -s bash "$file" || continue
  fi
done < <(find "$(repo_root)" -type f  -not -path '*/\.git/*' -not -path '*/plugin-examples/*' -print0)
