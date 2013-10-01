#!/usr/bin/env python

# http://www.mandatory.com/2013/07/09/the-ultimate-insult-creator/

import sys
import os
import random
import string

def get_names():
    name1 = [
        "lazy",
        "stupid",
        "insecure",
        "idiotic",
        "slimy",
        "slutty",
        "pompus",
        "communist",
        "dicknose",
        "pie-eating",
        "racist",
        "elitist",
        "white trash",
        "drug-loving",
        "butterface",
        "tone deaf",
        "ugly",
    ]
    
    name2 = [
        "douche",
        "ass",
        "turd",
        "rectum",
        "butt",
        "cock",
        "shit",
        "crotch",
        "bitch"
        "prick",
        "slut",
        "taint",
        "fuck",
        "dick",
        "boner",
        "shart",
        "nut",
    ]

    name3 = [
        "pilot",
        "canoe",
        "captain",
        "pirate",
        "hammer",
        "knob",
        "box",
        "jockey",
        "nazi",
        "waffle",
        "goblin",
        "biscuit",
        "clown",
        "socket",
        "monster",
        "hound", 
        "dragon",
    ]
    
    return [name1, name2, name3]


if __name__ == "__main__":
    #if 3 > len(sys.argv):
    #    print_usage()
    #    sys.exit(1)
        
    names = get_names()

    insult = []

    for i, n in enumerate(names):
        name_lbl = "NAME%d" % i
        idx = 0
        if name_lbl in os.environ:
            idx = int(os.environ[name_lbl])
        else:
            idx = random.randint(0, len(n) - 1)

        #sys.stderr.write(str(idx))
        #sys.stderr.write(" ")
        insult.append(n[idx % len(n)])

    #sys.stderr.write("\n")

    outsult = ""
    if 1 == len(sys.argv):
        outsult = " ".join(insult)
    else:
        outsult = " ".join(sys.argv[1:])
        
        if -1 < string.find("aeiou", insult[0][0]):
            outsult += " is an "
        else:
            outsult += " is a "
  
        outsult += " ".join(insult)
        outsult += "."


    print outsult
