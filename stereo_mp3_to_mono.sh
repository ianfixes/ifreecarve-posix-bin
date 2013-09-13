#!/bin/bash
#
# Usage: (this script) stereo-input.mp3 mono-output.mp3
#
# concept via http://superuser.com/a/566023/253931
#

bitrate=`file "$1" | sed 's/.*, \(.*\)kbps.*/\1/'`
BR='-V9'
if [ $bitrate -gt  75 ]; then BR='-V8'; fi
if [ $bitrate -gt  90 ]; then BR='-V7'; fi
if [ $bitrate -gt 105 ]; then BR='-V6'; fi
if [ $bitrate -gt 120 ]; then BR='-V5'; fi
if [ $bitrate -gt 145 ]; then BR='-V4'; fi
if [ $bitrate -gt 170 ]; then BR='-V3'; fi
if [ $bitrate -gt 180 ]; then BR='-V2'; fi
if [ $bitrate -gt 215 ]; then BR='-V1'; fi
if [ $bitrate -gt 230 ]; then BR='-V0'; fi
if [ $bitrate -gt 280 ]; then BR='-b320'; fi

echo "mono-izing file with detected bitrate '$bitrate': $mp3file"
lame --silent $BR -m m --mp3input "$1" "$2"
