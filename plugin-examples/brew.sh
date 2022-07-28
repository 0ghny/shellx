# .............................................................................
# if brew is available, include brew sbin into the path
# osx brew hack
# .............................................................................
command -v brew >/dev/null && return
# Settings
export PATH="/usr/local/sbin:$PATH"
