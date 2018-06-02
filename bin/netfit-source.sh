#!/usr/bin/env bash

resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

NETFIT_ROOT="$(dirname $(abs_dirname "$0"))"
NETFIT_LIBEXEC="$NETFIT_ROOT"/libexec/netfit
export PATH="$NETFIT_LIBEXEC:$PATH"

if [ "$1" == "location" ]
then
  echo "$NETFIT_ROOT"
fi
