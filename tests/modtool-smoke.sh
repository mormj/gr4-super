#!/bin/sh
# SPDX-License-Identifier: MIT

set -eu

if [ "$#" -ne 4 ]; then
  echo "usage: $0 activate.sh work-dir install-prefix cmake" >&2
  exit 2
fi

activate_script=$1
work_dir=$2
install_prefix=$3
cmake_command=$4

. "$activate_script"
gr4_modtool newmod \
  --project-dir "$work_dir" \
  --name modtool_smoke \
  --first-group basic \
  --yes

"$cmake_command" \
  -S "$work_dir/modtool_smoke" \
  -B "$work_dir/build" \
  "-DCMAKE_PREFIX_PATH:PATH=$install_prefix"
"$cmake_command" --build "$work_dir/build"
