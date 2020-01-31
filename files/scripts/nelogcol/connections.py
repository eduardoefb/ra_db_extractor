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
import random
import datetime
import uuid
from string import ascii_uppercase

class dev_lin:
	def __init__(self, ip, username, password):
		self.name = ip
		if ":" in ip:
			self.ip = ip.split(":")[0]
			self.port = ip.split(":")[1]
		else:
			self.ip = ip
			self.port = 22   #Only ssh port is defined. Telnet will be kept 23	
					
		self.username = username
		self.password = password
		
		self.nbytes = 4096			
		self.tn = paramiko.Transport((self.ip, int(self.port)))
		self.tn.connect(username=username, password=password)	

	def set_name(self, name):
		self.name = name		
		
	def connect(self):
		self.tn = paramiko.Transport((self.ip, int(self.port)))
		self.tn.connect(username=self.username, password=self.password)		
		
	def disconnect(self):
		self.tn.close()
		
	def set_port(self, port):
		self.port = port
		
	def tx(self, command):
		try:
			self.disconnect()
		except:
			pass
			
		self.connect()
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command
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
		self.disconnect()	
		return ret

											
class dev_dx:
	def __init__(self, ip, username, password):
		self.tn = 0
		if ":" in ip:
			self.ip = ip.split(":")[0]
			self.port = ip.split(":")[1]
		else:
			self.ip = ip
			self.port = 22
					
		self.username = username
		self.password = password
		self.timeout = 9999
		self.connection = 0
		self.exp = "COMMAND EXECUTED"
		self.name = ip
		self.connect()
					
	def set_name(self, name, ):
		self.name = name
	
	def set_timeout(self, t):
		self.timeout = t
		
	def tx(self, command, exp = None):
		connected = False
		ret = ""
		try:
			self.connect()
			connected = True
		except: 
			return -1
			
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command
		if exp is None:
			exp = self.exp
					
		try:
			attempts = 5  #5 attempts
			att = 0
			while True:
				ret = self.send(command, exp)
				if att >= attempts:
					print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command + " FAILED!"
					ret = "COMMAND EXECUTION FAILED"
					break								
				if exp in ret:
					print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command + " SUCCESS!"
					break
				else:
					att += 1
					print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command + " FAILED. RETRYING (" + str(att) + " OF " + str(attempts) + ")!"
					try:
						self.reconnect()
					except:
						print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command + " RECONNECTION  FAILED!"
						ret = "COMMAND EXECUTION FAILED"
						break
		except:
			traceback.print_exc(file=sys.stdout)
			try:
				self.reconnect()
				ret = self.send(command, exp)
			except:
				traceback.print_exc(file=sys.stdout)
				print self.ip + " command execution failure!"
				print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + self.name + " " + command + " FAILED!"
				ret = "COMMAND EXECUTION FAILED"
					
		self.disconnect()
		return ret
				
	def send(self, command, exp):								
		ret = ""		
		connection_timeout = 5   #minutes
		#try:
		if self.connection is 1:  #SSH
			chan = self.tn.invoke_shell() 
			chan.settimeout(self.timeout)
			chan.send(command + "\n\r")			
			ret = ''
			
			tmout = time.time() + 60*connection_timeout			
			while not exp in ret:				
				if chan.recv_ready():
					resp = chan.recv(1000)													
					ret += resp					
				elif time.time() > tmout:					
					break
				
																												
		elif self.connection is 2: #Telnet
			time.sleep (2)							
			time.sleep(2)
			self.tn.write(command + "\r\n")
			ret = self.tn.read_until(exp, self.timeout)							
			
		return ret
		
	def sendlist(self, commands):
	#def sendlist(self, commands, exp):										
		ret = ""		
		connection_timeout = 5   #minutes
		#try:
		if self.connection is 1:  #SSH
			chan = self.tn.invoke_shell() 
			chan.settimeout(self.timeout)			
			for command, exp in commands:
				chan.send(command + "\n\r")	
				ret = ''				
				tmout = time.time() + 60*connection_timeout			
				while not exp in ret:				
					if chan.recv_ready():						
						resp = chan.recv(1000)						
						ret += resp					
					elif time.time() > tmout:					
						break	
							
		
		elif self.connection is 2: #Telnet
			for command, exp in commands:
				time.sleep (2)							
				time.sleep(2)
				self.tn.write(command + "\r\n")
				ret = self.tn.read_until(exp, self.timeout)											
			
		return ret		
		
	def connect(self):
		try:    #Try ssh:
			self.connection = 1
			self.tn = paramiko.SSHClient()
			self.tn.load_system_host_keys()
			self.tn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
			self.tn.connect(self.ip, port = int(self.port), username = self.username, password = self.password)
		
		except:   #If not ok, try telnet:
			traceback.print_exc(file=sys.stdout)
			try:
				self.tn = telnetlib.Telnet(self.ip)
				self.tn.read_until("ENTER USERNAM", 10)
				self.tn.write(self.username + "\n\r")
				self.tn.read_until("ENTER PASSWORD <", 10)
				self.tn.write(self.password + "\n\r")
				self.tn.read_until("WELCOME TO", 10)			
				self.connection = 2
			except:
				traceback.print_exc(file=sys.stdout)
				self.connection = -1
				print "Failure to connect to " + self.ip + " !"		
			
	def disconnect(self):
		if self.connection is 1:
			self.tn.close()
		elif self.connection is 2:
			try:
				self.tn.write("ZZZZ;\n\r")		
			except:
				print self.ip + " Disconnection failure!"			

	def reconnect(self):
		try:
			self.disconnect()
		except:
			a = 1
		self.connect()

class log:
	def __init__(self, name):			
		self.name = name	
					
	def write(self, stream):		
		self.fp = open(self.name, "ab")
		self.fp.write(stream)
		self.fp.close()
										
class _file:
	def __init__(self, key):
		fn = str(uuid.uuid4())		
		self.name = _dir(TMP_DIRE).get_name() + os.sep + fn + ".log"
		self.fp = open(self.name, "wb")
			
	def open(self):		
		self.fp = open(self.name, "rb")
		
	def clear(self):
		try:
			self.close()
		except:
			a = 1		
		self.fp = open(self.name, "wb")
						
	def get_fp(self):
		return self.fp
		
	def close(self):
		self.fp.close()
		
	def remove(self):
		try:
			os.remove(self.name)
		except:
			print self.name + " removal failure!"
	
	def get_name(self):
		return self.name
				
class _dir:
	def __init__(self, name):
		self.name = name
		self.create()
	
	def remove(self):
		if os.path.exists(self.name) and os.path.isdir(self.name):
			shutil.rmtree(self.name)
			
	def create(self):
		if not os.path.exists(self.name):
			os.mkdir(self.name)
			
	def get_name(self):
		return self.name
		
	def exists(self):
		if os.path.exists(self.name) and os.path.isdir(self.name):
			return True
		else:
			return False
			
#Global:  LOG_DIRE and TMP_DIRE
TMP_DIRE = "tmp"
LOG_DIRE = "logs"


#Example:  how to use:

#bsc = dev_dx("10.52.5.4", "SYSTEM", "FBSC4SYSTEM")
#bsc.set_timeout(0.5)
#print bsc.tx("ZUSI;")
#bsc.disconnect()

#Create a temp directory:
#_dir(TMP_DIRE).remove()
#_dir(TMP_DIRE).create()
#_dir(LOG_DIRE).create()			
				
#fng = dev_lin("fng", "fngsysadmin", "fngsysadmin")
#print fng.tx("show networking vrf name vrfsgi")
#fng.disconnect()

#fns = dev_dx("10.234.16.68", "SYSTEM", "SYSTEM")
#print fns.tx("ZUSI;")
#fns.disconnect()

#bsc = dev_dx("10.20.0.2", "SYSTEM", "SYSTEM")
#bsc.set_timeout(0.1)

#f = _file("exemplo")
#fp = f.get_fp()
#fp.write(bsc.tx("ZQRI;"))
#f.close()
#f.remove()

#bsc.disconnect()

#lin = dev_lin("10.2.1.4", "eduabati", "Cebola12#")
#print lin.tx("ls -lhat")
#lin.disconnect()

#tmp_file = _file("10.20.0.2")
#fp = open(tmp_file.get_name(), "wb")
#fp.write(bsc.tx("ZUSI:COMP;"))
#fp.close()
#bsc.disconnect()

#print _file("test").get_name()


#lin = dev_lin("10.2.1.30", "root", "42567154")
#print lin.tx("uname -a")
