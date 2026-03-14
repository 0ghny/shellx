# shellcheck shell=bash

#######################################
# Returns the kernel name (e.g. "Linux", "Darwin").
# Outputs:
#   Writes the kernel name to stdout (result of 'uname -s').
#######################################
sysinfo::kernel::name() {
  uname -s
}

#######################################
# Returns the kernel release version string.
# Outputs:
#   Writes the kernel version to stdout (result of 'uname -r').
#######################################
sysinfo::kernel::version() {
  uname -r
}

#######################################
# Returns the kernel hardware machine type.
# Outputs:
#   Writes the machine type to stdout (result of 'uname -m').
#######################################
sysinfo::kernel::machine() {
  uname -m
}

#######################################
# Returns a combined kernel name and version string.
# Outputs:
#   Writes "<kernel_name> <kernel_version>" to stdout.
#######################################
sysinfo::kernel::full() {
  echo "$(sysinfo::kernel::name) $(sysinfo::kernel::version)"
}
