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
from string import ascii_uppercase

class dev_lin:
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
									
class dev_dx:
	def __init__(self, ip, username, password):
		self.tn = 0
		self.ip = ip
		self.username = username
		self.password = password
		self.timeout = 1200
		self.connection = 0
		self.exp = "COMMAND EXECUTED"
		try:    #Try ssh:
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
	
	def set_timeout(self, t):
		self.timeout = t
			
	def tx(self, command, exp = None):			
		if exp is None:
			exp = self.exp
						
		ret = ""		
		try:
			if self.connection is 1:  #SSH
				chan = self.tn.invoke_shell()    
				chan.send(command + "\n\r")
				chan.settimeout(self.timeout)
				ret = ''
				while not exp in ret:				
					resp = chan.recv(9999)														
					ret += resp	
																				
			elif self.connection is 2: #Telnet
				time.sleep (2)							
				time.sleep(2)
				self.tn.write(command + "\r\n")
				ret = self.tn.read_until(exp, self.timeout)							
		except:
			print self.ip + ": Command execution failure!"
			ret = ""
			
		return ret
		
	def disconnect(self):
		if self.connection is 1:
			self.tn.close()
		elif self.connection is 2:
			try:
				self.tn.write("ZZZZ;\n\r")		
			except:
				print self.ip + " Disconnection failure!"			
										
class _file:
	def __init__(self, key):
		fn = str(time.time()).replace(".","")
		fn = fn + "_" + str(random.randint(1,10000))
		self.name = _dir(TMP_DIRE).get_name() + os.sep + key + "_" + fn + ".log"
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

if _dir(LOG_DIRE).exists():
	while True:
		rm_conf = raw_input("Directory " + LOG_DIRE + " already exists. \
		\nDo you want to remove it?\
		\nYes --> Remove the directory and subdirectories\n\
        and get all logs from beginner;\n\
		\nNo  --> Keep the directory and remove only the\n\
        subdirectories that contain \"_running\" on its name.\
		\n\nOption:")
		
		if "Yes" in rm_conf or "No" in rm_conf:	
			break;
		else:
			print "\nInvalid option. Please:  \"Yes\" or \"No\""
	
	if "Yes" in rm_conf:
		_dir(LOG_DIRE).remove()
		
	else:
		for fi in os.listdir(LOG_DIRE):
			if "_running" in fi or "_failed" in fi:
				try:
					shutil.rmtree(LOG_DIRE + os.sep + fi)
				except:
					print fi + " removal failed!"

#Create a temp directory:
_dir(TMP_DIRE).remove()
_dir(TMP_DIRE).create()
_dir(LOG_DIRE).create()			
				
#fng = dev_lin("fng", "fngsysadmin", "fngsysadmin")
#print fng.tx("show networking vrf name vrfsgi")
#fng.disconnect()

#fns = dev_dx("10.234.16.68", "SYSTEM", "SYSTEM")
#print fns.tx("ZUSI;")
#fns.disconnect()


bsc = dev_dx("10.20.0.2", "SYSTEM", "SYSTEM")
bsc.set_timeout(0.1)


f = _file("exemplo")
fp = f.get_fp()
fp.write(bsc.tx("ZQRI;"))
f.close()
f.remove()

bsc.disconnect()






#lin = dev_lin("10.2.1.4", "eduabati", "Cebola12#")
#print lin.tx("ls -lhat")
#lin.disconnect()

#tmp_file = _file("10.20.0.2")
#fp = open(tmp_file.get_name(), "wb")
#fp.write(bsc.tx("ZUSI:COMP;"))
#fp.close()
#bsc.disconnect()

#print _file("test").get_name()


