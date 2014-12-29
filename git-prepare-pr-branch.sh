#!/bin/sh -xe

# usage function to display help for the hapless user

usage ()
{
     mycmd=`basename $0`
     echo "$mycmd"
     echo "usage: $mycmd <git-clone-url> <pull-request-number>"
     echo
     echo "Downloads a merged pull request into the current directory"
}


# test if we have an arguments on the command line
if [ $# -lt 2 ]
then
    usage
    exit 1
fi


REPO=$1
PR=$2

git init .
git config remote.origin.url "$REPO"
#git fetch
#git fetch --tags --progress "$REPO" +refs/heads/*:refs/remotes/origin/*
git fetch -q --tags --progress "$REPO" +refs/pull/*:refs/remotes/origin/pr/*
HEAD=$(git rev-parse origin/pr/$PR/merge^{commit})
git checkout -q -f $HEAD
