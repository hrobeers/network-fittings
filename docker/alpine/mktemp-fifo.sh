#! /usr/bin/env bash

# Patch for busybox mktemp
# busybox mktemp does not support --dry-run

fifo=$(mktemp "$@")
rm $fifo
mkfifo $fifo
echo $fifo
