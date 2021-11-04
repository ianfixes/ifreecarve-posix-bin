#!/bin/sh
#
# shell exits success if git is tracking the file given as the arg 

git ls-files --error-unmatch $1 1>/dev/null 2>/dev/null
