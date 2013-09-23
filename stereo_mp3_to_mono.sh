#!/bin/bash
#
# Usage: (this script) stereo-input.mp3 mono-output.mp3
#
# concept via http://superuser.com/a/566023/253931
#

OS=$(uname)
OS_X="Darwin"
OS_LIN="Linux"


if [ "$OS_LIN" = "$OS" ] ; then
    bitrate=`file "$1" | sed 's/.*, \(.*\)kbps.*/\1/'`
elif [ "$OS_X" = "$OS" ] ; then
    bitrate=`afinfo "$1" | grep "bits per second" | sed 's/.*: \(.*\)000 bits per second.*/\1/'`
fi


#freq=`afinfo "$1" | grep "Data format" | sed 's/.*, \(.*\)Hz.*/\1/' | awk '{print $1/1000}'`

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

echo "mono-izing file with detected bitrate '$bitrate': $1"
lame --silent $BR -m m -q 2 --mp3input "$1" "$2"
#lame --silent $BR --resample $freq -m m -q 2 --mp3input "$1" "$2"
