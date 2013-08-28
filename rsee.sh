#!/bin/sh
find "$@" -type f |grep -iv jpg |grep -iv jpeg |rl > /tmp/play.list
mplayer -playlist /tmp/play.list
