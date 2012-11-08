#!/bin/bash

# pingout.sh
#  Monitors connectivity.  Pings local network quickly, internet slowly
#  
# by Ian Katz, 2012
# ifreecarve@gmail.com
# released under the WTFPL


# timeouts
W_GW=1    # gateway ping timeout
W_ISP=2   # ISP ping timeout
W_INET=3  # internet ping timeout
P_INET=10 # pause between internet pings (if successful)

# addresses
AD_GW=""
AD_ISP=""
AD_INET="4.2.2.2" # safe internet address to test.  Also, its a DNS server

# loop infinitely
while : ; do
  
  # print time
  NOW=$(date +"%H:%M:%S") 
  echo -ne "PingOut: $NOW "

  # get gateway... currently works on OSX or linux
  if netstat -nr | grep ^0.0.0.0 >/dev/null ; then # linux
    AD_GW=$(netstat -nr | grep ^0.0.0.0 | awk '{print $2}' | head -n 1)
  elif netstat -nr |grep ^default >/dev/null ; then # OSX
    AD_GW=$(netstat -nr | grep ^default | awk '{print $2}' | head -n 1)
  else
    AD_GW=""
  fi

  # check gateway
  if [ -z "$AD_GW" ]; then
    echo -ne "(No Gateway)"
    sleep $W_GW
  else

    # ping gateway
    ping -q -c 1 -t $W_GW $AD_GW >/dev/null
    if [ ! $? ]; then
      echo -ne "" # FAIL
    else
      echo -ne "Gateway "

      # get ISP 
      TR=$(traceroute -q 1 -w $W_GW -f 2 -m 2 $AD_INET 2>/dev/null)
      if [ ! $? ] ; then
        AD_ISP=""
      else
        AD_ISP=$(echo "$TR" | grep " 2 " | awk '{print $2}')
      fi

      # check ISP
      if [ -z "$AD_ISP"  -o  "*" = "$AD_ISP" ] ; then
        echo -ne "(No ISP) "
        sleep $W_ISP
      else
        # ping ISP
        ping -q -c 1 -t $W_ISP $AD_ISP >/dev/null
        if [ ! $? ]; then
          #sleep $W_ISP
          echo -ne "" # FAIL
        else
          echo -ne "ISP "

          # ping internet
          ping -q -c 1 -t $W_INET $AD_INET >/dev/null
          if [ ! $? ]; then
            echo -ne "" # FAIL
          else
            echo -ne "Internet"
            sleep $P_INET
          fi # pingged inet
        fi # pingged isp
      fi # got isp address
    fi # pingged gw
  fi # got gw address

  echo "" # newline

done

