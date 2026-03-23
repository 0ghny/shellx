#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
BASHUNIT="${ROOT}/target/bashunit"
BASHUNIT_VERSION="0.33.0"
WITH_COVERAGE=0

# -----------------------------------------------------------------------------
# Coverage configuration — edit these to tune thresholds and scope
# -----------------------------------------------------------------------------
COVERAGE_MIN_UNIT=80
COVERAGE_MIN_INTEGRATION=70

COVERAGE_PATHS_UNIT=("lib/core" "lib/git" "lib/shellx")
COVERAGE_EXCLUDES_UNIT=("lib/shellx/cli" "lib/shellx/plugins" "lib/core/sysinfo")
COVERAGE_PATHS_INTEGRATION=("shellx.sh" "lib/shellx")
COVERAGE_EXCLUDES_INTEGRATION=("lib/git" "lib/core")

__ensure_bashunit() {
  if [ ! -f "${BASHUNIT}" ]; then
    echo "==> bashunit not found, downloading..."
    mkdir -p "$(dirname "${BASHUNIT}")"
    curl -fsSL "https://github.com/TypedDevs/bashunit/releases/download/${BASHUNIT_VERSION}/bashunit" \
      -o "${BASHUNIT}"
    chmod +x "${BASHUNIT}"
    echo "==> bashunit downloaded to ${BASHUNIT}"
  fi
}

# -----------------------------------------------------------------------------
# Lint: shellcheck all shell files, excluding .git, plugin-examples, tests
# -----------------------------------------------------------------------------
__run_lint() {
  # Verify shellcheck is available
  if ! command -v shellcheck &>/dev/null; then
    echo "ERROR: shellcheck is not installed." >&2
    echo "" >&2
    echo "  Install it with one of:" >&2
    echo "    macOS:   brew install shellcheck" >&2
    echo "    Debian:  apt-get install shellcheck" >&2
    echo "    Fedora:  dnf install ShellCheck" >&2
    echo "    Arch:    pacman -S shellcheck" >&2
    echo "    Manual:  https://github.com/koalaman/shellcheck#installing" >&2
    return 1
  fi

  # Shellcheck options
  local sc_opts=(-W0)
  local excludes=('.git' 'plugin-examples' 'tests')

  # Collect files first so we can print the summary before linting
  local -a files_to_lint=()
  while IFS= read -r -d '' file; do
    local needs_lint=0
    case "${file}" in
      *.sh|*.bash) needs_lint=1 ;;
    esac
    if [ "${needs_lint}" -eq 0 ]; then
      case "$(file -b --mime-type "${file}" 2>/dev/null)" in
        text/x-shellscript) needs_lint=1 ;;
      esac
    fi
    [ "${needs_lint}" -eq 1 ] && files_to_lint+=("${file}")
  done < <(find "${ROOT}" -type f \
    -not -path '*/.git/*' \
    -not -path '*/plugin-examples/*' \
    -not -path '*/target/*' \
    -not -path '*/tests/*' \
    -print0)

  # Summary header
  echo "┌─────────────────────────────────────────────────────────────"
  echo "│  Lint summary"
  echo "│"
  printf "│  %-20s %s\n" "Tool:"    "shellcheck $(shellcheck --version | awk '/^version:/{print $2}')"
  printf "│  %-20s %s\n" "Options:" "${sc_opts[*]}"
  printf "│  %-20s %s\n" "Root:"    "${ROOT}"
  printf "│  %-20s %s\n" "Excluded:" "${excludes[*]}"
  printf "│  %-20s %d file(s)\n" "Files to lint:" "${#files_to_lint[@]}"
  echo "│"
  for f in "${files_to_lint[@]}"; do
    printf "│    %s\n" "${f#"${ROOT}"/}"
  done
  echo "└─────────────────────────────────────────────────────────────"
  echo ""

  local failed=0
  for file in "${files_to_lint[@]}"; do
    if ! shellcheck "${sc_opts[@]}" "${file}"; then
      failed=$((failed + 1))
    fi
  done

  echo ""
  if [ "${failed}" -gt 0 ]; then
    echo "==> Lint FAILED: ${failed}/${#files_to_lint[@]} file(s) with issues."
    return 1
  else
    echo "==> Lint PASSED: ${#files_to_lint[@]} file(s) checked, no issues found."
  fi
}

# -----------------------------------------------------------------------------
# Tests: internal helper — runs one suite
# Arguments: suite (unit|integration)  [report_dir — only used with --coverage]
# -----------------------------------------------------------------------------
__run_test_suite() {
  local suite="${1}"        # unit | integration
  local report_dir="${2:-}"
  local suite_dir="${ROOT}/tests/${suite}"

  local -a suite_files=()
  while IFS= read -r -d '' f; do suite_files+=("${f}"); done \
    < <(find "${suite_dir}" -type f -name '*.bash' -print0)

  local bashunit_version
  bashunit_version="$("${BASHUNIT}" --version 2>/dev/null | head -1 || echo "unknown")"

  echo "┌─────────────────────────────────────────────────────────────"
  printf "│  Test suite: %s\n" "${suite}"
  echo "│"
  printf "│  %-24s %s\n" "Tool:" "${bashunit_version}"
  printf "│  %-24s %s\n" "Coverage:" "$([ "${WITH_COVERAGE}" -eq 1 ] && echo enabled || echo disabled)"
  local _cov_min="" coverage_paths="" coverage_exclude=""
  if [ "${WITH_COVERAGE}" -eq 1 ]; then
    local -a _paths=() _excludes=() _abs_paths=()
    local _p
    if [ "${suite}" = "integration" ]; then
      _cov_min=${COVERAGE_MIN_INTEGRATION}
      _paths=("${COVERAGE_PATHS_INTEGRATION[@]}")
      [ "${#COVERAGE_EXCLUDES_INTEGRATION[@]}" -gt 0 ] && \
        _excludes=("${COVERAGE_EXCLUDES_INTEGRATION[@]}")
    else
      _cov_min=${COVERAGE_MIN_UNIT}
      _paths=("${COVERAGE_PATHS_UNIT[@]}")
      [ "${#COVERAGE_EXCLUDES_UNIT[@]}" -gt 0 ] && \
        _excludes=("${COVERAGE_EXCLUDES_UNIT[@]}")
    fi
    for _p in "${_paths[@]}"; do _abs_paths+=("${ROOT}/${_p}"); done
    coverage_paths="$(IFS=, ; echo "${_abs_paths[*]}")"
    [ "${#_excludes[@]}" -gt 0 ] && coverage_exclude="$(IFS=, ; echo "${_excludes[*]}")"
    unset _paths _excludes _abs_paths _p
    printf "│  %-24s %s\n" "Coverage paths:"   "${coverage_paths}"
    printf "│  %-24s %s\n" "Coverage exclude:"  "${coverage_exclude:-(none)}"
    printf "│  %-24s %s\n" "Coverage min:"      "${_cov_min}%"
    printf "│  %-24s %s\n" "Report dir:"        "${report_dir}"
    printf "│  %-24s %s\n" "Report HTML:"       "${suite}.html"
    printf "│  %-24s %s\n" "Coverage HTML:"     "${suite}-coverage/"
  fi
  printf "│  %-24s %d file(s)\n" "Test files:" "${#suite_files[@]}"
  echo "│"
  for f in "${suite_files[@]}"; do
    printf "│    %s\n" "${f#"${ROOT}"/}"
  done
  echo "└─────────────────────────────────────────────────────────────"
  echo ""

  local -a extra_opts=()
  if [ "${WITH_COVERAGE}" -eq 1 ]; then
    mkdir -p "${report_dir}"
    extra_opts=(
      --report-html "${report_dir}/${suite}.html"
      --coverage
      --coverage-report-html "${report_dir}/${suite}-coverage/"
      --coverage-paths "${coverage_paths}"
      --coverage-min "${_cov_min}"
      --no-coverage-report
      --no-output-on-failure
      --show-skipped
      --log-junit "${report_dir}/${suite}.xml"
    )
    [ -n "${coverage_exclude}" ] && extra_opts+=(--coverage-exclude "${coverage_exclude}")
  fi

  "${BASHUNIT}" "${extra_opts[@]+"${extra_opts[@]}"}" "${suite_dir}"
}

# -----------------------------------------------------------------------------
# Tests: unit only
# -----------------------------------------------------------------------------
__run_tests_unit() {
  local report_dir="${ROOT}/target/$(date +%Y%m%d-%H%M%S)"
  __run_test_suite unit "${report_dir}"
  echo ""
  [ "${WITH_COVERAGE}" -eq 1 ] && echo "==> Test reports: ${report_dir}"
}

# -----------------------------------------------------------------------------
# Tests: integration only
# -----------------------------------------------------------------------------
__run_tests_integration() {
  local report_dir="${ROOT}/target/$(date +%Y%m%d-%H%M%S)"
  __run_test_suite integration "${report_dir}"
  echo ""
  [ "${WITH_COVERAGE}" -eq 1 ] && echo "==> Test reports: ${report_dir}"
}

# -----------------------------------------------------------------------------
# Tests: unit + integration
# -----------------------------------------------------------------------------
__run_tests() {
  local report_dir="${ROOT}/target/$(date +%Y%m%d-%H%M%S)"
  local exit_code=0

  __run_test_suite unit        "${report_dir}" || exit_code=$?
  echo ""
  __run_test_suite integration "${report_dir}" || exit_code=$?
  echo ""
  [ "${WITH_COVERAGE}" -eq 1 ] && echo "==> Test reports: ${report_dir}"
  return "${exit_code}"
}

# -----------------------------------------------------------------------------
# Fmt: shfmt format check on lib/** and shellx.sh
# -----------------------------------------------------------------------------
__run_fmt() {
  if ! command -v shfmt &>/dev/null; then
    echo "ERROR: shfmt is not installed." >&2
    echo "" >&2
    echo "  Install it with one of:" >&2
    echo "    macOS:   brew install shfmt" >&2
    echo "    Go:      go install mvdan.cc/sh/v3/cmd/shfmt@latest" >&2
    echo "    Manual:  https://github.com/mvdan/sh#installation" >&2
    return 1
  fi

  # shfmt options: indent with 2 spaces, binary-next-line, keep padding
  local shfmt_opts=(-i 2 -bn -sr -ln bash)

  # Collect target files
  local -a files_to_fmt=()
  while IFS= read -r -d '' file; do
    files_to_fmt+=("${file}")
  done < <(find "${ROOT}/lib" -type f \( -name '*.sh' -o -name '*.bash' \) -print0)
  files_to_fmt+=("${ROOT}/shellx.sh")

  # Summary header
  echo "┌─────────────────────────────────────────────────────────────"
  echo "│  Format check summary"
  echo "│"
  printf "│  %-20s %s\n" "Tool:"    "shfmt $(shfmt --version)"
  printf "│  %-20s %s\n" "Options:" "${shfmt_opts[*]}"
  printf "│  %-20s %s\n" "Paths:"   "lib/** shellx.sh"
  printf "│  %-20s %d file(s)\n" "Files to check:" "${#files_to_fmt[@]}"
  echo "│"
  for f in "${files_to_fmt[@]}"; do
    printf "│    %s\n" "${f#"${ROOT}"/}"
  done
  echo "└─────────────────────────────────────────────────────────────"
  echo ""

  local failed=0
  for file in "${files_to_fmt[@]}"; do
    if ! shfmt -d "${shfmt_opts[@]}" "${file}"; then
      failed=$((failed + 1))
    fi
  done

  echo ""
  if [ "${failed}" -gt 0 ]; then
    echo "==> Fmt FAILED: ${failed}/${#files_to_fmt[@]} file(s) not properly formatted."
    echo "    Run: shfmt ${shfmt_opts[*]} -w <file>  to auto-fix."
    return 1
  else
    echo "==> Fmt PASSED: ${#files_to_fmt[@]} file(s) are correctly formatted."
  fi
}

# -----------------------------------------------------------------------------
# Test Actions: run GitHub Actions CI jobs locally using act
# Usage: test-actions [JOB]   — omit JOB to run all ubuntu-compatible jobs
# Requires: act (https://github.com/nektos/act)
# NOTE: macos-latest runners are not supported by act; only ubuntu jobs run.
# -----------------------------------------------------------------------------
__run_test_actions() {
  local job="${1:-}"

  if ! command -v act &>/dev/null; then
    echo "ERROR: 'act' is not installed." >&2
    echo "" >&2
    echo "  Install it with one of:" >&2
    echo "    macOS:  brew install act" >&2
    echo "    Linux:  curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash" >&2
    echo "    Manual: https://github.com/nektos/act" >&2
    return 1
  fi

  # Jobs that can run locally (ubuntu-based only — act cannot emulate macos runners)
  local -a ubuntu_jobs=(
    lint
    fmt
    unit
    integration
    "e2e-bash"
    "e2e-zsh"
    "e2e-fish"
  )

  echo "┌─────────────────────────────────────────────────────────────"
  echo "│  GitHub Actions — local run via act"
  echo "│"
  printf "│  %-20s %s\n" "act version:" "$(act --version 2>/dev/null || echo unknown)"
  printf "│  %-20s %s\n" "Workflow:" ".github/workflows/ci.yml"
  printf "│  %-20s %s\n" "Event:" "pull_request"
  if [ -n "${job}" ]; then
    printf "│  %-20s %s\n" "Job filter:" "${job}"
  else
    printf "│  %-20s %s\n" "Jobs (ubuntu):" "${ubuntu_jobs[*]}"
    printf "│  %-20s %s\n" "Skipped:" "macos-latest runners (not supported by act)"
  fi
  echo "└─────────────────────────────────────────────────────────────"
  echo ""

  local act_opts=(
    pull_request
    --workflows "${ROOT}/.github/workflows/ci.yml"
    --directory "${ROOT}"
    # --action-offline-mode
  )

  # On Apple Silicon (arm64) force amd64 emulation to avoid container issues
  if [[ "$(uname -m)" == "arm64" ]]; then
    act_opts+=(--container-architecture linux/amd64)
  fi

  if [ -n "${job}" ]; then
    act "${act_opts[@]}" --job "${job}"
  else
    local exit_code=0
    for j in "${ubuntu_jobs[@]}"; do
      echo "==> Running job: ${j}"
      act "${act_opts[@]}" --job "${j}" || exit_code=$?
      echo ""
    done
    return "${exit_code}"
  fi
}

# -----------------------------------------------------------------------------
# All: lint + fmt + tests
# -----------------------------------------------------------------------------
__run_all() {
  local exit_code=0
  __run_lint  || exit_code=$?
  echo ""
  __run_fmt   || exit_code=$?
  echo ""
  __run_tests || exit_code=$?
  return "${exit_code}"
}

# -----------------------------------------------------------------------------
# Dispatch
# -----------------------------------------------------------------------------
__run_task() {
  local task="${1}"
  case "${task}" in
    lint)             __run_lint              ;;
    fmt)              __run_fmt               ;;
    test-unit)        __run_tests_unit        ;;
    test-integration) __run_tests_integration ;;
    test)             __run_tests             ;;
    test-actions)     __run_test_actions "${2:-}" ;;
    all)              __run_all               ;;
    *)
      echo "Unknown task: ${task}" >&2
      echo "Usage: $(basename "$0") lint|fmt|test-unit|test-integration|test|test-actions [JOB]|all" >&2
      exit 1
      ;;
  esac
}

__ensure_bashunit

# Enable coverage via env var or --coverage flag
[ -n "${SHELLX_TEST_COVERAGE:-}" ] && WITH_COVERAGE=1

# Parse --coverage flag from arguments
_args=()
for _arg in "$@"; do
  if [ "${_arg}" = "--coverage" ]; then
    WITH_COVERAGE=1
  else
    _args+=("${_arg}")
  fi
done
set -- "${_args[@]+"${_args[@]}"}" 

if [ -z "${1:-}" ]; then
  if ! command -v fzf &>/dev/null; then
    echo "fzf not found. Usage: $(basename "$0") [--coverage] lint|fmt|test-unit|test-integration|test|test-actions [JOB]|all" >&2
    exit 1
  fi
  selected=$(printf 'lint\nfmt\ntest-unit\ntest-integration\ntest\ntest-actions\nall\n' \
    | fzf --prompt="Select task > " --height=6 --border --ansi)
  [ -z "${selected}" ] && exit 0
  __run_task "${selected}"
else
  __run_task "$@"
fi
