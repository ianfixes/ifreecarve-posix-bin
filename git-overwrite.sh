#!/bin/sh

# usage function to display help for the hapless user
usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd remotename branchname"
     echo "Patches HEAD and force-pushes the result to a remote branch"
     echo "  e.g. $mycmd origin my_feature_branch"
}

# test if we have an arguments on the command line
if [ $# != 2 ]
then
    usage
    exit
fi
# 

LOCALBRANCH=$(git symbolic-ref --short HEAD)
git add -p && git commit --amend --no-edit && git push -f $1 $LOCALBRANCH:$2
