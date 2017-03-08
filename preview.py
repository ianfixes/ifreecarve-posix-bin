#!/usr/bin/env python

import sys
import os
from PIL import Image
import subprocess

def usage():
    print os.path.basename(__file__), "<file>"
    print
    print "Opens an appropriate command-line viewer for the file"
    print


def is_animated(gif_path):
    try:
        gif = Image.open(gif_path)
        gif.seek(1)
    except EOFError:
        return False
    else:
        return True

def handle_shell_command(args):
    try:
        subprocess.call(args)
    except OSError:
        print "Failed to execute shell command:", args
        exit(1)

def handle_image(f):
    print "handling image", f
    handle_shell_command(["xview", "-shrink", f])

def handle_gif_animation(f):
    print "handling gif animation", f
    #handle_shell_command(["animate", f])
    #handle_shell_command(["mplayer", f, "-loop", "0"])
    handle_shell_command(["gifview", "-a", "--fallback-delay", "10", f])

def handle_webm(f):
    handle_movie(f)

def handle_movie(f):
    print "handling movie", f
    handle_shell_command(["mplayer", "-fs", f])


def handle_file(f):
    _, e = os.path.splitext(f)
    ext = e.upper()[1:]

    if ext in ["JPG", "JPEG", "PNG"]:
        handle_image(f)
    elif ext in ["WEBM"]:
        handle_webm(f)
    elif ext in ["MOV", "AVI", "MKV", "MPG", "MPEG", "XVID", "WMV", "MP4", "FLV", "DV"]:
        handle_movie(f)
    elif ext in ["MP3", "WMA", "AC3", "FLAC", "WAV", "AIFF"]:
        handle_movie(f)
    elif ext == "GIF":
        if is_animated(f):
            handle_gif_animation(f)
        else:
            handle_image(f)
    else:
        print "I DON'T KNOW HOW TO OPEN", f

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()
        exit(1)

    handle_file(sys.argv[1]) # view the file
