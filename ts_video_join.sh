#!/bin/sh

TMP=`tempfile`
OUT=$1

shift

set -x

cat "$@" > $TMP
#mplayer $TMP
ffmpeg -i $TMP -acodec copy -vcodec copy $OUT.mp4
rm $TMP
