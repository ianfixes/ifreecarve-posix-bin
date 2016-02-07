#!/bin/sh

# apt-parallel-download.sh
# by Ian Katz, 2011
# ifreecarve@gmail.com
# released under the WTFPL


# usage function to display help for the hapless user

usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd package [package2 [package3 [...]]]"
     echo 
     echo "Downloads apt packages in parallel"
}


# test if we have an arguments on the command line
if [ $# -lt 1 ]
then
    usage
    exit
fi

# go to cache dir
cd /var/cache/apt/archives

# get list of debs
apt-get install -y --print-uris $@ > /tmp/debs.list

# download them
egrep -o -e "http://[^\']+" /tmp/debs.list | xargs -i{} -l3 -P5 wget -nv

