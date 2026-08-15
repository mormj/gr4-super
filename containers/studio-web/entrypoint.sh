#!/bin/sh
set -eu

# Keep the control plane private to the container. nginx is the public
# same-origin endpoint and exposes both the Studio application and /api.
export GR4CP_PORT=8081

gr4cp_server &
backend_pid=$!
nginx_pid=''

cleanup() {
  if [ -n "$nginx_pid" ] && kill -0 "$nginx_pid" >/dev/null 2>&1; then
    kill "$nginx_pid" >/dev/null 2>&1 || true
    wait "$nginx_pid" >/dev/null 2>&1 || true
  fi
  if kill -0 "$backend_pid" >/dev/null 2>&1; then
    kill "$backend_pid" >/dev/null 2>&1 || true
    wait "$backend_pid" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT INT TERM

attempt=0
while ! curl --fail --silent --output /dev/null http://127.0.0.1:8081/healthz; do
  if ! kill -0 "$backend_pid" >/dev/null 2>&1; then
    wait "$backend_pid" || true
    echo "gr4cp_server exited before becoming ready" >&2
    exit 1
  fi

  attempt=$((attempt + 1))
  if [ "$attempt" -ge 30 ]; then
    echo "gr4cp_server did not become ready within 30 seconds" >&2
    exit 1
  fi
  sleep 1
done

nginx -g 'daemon off;' &
nginx_pid=$!
wait "$nginx_pid"
