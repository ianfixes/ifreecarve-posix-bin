#!/usr/bin/env python

import sys
import tty
import termios
import os
import shutil
import subprocess

def usage():
    print os.path.basename(__file__), "<destination_dir1 [destination_dir2 [...]]> -- <file1 [file2 [...]]>"
    print
    print "Helps sort a set of files into a set of directories based on user interaction"
    print


def get_char():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch



def handle_file(f):
    try:
        subprocess.call(["preview.py", f])
    except OSError:
        print "Failed to execute shell command:", args
        exit(1)


def pick_n_place(destination_dirs, source_files):
    time_to_go = False
    undo_mv = None

    # short names
    dnames = map(os.path.basename, destination_dirs)

    for i, s in enumerate(source_files):
        print i, "of", len(source_files), "Deciding what to do with", s
        handle_file(s) # view the file

        while True:
            print

            print "s) skip this file for now"
            print "l) look at it again / repeat"
            print "r) look at it again / repeat"
            print "u) undo the last move"

            # 1-index the directories
            for i, d in enumerate(dnames):
                print str((i + 1) % 10) + ") move file to", d + "/"

            c = get_char()

            if "s" == c:
                break
            elif "u" == c:
                if not undo_mv is None:
                    shutil.move(undo_mv[0], undo_mv[1])
            elif c in ["l", "r"]:
                handle_file(s) # view the file
            elif 3 == ord(c):
                time_to_go = True
                break
            else:
                # handle numbers
                if ord("0") <= ord(c) and ord(c) <= ord("9"):
                    # convert back to 0-index
                    idx = (ord(c) - ord("0") - 1) % 10
                    if idx >= len(destination_dirs):
                        print "THAT WONT WORK, IDIOT."
                    else:
                        dest = destination_dirs[idx]
                        print "move", s, "to", dest
                        try:
                            shutil.move(s, dest)
                            try:
                                # compute origin dir and destination path
                                parts = os.path.split(s)
                                moved_to = os.path.join(dest, parts[1])
                                moved_from = parts[0]
                                undo_mv = [moved_to, moved_from]
                            except:
                                pass
                            break
                        except Exception as e:
                            print e
                else:
                    print "Ctrl-C exits"

            print

        print
        if time_to_go:
            break

    print "Normal exit"



if __name__ == "__main__":
    if not "--" in sys.argv:
        usage()
        exit(1)

    dash = sys.argv.index("--")

    destinations = map(os.path.realpath, sys.argv[1:dash])
    sources = map(os.path.realpath, sys.argv[(dash + 1):])

    if len(destinations) > 10:
        print "I can only handle 10 directories at once, not", len(destinations)
        exit(1)

    if not all(map(os.path.isdir, destinations)):
        print "These destinations are not a directories:"
        print filter(lambda x: not os.path.isdir(x), destinations)
        exit(1)

    files_are_dirs = [(f, os.path.isdir(f)) for f in sources]
    just_files_are_files = filter(lambda (k, v): (not v), files_are_dirs)
    files_that_are_not_dirs = map(lambda x: x[0], just_files_are_files)

    if not all(map(os.path.isfile, files_that_are_not_dirs)):
        print "These sources are not files:"
        print filter(lambda x: not os.path.isfile(x), sources)
        files_that_are_not_dirs = filter(lambda x: os.path.isfile(x), sources)
        #exit(1)

    pick_n_place(destinations, files_that_are_not_dirs)
