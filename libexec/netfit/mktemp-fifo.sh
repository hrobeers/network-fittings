#! /usr/bin/env bash

fifo=$(mktemp "$@" --dry-run)
mkfifo $fifo
echo $fifo
