#!/usr/bin/python

import getpass
import sys
import telnetlib
import os
import tempfile
import shutil
import time
import threading
import paramiko
import zipfile
import traceback
from random import choice
from string import ascii_uppercase

class device_fl:
	def __init__(self, ip, username, password):
		self.ip = ip
		self.username = username
		self.password = password
		self.port = 22
		self.nbytes = 4096			
		self.tn = paramiko.Transport((ip, self.port))
		self.tn.connect(username=username, password=password)	
		
	def disconnect(self):
		self.tn.close()
		
	def tx(self, command):
		session = self.tn.open_channel(kind='session')						
		
		stdout_data = []
		stderr_data = []
		session = self.tn.open_channel(kind='session')
		session.exec_command(command)
		ret = ""
		while True:
			if session.recv_ready():
				stdout_data.append(session.recv(self.nbytes))
			if session.recv_stderr_ready():
				stderr_data.append(session.recv_stderr(self.nbytes))
			if session.exit_status_ready():
				break		
		session.close()
		ret = ret.join(stdout_data)		
		return ret
									
		


class device_dx:
	def __init__(self, ip, username, password):
		self.tn = 0
		self.ip = ip
		self.username = username
		self.password = password
		self.timeout = 1200
		self.connection = 0
		self.exp = "COMMAND EXECUTED"
		try:
			self.connection = 1
			self.tn = paramiko.SSHClient()
			self.tn.load_system_host_keys()
			self.tn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
			self.tn.connect(ip, port=22, username=username, password=password)
		
		except:   #If not ok, try telnet:
			try:
				self.tn = telnetlib.Telnet(ip)
				self.tn.read_until("ENTER USERNAM", 10)
				self.tn.write(username + "\n\r")
				self.tn.read_until("ENTER PASSWORD <", 10)
				self.tn.write(password + "\n\r")
				self.tn.read_until("WELCOME TO", 10)			
				self.connection = 2
			except:
				self.connection = -1
				print "Failure to connect to " + self.ip + " !"
					
	def tx(self, command, exp = None):	
		if exp is None:
			exp = self.exp
			
		ret = ""
		if self.connection is 1:  #SSH
			chan = self.tn.invoke_shell()    
			chan.send(command + "\n\r")
			ret = ''
			while not exp in ret:
				resp = chan.recv(9999)
				ret += resp					
														
		elif self.connection is 2: #Telnet
			time.sleep (2)							
			time.sleep(2)
			self.tn.write(command + "\r\n")
			ret = self.tn.read_until(exp, self.timeout)							
				
		return ret
		
	def disconnect(self):
		if self.connection is 1:
			self.tn.close()
		elif self.connection is 2:
			try:
				self.tn.write("ZZZZ;\n\r")		
			except:
				print self.ip + " Disconnection failure!"			
										
			
#fng = device_fl("fng", "fngsysadmin", "fngsysadmin")
#print fng.tx("show networking vrf name vrfsgi")
#fng.disconnect()

#fns = device_dx("10.234.16.68", "SYSTEM", "SYSTEM")
#print fns.tx("ZUSI;")
#fns.disconnect()

bsc = device_dx("10.52.5.4", "SYSTEM", "FBSC4SYSTEM")
print bsc.tx("ZUSI:COMP;")	
bsc.disconnect()

