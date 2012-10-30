#!/bin/sh
#
# found at:
# https://ccollins.wordpress.com/2009/07/20/howto-pause-a-shell-script/
#

echo "Press any key to continue..."
OLDCONFIG=`stty -g`
stty -icanon -echo min 1 time 0
dd count=1 2>/dev/null
stty $OLDCONFIG
