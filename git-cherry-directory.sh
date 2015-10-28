#!/bin/sh

mycmd=$(basename $0)
if [ -z "$2" ]; then
  echo "Usage: $mycmd <other_branch> <path> [[path2] ...]"
  echo
  echo "Gives a list of commits that are in <other_branch> but not this one, that affect <path>"
  exit 1
fi

tempfileC=$(mktemp -t $mycmd) # cherry
tempfileL=$(mktemp -t $mycmd) # log

other_branch="$1"

git cherry "$other_branch" | cut -f 2 -d " " > "$tempfileC"
shift # now $@ is a list of paths

my_branch=$(git rev-parse --abbrev-ref HEAD)
echo "My branch is $my_branch"
common_ancestor=$(git merge-base -a "$my_branch" "$other_branch")
echo "Common ancestor is $common_ancestor"



unlink "$tempfileC"
unlink "$tempfileL"
