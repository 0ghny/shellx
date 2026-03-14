# hack/dev.sh — Developer Task Runner

`hack/dev.sh` is the main developer automation script for the shellx project.
It provides a unified entry point for linting, formatting checks, and test execution.

## Usage

```bash
./hack/dev.sh [--coverage] <task>
```

If invoked without arguments and `fzf` is available, an interactive menu is shown to pick a task.

## Tasks

| Task               | Description                                              |
|--------------------|----------------------------------------------------------|
| `lint`             | Run shellcheck on all shell files under the project root |
| `fmt`              | Check formatting of `lib/**` and `shellx.sh` with shfmt  |
| `test-unit`        | Run the unit test suite                                  |
| `test-integration` | Run the integration test suite                           |
| `test`             | Run unit + integration suites                            |
| `all`              | Run lint + fmt + test sequentially                       |

## Coverage mode

By default, tests run in **fast mode** — bashunit is invoked directly with no extra overhead.

Coverage mode enables:
- HTML test report generation
- Code coverage analysis with a minimum threshold of 80%
- JUnit XML report output
- All reports are written to `target/<timestamp>/`

Coverage mode can be activated in two ways:

**Flag:**
```bash
./hack/dev.sh --coverage test
./hack/dev.sh --coverage test-unit
```

**Environment variable** (useful for CI pipelines):
```bash
SHELLX_TEST_COVERAGE=1 ./hack/dev.sh test
```

The `--coverage` flag and the `SHELLX_TEST_COVERAGE` environment variable are equivalent and can be combined freely.

## bashunit

The script requires [bashunit](https://bashunit.typeddevs.com) to run tests.
It is **downloaded automatically** on first use and cached at `target/bashunit`.
If the file is already present, no download is performed.

The pinned version is controlled by the `BASHUNIT_VERSION` variable at the top of the script.

```bash
BASHUNIT_VERSION="0.33.0"
```

To upgrade, update that variable and delete `target/bashunit` so it is re-downloaded on next run.

## Dependencies

| Tool         | Required for | Install                          |
|--------------|--------------|----------------------------------|
| `shellcheck` | `lint`       | `apt install shellcheck` / `brew install shellcheck` |
| `shfmt`      | `fmt`        | `go install mvdan.cc/sh/v3/cmd/shfmt@latest` / `brew install shfmt` |
| `curl`       | bashunit download | pre-installed on most systems |
| `fzf`        | interactive menu (optional) | `apt install fzf` / `brew install fzf` |

## Output artifacts

All artifacts produced under coverage mode are written to a timestamped directory:

```
target/
└── 20260313-142500/
    ├── unit.html
    ├── unit.xml
    ├── unit-coverage/
    ├── integration.html
    ├── integration.xml
    └── integration-coverage/
```

The `target/` directory is not tracked by git.
