#!/bin/sh

# moves stuff into a temp directory, but not the hidden stuff.  that's sort of why this works.

TMPDIR=.ifreecarve-migration
DEST="$1"


echo "Moving everything into temp dir $TMPDIR"
mkdir $TMPDIR
git filter-branch -f --tree-filter "compgen -G * && rsync -a * $TMPDIR/ && rm -rf * || echo nope" HEAD

echo "Moving everything from temp dir $TMPDIR to final destination $1"
mkdir $DEST
git filter-branch -f --tree-filter "compgen -G $TMPDIR && rsync -a $TMPDIR/* $DEST/ && rm -rf $TMPDIR || echo nope" HEAD

rmdir $TMPDIR
