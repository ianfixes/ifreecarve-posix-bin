#!/bin/sh

# NOTE: this goes much better with
# git config --global rebase.abbreviatecommands true

# usage function to display help for the hapless user
usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd <memo>"
     echo "Applies a patch that is meant as a fixup for non-HEAD"
     echo " (MIB means what you think you saw, you did not see)"
}

# test if we have an arguments on the command line
if [ $# != 1 ]
then
    usage
    exit
fi
# 

git add -p && git commit -m "fixup $1" && git rebase -i
