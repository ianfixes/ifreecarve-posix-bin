#!/bin/sh

# usage function to display help for the hapless user
usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd portnum"
     echo "Starts an HTTP server in the current directory, using the given port"
}

# test if we have an arguments on the command line
if [ $# != 1 ]
then
    usage
    exit
fi

echo "python -m SimpleHTTPServer $1"
python -m SimpleHTTPServer $1