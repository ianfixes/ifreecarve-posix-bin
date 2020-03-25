#!/bin/bash

# like mktemp-lite, but for current working directory. A unique filename.

# MUST RUN WITH BASH for $RANDOM

while : ; do 
  RET="tmpfile-$RANDOM.tmp" 
  [ -f $RET ] || echo $RET && break 
done
