#!/bin/sh
#echo launched >> ~/take-screenshot.log
#printenv >> ~/take-screenshot.log
sleep 0.05
gnome-screenshot -a
#gksu -u `whoami` "gnome-screenshot -a"
#echo $? >> ~/take-screenshot.log
