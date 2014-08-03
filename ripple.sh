#!/bin/bash

# this command inserts blank lines into the terminal output


# function to get number of rows in the terminal
read_terminal_height() {
    ROWS=$(tput lines)
}

# under fast scrolling, insert a whole chunk of blank lines
clock_tick() {
    if [ $BLANKS -ge 5 ]; then
        let I=$ROWS
        while [ $I -ge 0 ]
        do
            let I=I-1
            echo 1>&2
        done
        sleep 0.1
    fi
    let BLANKS=0

    (sleep 1 ; kill -SIGUSR1 $MYPID 2>/dev/null) &
}

trap read_terminal_height WINCH
trap clock_tick SIGUSR1

# initialize
MYPID=$$
COUNTER=0
BLANKS=0

read_terminal_height
clock_tick

while read line
do
    echo "$line" 

    let COUNTER=COUNTER+1
    let DATE=$(date +%s)

    # under normal conditions, insert a blank line every time a row goes by
    if [ "$ROWS" -lt "$COUNTER" ]; then
        let COUNTER=0
        # only bother doing it once per second
        if  [ $BLANKS -eq 0 ]; then
            echo 1>&2
        fi
        let BLANKS=BLANKS+1
    fi

done
