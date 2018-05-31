#!/usr/bin/env bash

#    Copyright (C) 2018  hrobeers
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e
set -u

DIR=$( dirname "${BASH_SOURCE[0]}" )
host=${HOST:-"localhost"}
port=${PORT:-9833}

args="$@"

set -o pipefail
cat <(echo "$args") - | socat - tcp:$host:$port | "$DIR"/demux
