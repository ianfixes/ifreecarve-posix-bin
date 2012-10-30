#!/bin/sh

# streamrecord_mplayer.sh
#  record a video stream to disk
# by Ian Katz, 2008
# ifreecarve@gmail.com
# released under the WTFPL

#usage: streamrecord_mplayer.sh <stream url> <output file> [mplayer arg #1] [mplayer arg #2] 

mplayer -dumpfile "$2" -dumpstream "$1" "$3" "$4"
