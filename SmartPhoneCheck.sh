#!/bin/bash
# Based on the excellent community work here : https://www.domoticz.com/forum/viewtopic.php?t=6264
# Adapted to my configuration
# Last Update 20160903
## Installation ##
# Add this script in the /etc/local.rc like that :
# /path/to/your/script/script.sh BTMAC WiFiMAC SwitchID &
# ATTENTION the "&" is very important !!!


if [ -z "$3" ] ; then
        echo "Usage:   SmartphoneCheck.sh BTMAC WiFiMAC SwitchID"
        echo "Example: SmartphoneCheck.sh AA:BB:CC:16:09:51 aa:bb:cc:b4:a5:21 65"
        exit
fi

# Main settings
DomoticzIP="127.0.0.1:8080"     # Your Domoticz IP address and port if different from 80

# Script variables
LongSleep=200                   # Time to sleep between probes if device is within range.
ShortSleep=20                   # Time to sleep between probes if device is out of range. Don't make this too long, because the arp-scan and l2ping take almost 10 seconds.
DownStateRecheckTime=5          # Time to sleep between rechecks if device falls out of range.
DownStateRecheckCount=4         # Number of rechecks to perform before device is confirmed out of range (time = DownStateRecheckTime * DownStateRecheckCount)
MACAddressBT=$1                 # Set the MAC Address of the Bluetooth interface (script parameter 1)
MACAddressWIFI=$2               # Set the MAC Address of the WiFi interface (script parameter 2)
DeviceID=$3                     # Set the Switch ID (script parameter 3)

# Remove Capitals from Wifi mac.
MACAddressWIFI=`echo $MACAddressWIFI | tr '[:upper:]' '[:lower:]'`

#Startup delay
sleep 60                        # Wait for the Raspberry to finish booting completely.

#Main loop
while [ 1 ]
do

  #Ping test
  sudo l2ping -c1 $MACAddressBT > /dev/null 2>&1
  Result=$?                                          # Store the return code in BTResult (will be 0 if mac is found).
  if  [ $Result -eq 0 ] ; then
      echo "`date -u` - Performing check:   Bluetooth check success.."
  else
      sudo arp-scan -l -i 1 | grep $MACAddressWIFI > /dev/null 2>&1
      Result=$?                                      # Store the return code in WIFIResult (will be 0 if the mac is found).
      if  [ $Result -eq 0 ] ; then
          echo "`date -u` - Performing check:   WiFi check success.."
      else
          echo "`date -u` - Performing check:   Both WiFi and Bluetooth unavailable for now.."
      fi
  fi

  if  [ $Result -eq 0 ] ; then
    #Device in range
    LoopSleep=$LongSleep
    curl -s "http://$DomoticzIP/json.htm?type=devices&rid=$DeviceID" | grep Status | grep Off > /dev/null
     if [ $? -eq 1 ] ; then
      # Do nothing device presence did not change
      echo "`date -u` - Status Unchanged:   Already on, do nothing and wait $LoopSleep seconds.."
    else
      #Device is status changed to: in range / detected
      echo -e "`date -u` - Status Changed:   Turning device ID $DeviceID on and wait $LoopSleep seconds.."
      `curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$DeviceID&switchcmd=On" > /dev/null`
    fi
  else
    #Device out of range
    LoopSleep=$ShortSleep
    curl -s "http://$DomoticzIP/json.htm?type=devices&rid=$DeviceID" | grep Status | grep Off > /dev/null
    if [ $? -eq 0 ] ; then
      # Do nothing device presence did not change
      echo "`date -u` - Status Unchanged:   Already off, do nothing and wait $LoopSleep seconds.."
    else
      x=0
      while [ $x -le $DownStateRecheckCount ]
      do
       x=$(( $x + 1 ))
       if  [ $x -eq $DownStateRecheckCount ] ; then
        # Device status changed to : not in range / not detected
          echo -e "`date -u` - Status Changed:   Turning device ID $DeviceID off"
         `curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$DeviceID&switchcmd=Off" > /dev/null`
        break
        fi
        echo "`date -u` - Performing recheck: Device possibly down, rechecking and wait $DownStateRecheckTime seconds.."

        #Ping test
            sudo arp-scan -l -i 1 | grep $MACAddressWIFI > /dev/null 2>&1
            Result=$?                                      # Store the return code in WIFIResult (will be 0 if the mac is found).
            if  [ $Result -eq 0 ] ; then
                echo "`date -u` - Performing recheck: WiFi check success.."
            else
                echo "`date -u` - Performing recheck: Both WiFi and Bluetooth remain unavailable.."
            fi

        if  [ $Result -eq 0 ] ; then
         echo "`date -u` - Status Unchanged:   Device seemed to be down but is not (recheck). Do nothing and wait $LoopSleep seconds.."
         break
        fi

        sleep $DownStateRecheckTime
        done
    fi
  fi

  # Wait before running loop again
  sleep $LoopSleep

done

