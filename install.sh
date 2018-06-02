#!/usr/bin/env bash
set -e

DIR=$( dirname "${BASH_SOURCE[0]}" )
source "$DIR/bin/netfit-source.sh"

PREFIX="$1"
if [ -z "$1" ]; then
  { echo "usage: $0 <prefix>"
    echo "  e.g. $0 /usr/local"
  } >&2
  exit 1
fi

NETFIT_ROOT="$(abs_dirname "$0")"
mkdir -p "$PREFIX"/{bin,libexec,share/man/man1}
cp -R "$NETFIT_ROOT"/bin/netfit-* "$PREFIX"/bin
cp -R "$NETFIT_ROOT"/libexec/netfit/ "$PREFIX"/libexec
# TODO write man page (e.g. generate from README)
#cp "$NETFIT_ROOT"/man/netfit.1 "$PREFIX"/share/man/man1

echo "Installed netfit to $PREFIX/bin/"
