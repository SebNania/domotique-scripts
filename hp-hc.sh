#!/bin/bash
# Detect if we are in peak hour or not and send it to domoticz if needed
# By Sebastien Nania
# Created on 08/20/2016 ; Updated on le 08/20/2016
# Status : Online at Home

## Install ##
#  in /etc/rc.local :
# sh /path/to/your/script.sh & (the & is very important to fork the process and let it run in background, it prevent boot hangup if it was an error in the script or something else)

# Main Settings
DomoticzIP="127.0.0.1:8080"     # Your Domoticz IP address and port, port only if different from 80
HomeName="HomeNet"              # Name of your HomeAutomation system
# HC Start/Stop time in hourminutes without "h" or ":" exemple 1330 for 13:30
HC1Start="1234"
HC1Stop="1234"
HC2Start="1234"
HC2Stop="1234"
SleepTime="240"

# Sensors Settings
HCswIDX=12      # Switch for HC ON/OFF indication
HCalIDX=12      # Alert fort HC or not indication

# Waiting to let the raspberry boot
 sleep 30
while true
do

# Set currenttime var with the time like hhmm
currentTime=$(date +"%H%M")
if [ "$HC1Start" -le "$currentTime" -a "$currentTime" -le "$HC1Stop" ];
then
# Test line, uncomment if needed to see the answer in shell
# echo "Nous sommes en heures creuses"
curl -s "http://$DomoticzIP/json.htm?type=devices&rid=$HCswIDX" | grep Status | grep On > /dev/null
    if [ $? -eq 0 ] ; then
        # Do nothing device presence did not change
        echo "`date -u` - Status Unchanged:   Already on, do nothing and wait $SleepTime seconds.."
    else 
        # Domoticz status is different from the actual state, send the data to update
        echo "`date -u` - Status Changed:   Turning device ID $HCswIDX On"
        curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HCswIDX&switchcmd=On" > /dev/null
	curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HCalIDX&nvalue=1&svalue=Oui" > /dev/null
    fi
elif [ "$HC2Start" -le "$currentTime" -a "$currentTime" -le "$HC2Stop" ];
then
# Test line, uncomment if needed to see the answer in shell
# echo "Nous sommes en heures Creuses"
curl -s "http://$DomoticzIP/json.htm?type=devices&rid=$HCswIDX" | grep Status | grep On > /dev/null
    if [ $? -eq 0 ] ; then
        # Do nothing device presence did not change
        echo "`date -u` - Status Unchanged:   Already on, do nothing and wait $SleepTime seconds.."
    else 
        # Domoticz status is different from the actual state, send the data to update
        echo "`date -u` - Status Changed:   Turning device ID $HCswIDX On"
        curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HCswIDX&switchcmd=On" > /dev/null
	curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HCalIDX&nvalue=1&svalue=Oui" > /dev/null
    fi
else
# echo "Nous sommes en heures Pleines"
# Test line, uncomment if needed to see the answer in shell
curl -s "http://$DomoticzIP/json.htm?type=devices&rid=$HCswIDX" | grep Status | grep Off > /dev/null
    if [ $? -eq 0 ] ; then
        # Do nothing device presence did not change
        echo "`date -u` - Status Unchanged:   Already off, do nothing and wait $SleepTime seconds.."
    else 
        # Domoticz status is different from the actual state, send the data to update
        echo "`date -u` - Status Changed:   Turning device ID $HCswIDX Off"
        curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HCswIDX&switchcmd=Off" > /dev/null
	curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HCalIDX&nvalue=2&svalue=Non" > /dev/null
    fi
fi
sleep $SleepTime
done 
