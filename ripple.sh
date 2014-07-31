#!/bin/bash

# this command inserts blank lines into the terminal output

trap "read_terminal_height" WINCH


# function to get number of rows in the terminal
read_terminal_height() {
    ROWS=$(tput lines)
}

# initialize
read_terminal_height

COUNTER=0
while read line
do 
    echo "$line" 
    let COUNTER=COUNTER+1

    if [ "$ROWS" -lt "$COUNTER" ]; then
        let COUNTER=0
        echo 1>&2
    fi
done
