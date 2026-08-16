#!/bin/sh
# SPDX-License-Identifier: MIT

set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 /path/to/gr4cp_server /path/to/cmake" >&2
  exit 2
fi

server="$1"
cmake_command="$2"
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ ! -x "$server" ]; then
  echo "gr4cp_server is not executable: $server" >&2
  exit 1
fi

if [ ! -x "$cmake_command" ]; then
  echo "cmake is not executable: $cmake_command" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
port_file="$tmpdir/port"
server_log="$tmpdir/server.log"
server_pid=""

cleanup() {
  if [ -n "$server_pid" ] && kill -0 "$server_pid" 2>/dev/null; then
    kill "$server_pid" 2>/dev/null || true
  fi
  if [ -n "$server_pid" ]; then
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

http_get() {
  "$cmake_command" \
    -DGR4_HTTP_URL="$1" \
    -DGR4_HTTP_OUTPUT="$2" \
    -P "$script_dir/http-get.cmake" >/dev/null 2>&1
}

GR4CP_PORT=0 GR4CP_PORT_FILE="$port_file" "$server" >"$server_log" 2>&1 &
server_pid=$!

port=""
attempt=0
while [ "$attempt" -lt 100 ]; do
  if [ -s "$port_file" ]; then
    port="$(tr -d '\r\n' <"$port_file")"
    if http_get "http://127.0.0.1:$port/healthz" "$tmpdir/health.json"; then
      break
    fi
  fi

  if ! kill -0 "$server_pid" 2>/dev/null; then
    cat "$server_log" >&2
    exit 1
  fi

  attempt=$((attempt + 1))
  sleep 0.1
done

if [ -z "$port" ] || [ ! -s "$tmpdir/health.json" ]; then
  echo "gr4cp_server did not become ready" >&2
  cat "$server_log" >&2
  exit 1
fi

grep -Fq '"ok":true' "$tmpdir/health.json"
http_get "http://127.0.0.1:$port/blocks" "$tmpdir/blocks.json"
grep -Fq '"id"' "$tmpdir/blocks.json"
