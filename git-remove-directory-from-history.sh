#!/bin/sh

# via https://stackoverflow.com/a/17824718/2063546

# usage function to display help for the hapless user
usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd directory"
     echo "Removes a directory from a repository's history"
}

# test if we have an arguments on the command line
if [ $# -lt 1 ]
then
    usage
    exit
fi

git filter-branch --tree-filter "rm -rf $*" --prune-empty HEAD
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
git gc
