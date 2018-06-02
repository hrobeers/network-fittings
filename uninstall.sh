#!/usr/bin/env bash
set -e

NETFIT_ROOT="$(netfit-source.sh location)"
rm "$NETFIT_ROOT"/bin/netfit-*
rm -r "$NETFIT_ROOT"/libexec/netfit/

echo "Uninstalled netfit from $NETFIT_ROOT/bin/"
