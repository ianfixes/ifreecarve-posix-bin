#!/usr/bin/env python

import sys
import tty
import termios
import os
import shutil
import Image
import subprocess

def usage():
    print os.path.basename(__file__), "<destination_dir1 [destination_dir2 [...]]> -- <file1 [file2 [...]]>"
    print
    print "Helps sort a set of files into a set of directories based on user interaction"
    print


def is_animated(gif_path):
    gif = Image.open(gif_path)
    try:
        gif.seek(1)
    except EOFError:
        return False
    else:
        return True


def get_char():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


def handle_image(f):
    print "handling image", f
    subprocess.call(["xview", "-shrink", f])

def handle_gif_animation(f):
    print "handling gif animation", f
    #subprocess.call(["animate", f])
    subprocess.call(["gifview", "-a", "--fallback-delay", "10", f])

def handle_webm(f):
    handle_movie(f)

def handle_movie(f):
    print "handling movie", f
    subprocess.call(["mplayer", f])


def handle_file(f):
    _, e = os.path.splitext(f)
    ext = e.upper()[1:]

    if ext in ["JPG", "JPEG", "PNG"]:
        handle_image(f)
    elif ext in ["WEBM"]:
        handle_webm(f)
    elif ext in ["MOV", "AVI", "MKV", "MPG", "MPEG", "XVID", "WMV", "MP4", "FLV"]:
        handle_movie(f)
    elif ext == "GIF":
        if is_animated(f):
            handle_gif_animation(f)
        else:
            handle_image(f)
    else:
        print "I DON'T KNOW HOW TO OPEN", f


def pick_n_place(destination_dirs, source_files):
    time_to_go = False

    # short names
    dnames = map(os.path.basename, destination_dirs)

    for i, s in enumerate(source_files):
        print i, "of", len(source_files), "Deciding what to do with", s
        handle_file(s) # view the file

        while True:
            print

            print "s) skip this file for now"
            print "l) look at it again"
            # 1-index the directories
            for i, d in enumerate(dnames):
                print str((i + 1) % 10) + ") move file to", d + "/"

            c = get_char()
            
            if "s" == c:
                break
            elif "l" == c:
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
        exit(1)
        
    pick_n_place(destinations, files_that_are_not_dirs)
