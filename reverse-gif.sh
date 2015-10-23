#!/bin/sh

usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd normal.gif reversed.gif"
     echo 
     echo "Reverses an animated gif"
}


# test if we have an arguments on the command line
if [ $# -lt 2 ]
then
    usage
    exit
fi

convert $1 -coalesce -reverse -layers OptimizePlus -loop 0 $2