#!/usr/bin/env sh
jack -Q --remove-files --rename-fmt "%a - %l %n - %t" -b 192 -e 2 -E lame "$@"
