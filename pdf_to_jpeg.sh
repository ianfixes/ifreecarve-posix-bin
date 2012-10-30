#!/bin/sh

# pdf_to_jpeg.sh
#  usage: pdf_to_jpeg.sh inputfile.pdf outputfile.jpg
# by Ian Katz, 2010
# ifreecarve@gmail.com
# released under the WTFPL


convert -density 200 "$@"
