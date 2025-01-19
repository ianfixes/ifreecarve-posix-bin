#!/bin/sh

if ! test -z "$1" ; then
  cd "$1"
fi
  

EDITOR="code -nw" vidir
