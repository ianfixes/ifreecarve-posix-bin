#!/bin/bash

# pipe-mplayer.sh
#  Uses mplayer to convert a video (especially streaming video) to data on STDOUT
# by Ian Katz, 2009
# ifreecarve@gmail.com
# released under the WTFPL

if [ -n "`ls /tmp/ikmplayer-pipe.* 2>/dev/null`" ]; then
    rm /tmp/ikmplayer-pipe.*
fi
PIPE="/tmp/ikmplayer-pipe.$$"
#mknod $PIPE p
mkfifo $PIPE

mencoder "$@" -really-quiet -oac copy -ovc copy -o $PIPE  2>/dev/null | cat $PIPE 2>/dev/null
#mencoder "$@" -nosound -really-quiet -ovc copy -o $PIPE  2>/dev/null | cat $PIPE 2>/dev/null

rm $PIPE
#END SCRIPT

