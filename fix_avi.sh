#!/bin/sh

for arg in "$@" 
do
    mencoder -idx "$arg" -ovc copy -oac copy -o "$arg.fixed.avi"
    echo " $arg"
done

