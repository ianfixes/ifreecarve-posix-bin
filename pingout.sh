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
P_ISP=2   # pause between ISP pings (if successful)

# addresses
AD_GW=""
AD_ISP=""
AD_INET="4.2.2.2" # safe internet address to test.  Also, its a DNS server

OS=$(uname)
OS_X="Darwin"
OS_LIN="Linux"
      

# cross-platform ping
myping(){

  local adr="$1"
  local tmo="$2"

  if [ "$OS_LIN" = "$OS" ] ; then
    output_ping=$(ping -q -c 1 -w $tmo $adr >/dev/null 2>/dev/null)
    result_ping=$?
  elif [ "$OS_X" = "$OS" ] ; then
    output_ping=$(ping -q -c 1 -t $tmo $adr >/dev/null 2>/dev/null)
    result_ping=$?
  fi

}


# cross-platform gateway grab
getgateway(){

  if [ "$OS_LIN" = "$OS" ] ; then
    local route="0.0.0.0"
  elif [ "$OS_X" = "$OS" ] ; then
    local route="default"
  fi

  AD_GW=$(netstat -nr | grep ^$route | awk '{print $2}' | head -n 1)
}


# loop infinitely
while : ; do
  
  # print time
  NOW=$(date +"%H:%M:%S") 
  echo -ne "PingOut: $NOW "

  # ping internet
  myping $AD_INET $W_INET
  if [ 0 -eq "$result_ping" ] ; then
    echo -ne "Internet "
    sleep $P_INET
  else
    echo -ne "(No Internet) "

    # get ISP 
    TR=$(traceroute -q 1 -w $W_GW -f 2 -m 4 $AD_INET 2>/dev/null)
    if [ ! $? ] ; then
      AD_ISP=""
    else
      AD_ISP=$(echo "$TR" | grep "^ " | grep -v "*" | grep -v "!N" | grep -v "raceroute" )
      AD_ISP=$(echo "$AD_ISP" | head -n 1 | awk '{print $2}')
    fi

    # check ISP
    if [ -z "$AD_ISP" ] ; then 
      echo -ne "(No ISP) "
      DO_GW=""
    elif  [ "*" = "$AD_ISP" ] ; then
      echo -ne "(ISP FAIL) -- $AD_ISP"
      DO_GW=""
    else
      echo -ne "ISP -- $AD_ISP"
      DO_GW="NO"
      sleep $P_ISP
    fi

    if [ -z $DO_GW ]; then

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
        ping -q -c 1 -t $W_GW $AD_GW >/dev/null 2>/dev/null
        if [ ! $? ]; then
          echo -ne "(Gateway FAIL) " # FAIL
        else
          echo -ne "Gateway "
        fi
        echo -ne "-- $AD_GW"

      fi # pingged gateway
    fi # pingged isp
  fi # pingged inet


  echo "" # newline

done

