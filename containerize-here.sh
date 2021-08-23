#!/bin/sh

docker run --rm -it -v "$(pwd):/host" "$@" /bin/sh -c 'cd /host && /bin/bash' 
