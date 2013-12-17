#!/bin/sh
DIRNAME=`readlink -f "$@"`
find "$DIRNAME" -type f |sort > /tmp/play.list
mplayer -playlist /tmp/play.list
