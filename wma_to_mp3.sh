#!/bin/bash

# wma_to_mp3.sh
#  Dump a set of wma files to mp3 files
# by Ian Katz, 2010
# ifreecarve@gmail.com
# released under the WTFPL


for i in "$@"
do
  if [ -f "$i" ]; then
    rm -f $i.wav
    mkfifo $i.wav
    mplayer -vo null -vc dummy -af resample=44100 -ao pcm -ao pcm:waveheader $i -ao pcm:file=$i.wav &
    dest=`echo $i.mp3`
    lame -h -b 192 $i.wav $dest
    rm -f $i.wav
  fi
done
