#!/bin/bash
# Load and store Holyday status of the day ; i've add a lot of others information to load like schoolholidays, weekend, sun zenith and sunday duration
# By Sebastien Nania
# Created on 17/15/2016 ; Updated on le 18/15/2016
# Status : Draft

# Main Settings
DomoticzIP="127.0.0.1:8080"                             # Your Domoticz IP address and port, port only if different from 80
tmpfile="/home/pi/tempraw.json"                         # Enter here the temp file path
SchoolZone="b"                                          # Enter here the School Zone
TomorrowDate=$(date --date="next day" "+%d-%m-%Y")      # Setting Var Tomorrow Date

# Sensors Settings
HolidaySWIDX=46
HolidayIDX=45
WeekendIDX=47
SchoolHolidaySWIDX=48
SchoolHolidayIDX=49
SeasonIDX=50
WeekIDX=51
HolidayTSWIDX=53
HolidayTIDX=52
WeekendTIDX=54
SchoolHolidayTSWIDX=55
SchoolHolidayTIDX=56
SunZenithIDX=57
SunDayDurationIDX=58

# Loading data into a json tmp file and extract wanted data to create some var
    # Loading Holiday (all type) for today and parse it to send to domoticz
curl -s "http://domogeek.entropialux.com/holidayall/$SchoolZone/now" > $tmpfile		        # Loading holidayall data from domogeek and store into a tmp file
Holiday=$(cat $tmpfile | jq -r '.holiday')					                # Set Var Holiday
Weekend=$(cat $tmpfile | jq -r '.weekend')					                # Set Var Weekend
SchoolHoliday=$(cat $tmpfile | jq -r '.schoolholiday')				                # Set Var SchoolHoliday
rm -rf $tmpfile
    # Loading Holiday (all type) for today and parse it to send to domoticz
curl -s "http://domogeek.entropialux.com/holidayall/$SchoolZone/$TomorrowDate" > $tmpfile       # Loading holidayall data from domogeek and store into a tmp file
HolidayT=$(cat $tmpfile | jq -r '.holiday')					                # Set Var HolidayT
WeekendT=$(cat $tmpfile | jq -r '.weekend')					                # Set Var WeekendT
SchoolHolidayT=$(cat $tmpfile | jq -r '.schoolholiday')				                # Set Var SchoolHolidayT
rm -rf $tmpfile
    # Loading Sun infos and parsing it to send to domoticz later (only Zenith and DayDuration needed)
curl -s "http://domogeek.entropialux.com/sun/la_jarrie/all/now" > $tmpfile	                # Loading sun data from domogeek and store into a tmp file
Sunset=$(cat $tmpfile | jq -r '.sunset')					                # Set Var Sunset
Sunrise=$(cat $tmpfile | jq -r '.sunrise')					                # Set Var Sunrise
Zenith=$(cat $tmpfile | jq -r '.zenith')                                                        # Set Var Zenith
DayDuration=$(cat $tmpfile | jq -r '.dayduration')				                # Set Var Dayduration
rm -rf $tmpfile
    # Send Sun data to domoticz
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SunZenithIDX&nvalue=0&svalue=$Zenith" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SunDayDurationIDX&nvalue=0&svalue=$DayDuration" > /dev/null

# Find the actual week number and send it to Domoticz
Week=$(date +%W)
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$WeekIDX&nvalue=0&svalue=$Week" > /dev/null

# Loading Season and translate in french then send it to domoticz
Season=$(curl -s "http://domogeek.entropialux.com/season")                      # Loading Season data from domogeek and store into a tmp file

if [ $Season = spring ] ; 
then
	Season=Printemps
elif [ $Season = summer ] ;
then
	Season=Ete
elif [ $Season = autumn ] ;
then
	Season = Automne
elif [ $Season = Winter ] ;
then
	Season=Hiver
else
	Season=Erreur
fi
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SeasonIDX&nvalue=0&svalue=$Season" > /dev/null

# Modify and send Holiday (All type) to DomoticZ
    # Replace " " by "%20" in result of Holiday and SchoolHoliday before store in Domoticz
HolidayWeb=$(echo $Holiday | sed -e 's/ /%20/g')
SchoolHolidayWeb=$(echo $SchoolHoliday | sed -e 's/ /%20/g')

# Send Holiday data to domoticz
if [ "$Holiday" = False ] ; then
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HolidaySWIDX&switchcmd=Off" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HolidayIDX&nvalue=0&svalue=Non" > /dev/null
else
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HolidaySWIDX&switchcmd=On" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HolidayIDX&nvalue=0&svalue=$HolidayWeb" > /dev/null
fi

# Send Weekend Data to domoticz
if [ $Weekend = False ] ; then
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$WeekendIDX&switchcmd=Off" > /dev/null
else
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$WeekendIDX&switchcmd=On" > /dev/null
fi

# Send Schoolholiday data to domoticz
if [ "$SchoolHoliday" = False ] ; then
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$SchoolHolidaySWIDX&switchcmd=Off" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SchoolHolidayIDX&nvalue=0&svalue=Non" > /dev/null
else
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$SchoolHolidaySWIDX&switchcmd=On" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SchoolHolidayIDX&nvalue=0&svalue=$SchoolHolidayWeb" > /dev/null
fi

# Modify and send Tomorrow Holiday (All type) to DomoticZ
    # Replace " " by "%20" in result of Holiday and SchoolHoliday before store in Domoticz
HolidayTWeb=$(echo $HolidayT | sed -e 's/ /%20/g')
SchoolHolidayTWeb=$(echo $SchoolHolidayT | sed -e 's/ /%20/g')
    # Test and send data to domoticZ
if [ "$HolidayT" = False ] ; then
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HolidayTSWIDX&switchcmd=Off" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HolidayTIDX&nvalue=0&svalue=Non" > /dev/null
else
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$HolidayTSWIDX&switchcmd=On" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$HolidayTIDX&nvalue=0&svalue=$HolidayTWeb" > /dev/null
fi
    # Test and send data to domoticZ
if [ $WeekendT = False ] ; then
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$WeekendTIDX&switchcmd=Off" > /dev/null
else
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$WeekendTIDX&switchcmd=On" > /dev/null
fi

if [ "$SchoolHolidayT" = False ] ; then
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$SchoolHolidayTSWIDX&switchcmd=Off" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SchoolHolidayTIDX&nvalue=0&svalue=Non" > /dev/null
else
curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$SchoolHolidayTSWIDX&switchcmd=On" > /dev/null
curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$SchoolHolidayTIDX&nvalue=0&svalue=$SchoolHolidayWebT" > /dev/null
fi

#Model Text Sensor
#curl -s "http://$DomoticzIP/json.htm?type=command&param=udevice&idx=$IDX&nvalue=0&svalue=$TEXTE"
#Model Switch Sensor
#curl -s "http://$DomoticzIP/json.htm?type=command&param=switchlight&idx=$IDX&switchcmd=Off/On"
