#!/bin/bash

# colors.sh
#  generates a color table in the terminal
# by Ian Katz, 2001-ish
# ifreecarve@gmail.com
# released under the WTFPL


R=37
C=47

echo -ne "_ _ _"
for ((c=40; c <= C; c++ ))
do
	echo -ne " _ _ $c _"
done
echo ""

for ((r=30; r <= R ; r++))
do

	echo -ne "$r   "
	for ((c=40; c <= C; c++))
	do
		echo -ne "\e[$r;${c}m Normal  "	
	done
	echo -e "\e[0m"

	echo -ne "     "
	for ((c=40; c <= C; c++))
	do
		echo -ne "\e[$r;${c};1m Bold    "
	done
	echo -e "\e[0m"
done

echo -e "\e[0m"
