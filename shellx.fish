# shellx.fish — Fish Shell support for ShellX
#
# Add to ~/.config/fish/config.fish:
#
#   set -gx SHELLX_HOME /path/to/.shellx
#   source $SHELLX_HOME/shellx.fish
#
# Full plugin environment propagation requires bass:
#   https://github.com/edc/bass
#
# Without bass, PATH setup and the 'shellx' CLI are still available.

# ---------------------------------------------------------------------------
# SHELLX_HOME — resolve from file location if not already set
# ---------------------------------------------------------------------------
if not set -q SHELLX_HOME
    set -gx SHELLX_HOME (dirname (status --current-filename))
end

# ---------------------------------------------------------------------------
# PATH — add ShellX bin and common user bin directories
# ---------------------------------------------------------------------------
for _sx_path in "$SHELLX_HOME/bin" "$HOME/bin" "$HOME/.local/bin"
    if test -d "$_sx_path"
        fish_add_path --global --prepend "$_sx_path"
    end
end
set -e _sx_path

# ---------------------------------------------------------------------------
# shellx — CLI command wrapper (delegates to bash subprocess)
#
# All ShellX CLI commands (version, info, plugins, config, debug, ...) are
# available via this wrapper.  The session environment of the bash child does
# NOT propagate back to Fish — for that, use bass (see below).
# ---------------------------------------------------------------------------
function shellx --description "ShellX framework CLI"
    SHELLX_HOME=$SHELLX_HOME SHELLX_NO_BANNER=1 bash -c '
        source "$SHELLX_HOME/shellx.sh" >/dev/null 2>&1
        shellx "$@"
    ' -- $argv
end

# ---------------------------------------------------------------------------
# Full environment bootstrap
#
# When bass is installed it sources shellx.sh through a bash subprocess and
# replays all exported variable changes back into the Fish session.  This
# makes plugin-exported environment variables (e.g. GOPATH, JAVA_HOME …)
# visible to the running Fish session — exactly as they are in Bash/Zsh.
#
# If bass is not installed only the above PATH additions and the 'shellx'
# function are available.  Set SHELLX_FISH_QUIET=1 to silence the notice.
# ---------------------------------------------------------------------------
if type -q bass
    bass source "$SHELLX_HOME/shellx.sh"
else
    if not set -q SHELLX_FISH_QUIET
        echo "shellx: Fish running in basic mode (install bass for full env support)" >&2
        echo "shellx:   https://github.com/edc/bass" >&2
    end
end
