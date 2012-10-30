#!/bin/bash

# seq.sh
#  seq replacement for OSX
# by Ian Katz, 2011
# ifreecarve@gmail.com
# released under the WTFPL


if [ $# -eq 2 ]
then
  let from="$1";
  let to="$2";
elif [ $# -eq 1 ]
then
  let from="0";
  let to="$1";
else
  echo "Usage: seq [from] [to]"
exit 1;
fi

while [ $from -lt $to ]
do
  echo "$from";
  from=$[$from+1]
done
echo "$from";
