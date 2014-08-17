#!/bin/zsh

#state=`xinput --list-props "PS/2 Generic Mouse" | grep Enabled | awk '{print $4}'`
#9.10
state=`xinput list-props "PS/2 Generic Mouse" | grep Enabled | awk '{print $4}'`
#echo "state = "$state;

if [ $state = '1' ]
then
    #xinput set-prop --type=int --format=8 "PS/2 Generic Mouse" "Device Enabled" "0"
    xinput set-int-prop "PS/2 Generic Mouse" "Device Enabled" 8 0
else
    #xinput set-prop --type=int --format=8 "PS/2 Generic Mouse" "Device Enabled" "1"
    xinput set-int-prop "PS/2 Generic Mouse" "Device Enabled" 8 1
fi
