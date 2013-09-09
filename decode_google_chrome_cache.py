#!/usr/bin/python

import string
import BeautifulSoup
import zlib
import sys
import os

if 2 != len(sys.argv):
    script = os.path.basename(sys.argv[0])
    print "%s: Decode a Google Chrome cache file to stdout" % script
    print
    print "Usage: %s <file>" % script
    print
    exit(1)

soup = BeautifulSoup.BeautifulSoup(open(sys.argv[1]))

sections = soup.findAll('pre')
if 3 > len(sections):
    print "Couldn't find all 3 sections that we wanted"
    exit(2)

h_http = sections[0]
h_head = sections[1]
h_body = sections[2]

pairs = dict([string.split(p, ": ", 1) for p in h_http.text.split('\n') if ": " in p])


bytes = "".join(["".join([chr(int(b, 16)) 
                          for b in l[11:73].split("  ") if b]) 
                          for l in h_body.text.split('\n')])


if u'content-encoding' in pairs and u'gzip' == pairs[u'content-encoding']:
    bytes = zlib.decompress(bytes, 15 + 32) # autodetect compression type

print bytes,
