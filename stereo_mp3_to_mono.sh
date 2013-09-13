#!/bin/bash
#
# via http://superuser.com/a/566023/253931

mp3file=$@

mp3size () {
    du -sk "$1" | awk '{print $1 * 8 }'
}
mp3length () {
    id3info "$1" | \
        awk '/=== TLEN/ { if ($NF > 0) { len=int( $NF/1000) }} END {print len}'
}
mp3rate () {
    echo $(( `mp3size "$1"` / `mp3length "$1"` ))
}

bitrate=`mp3rate "$mp3file"`
if [ $bitrate -gt 155 ]; then VBR='-V4'; fi
if [ $bitrate -gt 190 ]; then VBR='-V2'; fi
if [ $bitrate -gt 249 ]; then VBR='-V0'; fi

echo downsampling $mp3file
lame --silent $VBR -m m --mp3input "$mp3file" \
      "$(basename "$mp3file" .mp3 )-mono.mp3"
