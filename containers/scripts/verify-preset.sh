#!/usr/bin/env bash
set -euo pipefail

preset="${1:-full}"
target="${GR4_BUILD_TARGET:-check}"

if [[ ! -f CMakePresets.json ]]; then
  echo "error: run this script from the gr4-super source root" >&2
  exit 2
fi

echo '=== platform ==='
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  printf '%s %s\n' "${PRETTY_NAME:-unknown distribution}" "${VERSION_ID:-}"
fi
uname -a

echo '=== toolchain ==='
cmake --version | head -n 1
ninja --version
git --version
gcc --version | head -n 1
g++ --version | head -n 1
python3 --version
node --version
npm --version

echo '=== selected system packages ==='
if command -v dpkg-query >/dev/null; then
  dpkg-query -W -f='${binary:Package}=${Version}\n' \
    build-essential cmake g++ libcpp-httplib-dev libtbb-dev nodejs \
    python3-dev python3-numpy 2>/dev/null || true
fi

echo "=== configure: ${preset} ==="
cmake --preset "${preset}"

echo "=== build target ${target}: ${preset} ==="
cmake --build --preset "${preset}" --target "${target}"
