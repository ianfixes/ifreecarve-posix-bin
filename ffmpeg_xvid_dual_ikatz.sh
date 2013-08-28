#!/bin/sh
# A Kino export script that outputs to MPEG-4 part 2 AVI using ffmpeg with Xvid

usage()
{
	# Title
	echo "Title: (ikatz) XviD MPEG-4 AVI Dual Pass (FFMPEG)"

	# Usable?
	xvid=`ffmpeg -formats 2> /dev/null | egrep "(Encoders:)|(.*EV.*xvid)" | grep xvid | wc -l`
	[ "$xvid" -gt 0 ] && echo Status: Active || echo Status: Inactive

	# Type
	echo Flags: double-pass file-producer

	# Profiles
	echo "Profile: Best Quality (native size, interlace, 2240 kb/s)"
	echo "Profile: High Quality (640x480, progressive, 2240 kb/s)"
	echo "Profile: Medium Quality (512x384, progressive, 1152 kb/s)"
}

execute()
{
	# Arguments
	normalisation="$1"
	length="$2"
	profile="$3"
	file="$4"
	pass="$6"
	aspect="$7"
	
	. "`dirname $0`/ffmpeg_utils.sh"

	# generate filename if missing
	[ "x$file" = "x" ] && file="kino_export_"`date +%Y-%m-%d_%H.%M.%S`
	
	# Determine audio codec (MP3 if avail)
	acodec="mp2"
	mp3=0
	mp3=`ffmpeg -formats 2> /dev/null | egrep "(Encoders:)|(.*E.*mp3)" | grep mp3 | wc -l`
	[ "$mp3" -gt 0 ] && acodec="mp3"

	# Set high quality on second pass
	[ $pass -eq "2" ] && ffmpeg_generate_hq

	# Run the command
	case "$profile" in 
		"0" ) 	ffmpeg -f dv -i pipe: -pass $pass -passlogfile "$file" $hq \
			-vcodec $xvid -g 300 $hq $interlace -aspect $aspect -b 2048$kilo \
			-acodec "$acodec" -ab 192$audio_kilo -y "$file".avi ;;
		"1" ) 	ffmpeg -f dv -i pipe: -pass $pass -passlogfile "$file" $hq \
			-vcodec $xvid -g 300 $hq $progressive -s $res_640 -aspect $aspect -b 2048$kilo \
			-acodec "$acodec" -ab 192$audio_kilo -y "$file".avi ;;
		"2" ) 	ffmpeg -f dv -i pipe: -pass $pass -passlogfile "$file" $hq \
			-vcodec $xvid -g 300 $hq $progressive -s $res_512 -aspect $aspect -b 1664$kilo \
			-acodec "$acodec" -ar 44100 -ab 128$audio_kilo -y "$file".avi ;;
	esac
	if [ $pass -eq "2" ]; then
		rm -f "$file-0.log"
	fi
}

[ "$1" = "--usage" ] || [ -z "$1" ] && usage "$@" || execute "$@"
