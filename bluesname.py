#!/usr/bin/env python

# http://www.mandatory.com/2013/07/09/the-ultimate-insult-creator/

import sys
import os
import random
import string

def get_names():
    name1 = [
        "Fat",
        "Buddy",
        "Sticky",
        "Old",
        "Texas",
        "Hollerin'",
        "Ugly",
        "Brown",
        "Happy",
        "Boney",
        "Curly",
        "Pretty",
        "Jailhouse",
        "Peg-Leg", 
        "Red",
        "Sleepy",
        "Bald",
        "Skinny",
        "Blind",
        "Big",
        "Yella",
        "Toothless",
        "Screamin'",
        "Fat-Boy",
        "Washboard",
        "Steel-Eye",
    ]
    
    name2 = [
        "Bones",
        "Money",
        "Harp",
        "Legs",
        "Eyes",
        "Lemon",
        "Killer",
        "Hips",
        "Lips",
        "Fingers",
        "Boy",
        "Liver",
        "Gumbo",
        "Foot",
        "Mama",
        "Back",
        "Duke",
        "Dog",
        "Bad Boy",
        "Baby",
        "Chicken",
        "Pickles",
        "Sugar",
        "Willy",
        "Tooth",
        "Smoke",
    ]

    name3 = [
        "Jackson",
        "McGee",
        "Hopkins",
        "Dupree",
        "Green",
        "Brown",
        "Jones",
        "Rivers",
        "Malone",
        "Washington",
        "Smith",
        "Parker",
        "Lee",
        "Thompkins",
        "King",
        "Bradley",
        "Hawkins",
        "Jefferson",
        "Davis",
        "Franklin",
        "White",
        "Jenkins",
        "Bailey",
        "Johnson",
        "Blue",
        "Allison"
    ]
    
    return [name1, name2, name3]


if __name__ == "__main__":
    #if 3 > len(sys.argv):
    #    print_usage()
    #    sys.exit(1)
        
    names = get_names()

    bluesman = []

    for i, n in enumerate(names):
        name_lbl = "NAME%d" % i
        idx = 0
        if name_lbl in os.environ:
            idx = int(os.environ[name_lbl])
        else:
            idx = random.randint(0, len(n) - 1)

        #sys.stderr.write(str(idx))
        #sys.stderr.write(" ")
        bluesman.append(n[idx % len(n)])

    #sys.stderr.write("\n")


    print " ".join(bluesman)
