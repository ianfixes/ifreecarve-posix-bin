#!/usr/bin/env python

# mini-buildbot script
# by Ian Katz, 2012
# ifreecarve@gmail.com
# released under the WTFPL


import sys
import os
import time
import datetime
import subprocess

spinner = {
    "|": "/",
    "/": "-",
    "-": "\\",
    "\\": "|"
    }

def print_usage():
        print ("\nUsage: %s <cmd> <file1> [file2 [file3 [ ... ]]]\n" % 
               os.path.basename(sys.argv[0]))

# update modification time dictionary and return list of changed files
def update_mods(mods, files):
    changed_files = []
    ret = {}
    for f in files:
        s = os.stat(f).st_mtime
        if s != mods[f]: 
            changed_files.append(f)
        ret[f] = s
    return ret, changed_files

#main loop
def monitor_files(shell_cmd, files):
    mtimes = {}
    for f in files:
        mtimes[f] = os.stat(f).st_mtime
    
    spin = "|"

    try:
        while True:
            mtimes, changes = update_mods(mtimes, files)
            
            if 0 == len(changes):
                sys.stdout.write("\r\x1b[K%s %s" % 
                                 (spin, 
                                  str(datetime.datetime.now()).split(".")[0]))
            else:
                sys.stdout.write("\nChanges detected:\n")
                for c in changes: sys.stdout.write("\t%s\n" % c)
                sys.stdout.write("Running build command:\n $ %s\n" % shell_cmd)
                p = subprocess.Popen(shell_cmd, shell=True, 
                                     executable=os.environ["SHELL"])
                p.wait()
                sys.stdout.write("\n")

            sys.stdout.flush() 
            time.sleep(.1)
            spin = spinner[spin]

    except KeyboardInterrupt:
        print
        return

if __name__ == "__main__":
    if 3 > len(sys.argv):
        print_usage()
        sys.exit(1)
        
    shell_cmd = sys.argv[1]
    files = sys.argv[2:]
    monitor_files(shell_cmd, files)

