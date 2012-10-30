#!/bin/sh

# video_to_mp3.sh
#  Extracts audio from input file (probably a video) and saves as MP3
# by Ian Katz, 2008
# ifreecarve@gmail.com
# released under the WTFPL


# usage function to display help for the hapless user
usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd inputfile outputfile"
     echo "Extracts audio from inputfile, saves as mp3 format in outputfile.mp3"
}

# test if we have an arguments on the command line
if [ $# != 2 ]
then
    usage
    exit
fi

echo "converting $1 to $2.mp3"
ffmpeg -i "$1" -f mp3 -vn -acodec libmp3lame "$2.mp3"
