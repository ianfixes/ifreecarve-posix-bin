#!/bin/sh
echo "You're going to run (with our additions) ssh $@"
read -s -p "Password to use: " SSHPASS 
export SSHPASS
sshpass -e ssh -o PreferredAuthentications=keyboard-interactive -o PubkeyAuthentication=no "$@"
unset SSHPASS
