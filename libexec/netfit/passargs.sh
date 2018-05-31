#!/usr/bin/env bash

set -e
set -u

read line
eval "$@ $line"
