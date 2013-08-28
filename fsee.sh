#!/bin/sh
find "$@" -type f |sort > /tmp/play.list
mplayer -playlist /tmp/play.list
