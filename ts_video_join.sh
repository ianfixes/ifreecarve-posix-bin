#!/bin/sh

usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd <output file> <input file 1> [[input file 2] ...]"
     echo
     echo "Combines a set of input .ts video files to an ouput file (.mp4 extension added)"
}

# test if we have an arguments on the command line
if [ $# -lt 2 ]
then
    usage
    exit
fi

TMP=`tempfile || echo ts_video_join.tmp`
OUT=$1

shift

set -x

cat "$@" > $TMP
#mplayer $TMP
ffmpeg -i $TMP -acodec copy -vcodec copy "$OUT.mp4"
rm $TMP
