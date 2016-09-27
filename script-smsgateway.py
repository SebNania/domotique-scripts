#!/usr/bin/python
# Based on the excellent work of vil1driver
# Used to send notification by SMS using the "SMS Gateway Ultimate" android app
# INSTALLATION #
# Put this file in /path/to/domoticz/scripts/python
# Add this in the "HTTP/URLAction" of domoticz parameters :
# script:///path/to/domoticz/scripts/python/script-smsgateway.py #MESSAGE
# -*- coding: utf-8 -*-
# it need the requests module, install it with :
# sudo pip install requests

import requests
import os
import sys

#~~~~~~~~~~Phone numbers to send SMS to~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
phones=['PhoneNumber1','PhoneNumber2']

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~SMS Gateway Ultimate parameters~~~~~~~~~~~~~~~~~~~~~~~~~~~

ip_sms_gateway='192.168.0.xyz'
port_sms_gateway='12345'


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if len(sys.argv)==1:
	message= 'message de Domoticz'
else:
	message = sys.argv[1]


def send_sms (tel,message):
#http://192.168.x.y:12345/send.html?smsto=06XXXXXX&smsbody=tets&smstype=sms
	requetesms='http://'+ip_sms_gateway+':'+port_sms_gateway+'/send.html?'+'smsto='+tel+'&smsbody='+message+'&smstype=sms'
	r = requests.get(requetesms)
	print (r.url)


for tel in phones:
	#print (tel)
	send_sms(tel,message)
