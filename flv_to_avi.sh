#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 flv_file"
  exit 1
fi

# video encoding bit rate
V_BITRATE=1000
MENC_OPTS="-ovc lavc -lavcopts vcodec=mpeg4:vbitrate=$V_BITRATE:mbd=2:v4mv:autoaspect"

        mencoder-bin "$@" $MENC_OPTS -vf pp=lb -oac mp3lame \
          -lameopts fast:preset=standard -o \
          "`basename "$@" .flv`.avi"


