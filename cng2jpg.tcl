#!/usr/bin/tclsh
##
##########################################################################
## NOTE:
## If 'tclsh' is in /usr/local/bin, for example, instead of /usr/bin, then
## the (root) user could make a soft-link named /usr/bin/tclsh that
## points to /usr/local/bin/tclsh. Example command:
##             ln -s /usr/bin/local/tclsh  /usr/bin/tclsh
## Then this script will work without changing the top line of the script.
##########################################################################
## Tcl SCRIPT NAME:   .cng2jpg.tcl
##
## WHERE:        in  $DIR_NAUT/IMAGEtools/otherCONVERT
##
##                                    where $DIR_NAUT is the Nautilus
##                                    Scripts directory, typically
##                                    $HOME/.gnomeN/nautilus-scripts
##                                    where N=2 (or 3?).
##########################################################################
## PURPOSE:  Reads the bytes of a Complete National Geographic ('.cng')
##           file and converts the bytes --- by an XOR with hex 'EF' =
##           decimal 239 = binary 11101111 --- to make a JPEG ('.jpg') file.
##########################################################################
## IMPLEMENTATION:
## As a Nautilus script utility, this 'hidden' Tcl script (note the dot
## prefix on the script name) is called in a 'wrapper' shell script,
## named cng2jpg.sh.
##########################################################################
## DEVELOPED WITH: Tcl 8.5 --- on Ubuntu 9.10 Linux.
##   tclsh> puts "$tcl_version"
##   8.58.4
##########################################################################
## This script was developed in 2011 and was released as part of the
## FE (Freedom Environment) system --- Copyright 2006+ by Blaise Montandon
##########################################################################
## MAINTENANCE HISTORY of cng2jpg.tcl:
## Written by: Blaise Montandon 2011dec19 Started on an Ubuntu 9.10 system.
## Updated by: Blaise Montandon 2011
###########################################################################

## FOR TESTING:
#  puts "STARTING."

##########################################################################
## GET THE FILENAME TO CONVERT AND FILENAME FOR OUTPUT -- by
##      1) PROCESSING COMMAND LINE ARGUMENTS (two arguments)
##   OR
##      2) GETTING CONTENTS OF ENVIRONMENT VARIABLES 'FILEIN' and 'FILEOUT'.
##########################################################################

set argc [llength $argv]

set FILEin ""
set FILEout ""

if {$argc == 0} {
   catch { set FILEin  "$env(FILEIN)" } 
   catch { set FILEout "$env(FILEOUT)" } 
   if { "$FILEin" == "" || "$FILEout" == "" } {
      puts "*** Need filenames. There are no arguments, and the"
      puts "    environment variable FILEIN or FILEOUT is not set."
      exit
   }
} elseif {$argc == 2} {
   set FILEin  [lindex $argv 0]
   set FILEout [lindex $argv 1]
} else {
   puts "*** Wrong number of arguments."
   puts "    Should be two: one input filename and one output filename."
   puts "    If the filenames contain embedded spaces, you may need to"
   puts "    put the filenames in quotes."
   exit
}

########################################################################
## Open the input and output files.
##
## Then read the contents of $FILEin--- a character at a time --- into
## the character variable, BYTEin.
## 
## Uses 'read' to read characters, one at a time. (Underneath it all
## the file reads are actually buffered. So the reading of the CNG file
## should go really fast, in blocks. We are actually fetching a byte at
## a time from a cache input buffer, which should go very fast.) 
##
## Translate each character (by XOR with hex 'EF' = decimal 239)
## and write (with 'puts') the resulting byte to the output file,
## $FILEout. (As with reading, underneath it all, the file writing is
## actually buffered and is done in blocks. We are actually putting a
## byte at a time into a cache output buffer. The actual writes to
## the resulting JPEG file should go very fast.)
########################################################################

## FOR TESTING:
#   puts "FILEin   : $FILEin"
#   puts "FILEout  : $FILEout"

set f1 [open $FILEin r]
fconfigure $f1 -translation binary

set f2 [open $FILEout w]
fconfigure $f2 -translation binary

## FOR TESTING:
# set TotBytesRead 0

###############################################################
## START READING AND TRANSLATING THE BYTES --- AND WRITING EACH
## BYTE TO THE OUTPUT FILE.
###############################################################

while {![eof $f1]} {

   ## NOTE: We are reading one byte at a time here.
   set BYTEin [read $f1 1]

   ## FOR TESTING:
   # set TotBytesRead  [expr $TotBytesRead + 1]

   ## FOR TESTING:
   #    puts "*************************"
   #    puts "TotBytesRead   : $TotBytesRead"
   #    puts "BYTEin         : $BYTEin"

   ## FOR TESTING:  (stop after processing 10 bytes)
   # if { $TotBytesRead > 10 } {
   #    close $f1
   #    close $f2
   #    exit
   # }

   #######################################################################
   ## TRANSLATION OF THE BYTE IS HERE -- XOR with hex 'EF' for each byte.
   ##
   ## In 'binary scan', 'c' indicates we want the new variable CHARin to be 
   ## 'typed' as an 8-bit character code.
   ##
   ## TO DO: Check if we can XOR with BYTEin and eliminate the 'binary scan'
   ## into the variable CHARin.
   #######################################################################

   binary scan "$BYTEin" c CHARin
   ## FOR TESTING:
   #    puts "CHARin         : $CHARin"

   set XORout [expr { $CHARin ^ 239 }]
   ## FOR TESTING:
   #    puts "XORout        : $XORout"


   ##########################################################
   ## WRITING OUT THE BYTE HERE.
   ##
   ## TO DO: Check if we can just 'puts' XORout and eliminate
   ## the 'binary scan' into the variable BYTEout.
   ##########################################################

   set BYTEout [binary format c $XORout]
   ## FOR TESTING:
   #    puts "BYTEout        : $BYTEout"

   puts -nonewline $f2 $BYTEout

}
## END OF   while {![eof $f1]}

close $f1
close $f2

## FOR TESTING:
#  puts "Finished."
#  puts "   TotBytesRead   : $TotBytesRead"

exit

EXAMPLE 'FOR TESTING' OUTPUT FROM THE FIRST TEN BYTES OF A CNG FILE:

*************************
TotBytesRead   : 1
BYTEin         : 
CHARin         : 16
XORout        : 255
BYTEout        : ÿ
*************************
TotBytesRead   : 2
BYTEin         : 7
CHARin         : 55
XORout        : 216
BYTEout        : Ø
*************************
TotBytesRead   : 3
BYTEin         : 
CHARin         : 16
XORout        : 255
BYTEout        : ÿ
*************************
TotBytesRead   : 4
BYTEin         : 
CHARin         : 15
XORout        : 224
BYTEout        : à
*************************
TotBytesRead   : 5
BYTEin         : ï
CHARin         : -17
XORout        : -256
BYTEout        : 
*************************
TotBytesRead   : 6
BYTEin         : ÿ
CHARin         : -1
XORout        : -240
BYTEout        : 
*************************
TotBytesRead   : 7
BYTEin         : ¥
CHARin         : -91
XORout        : -182
BYTEout        : J
*************************
TotBytesRead   : 8
BYTEin         : ©
CHARin         : -87
XORout        : -186
BYTEout        : F
*************************
TotBytesRead   : 9
BYTEin         : ¦
CHARin         : -90
XORout        : -183
BYTEout        : I
*************************
TotBytesRead   : 10
BYTEin         : ©
CHARin         : -87
XORout        : -186
BYTEout        : F
*************************












