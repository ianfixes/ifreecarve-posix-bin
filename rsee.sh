#!/bin/sh
DIRNAME=`readlink -f "$@"`
find "$DIRNAME" -type f |grep -iv jpg |grep -iv jpeg |rl > /tmp/play.list
mplayer -playlist /tmp/play.list
