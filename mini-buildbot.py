#!/usr/bin/env python

# mini-buildbot script
#  monitors files for changes, then runs a command
# by Ian Katz, 2012
# ifreecarve@gmail.com
# released under the WTFPL


import sys
import os
import time
import datetime
import subprocess

spinners = ["|/-\\", ".,ooOO0@* ", "'!|Yv "] #, ">v<^"]


def print_usage():
    print ("\nUsage: %s <cmd> <file1> [file2 [file3 [ ... ]]]\n" % 
           os.path.basename(sys.argv[0]))

def notify(message, success):
    if not hasattr(notify, "can_notify"):
        notify.can_notify = True

    if notify.can_notify:
        try:
            exe = os.path.basename(sys.argv[0])
            if success:
                status = "SUCCESS"
            else:
                status = "FAIL"
            subprocess.call(["growlnotify", "-t", "%s -- %s" % (exe, status), "-m", message])
        except OSError as e:
            if e.errno == os.errno.ENOENT:
                # handle file not found error.
                notify.can_notify = False
                print "Can't notify with growlnotify\n"
            else:
                # Something else went wrong
                raise

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
    
    spin = 0
    buildnum = 0

    try:
        spinner = spinners[buildnum % len(spinners)]
        while True:
            mtimes, changes = update_mods(mtimes, files)
            
            if 0 == len(changes):
                sys.stdout.write("\r\x1b[K%s %s" % 
                                 (spinner[spin], 
                                  str(datetime.datetime.now()).split(".")[0]))
            else:
                buildnum += 1
                sys.stdout.write("\nStarting build #%d for these changes:\n" % buildnum)
                for c in changes: sys.stdout.write("\t%s\n" % c)
                sys.stdout.write("Running build command:\n $ %s\n" % shell_cmd)
                p = subprocess.Popen(shell_cmd, shell=True, 
                                     executable=os.environ["SHELL"])
                p.wait()
                sys.stdout.write("\n")
                notify("Build #%d complete" % buildnum, 0 == p.returncode)
                spinner = spinners[buildnum % len(spinners)]

            sys.stdout.flush() 
            time.sleep(.1)
            spin = (spin + 1) % len(spinner)

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

