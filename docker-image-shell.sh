#!/bin/sh

# usage function to display help for the hapless user
usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd imagename [shell]"
     echo "Runs a shell in a docker image with the current directory mounted at /app"
}

# test if we have an arguments on the command line
if [ $# -lt 1 ]
then
    usage
    exit
fi

echo docker run --rm -it -v "${PWD}:/app" -u root -w /app "$@"
docker run --rm -it -v "${PWD}:/app" -v /var/run/docker.sock:/var/run/docker.sock -u root -w /app "$@"
