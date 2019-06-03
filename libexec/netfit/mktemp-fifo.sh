#! /usr/bin/env bash

fifo=$(mktemp -t "$@" --dry-run)
mkfifo $fifo
echo $fifo
