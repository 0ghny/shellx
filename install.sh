#!/usr/bin/env bash
# install.sh — ShellX installer
#
# Usage:
#   ./install.sh [--version <tag>]
#
# Or via curl:
#   curl -fsSL https://raw.githubusercontent.com/0ghny/shellx/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/0ghny/shellx/main/install.sh | bash -s -- --version v2.0.0

set -euo pipefail

SHELLX_INSTALL_DIR="${SHELLX_INSTALL_DIR:-${HOME}/.shellx}"
SHELLX_REPO="https://github.com/0ghny/shellx.git"
SHELLX_VERSION=""

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
_parse_args() {
  local _next_is_version=0
  for _arg in "$@"; do
    if [ "${_next_is_version}" -eq 1 ]; then
      SHELLX_VERSION="${_arg}"
      _next_is_version=0
      continue
    fi
    case "${_arg}" in
      --version=*) SHELLX_VERSION="${_arg#*=}" ;;
      --version)   _next_is_version=1 ;;
      *)
        echo "ERROR: Unknown option: ${_arg}" >&2
        echo "Usage: install.sh [--version <tag>]" >&2
        exit 1
        ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# Post-install instructions
# -----------------------------------------------------------------------------
_print_post_install() {
  echo ""
  echo "┌─────────────────────────────────────────────────────────────"
  echo "│  ShellX installed successfully at ${SHELLX_INSTALL_DIR}"
  echo "│"
  echo "│  Add the following lines to your shell configuration file"
  echo "│  and restart your shell (or run: exec \$SHELL)."
  echo "│"

  if command -v bash &>/dev/null; then
    echo "│  ── Bash  (~/.bashrc) ──────────────────────────────────────"
    echo "│  [[ -f ~/.shellx/shellx.sh ]] && source ~/.shellx/shellx.sh"
    echo "│"
  fi

  if command -v zsh &>/dev/null; then
    echo "│  ── Zsh  (~/.zshrc) ────────────────────────────────────────"
    echo "│  [[ -f ~/.shellx/shellx.sh ]] && source ~/.shellx/shellx.sh"
    echo "│"
  fi

  if command -v fish &>/dev/null; then
    echo "│  ── Fish  (~/.config/fish/config.fish) ─────────────────────"
    echo "│  set -gx SHELLX_HOME ~/.shellx"
    echo "│  source ~/.shellx/shellx.fish"
    echo "│"
  fi

  if ! command -v bash &>/dev/null && ! command -v zsh &>/dev/null && ! command -v fish &>/dev/null; then
    echo "│  No supported shell (bash/zsh/fish) was detected."
    echo "│  Manually source ~/.shellx/shellx.sh in your shell config."
    echo "│"
  fi

  echo "└─────────────────────────────────────────────────────────────"
  echo ""
}

# -----------------------------------------------------------------------------
# Handle an existing installation
# -----------------------------------------------------------------------------
_handle_existing() {
  echo "ShellX is already installed at ${SHELLX_INSTALL_DIR}."
  echo ""
  echo "  [r] Remove existing installation and reinstall"
  echo "  [u] Update (discard local changes and pull latest)"
  echo "  [c] Cancel"
  echo ""
  printf "Your choice [r/u/c]: "
  read -r _choice

  case "${_choice}" in
    r | R)
      echo "==> Removing existing installation..."
      rm -rf "${SHELLX_INSTALL_DIR}"
      echo "==> Done. Proceeding with a fresh install."
      ;;
    u | U)
      echo "==> Fetching latest changes..."
      git -C "${SHELLX_INSTALL_DIR}" fetch origin
      echo "==> Discarding local changes and updating..."
      git -C "${SHELLX_INSTALL_DIR}" reset --hard FETCH_HEAD
      echo "==> ShellX updated successfully."
      _print_post_install
      exit 0
      ;;
    *)
      echo "==> Installation cancelled."
      exit 0
      ;;
  esac
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
_parse_args "$@"

if [ -d "${SHELLX_INSTALL_DIR}" ]; then
  _handle_existing
fi

echo "==> Installing ShellX into ${SHELLX_INSTALL_DIR}..."

if [ -n "${SHELLX_VERSION}" ]; then
  echo "==> Using version: ${SHELLX_VERSION}"
  git clone --branch "${SHELLX_VERSION}" --depth 1 "${SHELLX_REPO}" "${SHELLX_INSTALL_DIR}"
else
  git clone "${SHELLX_REPO}" "${SHELLX_INSTALL_DIR}"
fi

_print_post_install
