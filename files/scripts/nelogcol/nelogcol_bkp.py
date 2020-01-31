#!/usr/bin/python

from connections import _dir, _file, dev_dx, dev_lin, TMP_DIRE, LOG_DIRE
from dxipa import dxipa
from dxipa import mcrnc
import threading
import datetime
import time
import os
import shutil
import zipfile
import sys, traceback
from os import listdir
from os.path import isfile, join

class ne:
	def __init__(self):
		return
	
	def set_ip(self, ip):
		self.ip = ip
	
	def set_port(self, port):
		self.port = port
	
	def set_type(self, _type):
		self._type = _type
	
	def set_user(self, _user):
		self._user = _user
	
	def set_password(self, _password):
		self._password = _password
	
	def get_ip(self):
		return self.ip
	
	def get_type(self):
		return self._type
	
	def get_user(self):
		return self._user
	
	def get_password(self):
		return self._password
	
	def get_all(self):
		print "IP      : " + self.ip
		print "Port    : " + self.port
		print "Type    : " + self._type
		print "User    : " + self._user
		print "Password: " + self._password
		

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


def get_running(dire):	
	running = 0
	for d in listdir(dire + "/"):
		if "_running" in d:
			running += 1
	
	return running
		

def getDateString():
	year = time.localtime().tm_year
	mon = time.localtime().tm_mon
	day = time.localtime().tm_mday
	
	if mon < 10:
		mon_str = "0" + str(mon)
	else:
		mon_str = str(mon)

	if day < 10:
		day_str = "0" + str(day)
	else:
		day_str = str(day)
	
	return str(year) + mon_str + day_str

def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))

#Create a temp directory:
_dir(TMP_DIRE).remove()
_dir(TMP_DIRE).create()
_dir(LOG_DIRE).create()

#Get ne list from ne.csv
nelist = []
fp = open("ne.csv", "rb")
max_sim_running = 10
for l in fp.readlines():
	if "#MAX_SIM_NE=" in l:
		max_sim_running = int(l.replace("#MAX_SIM_NE=", "").strip())
	if not l.startswith("#"):		
		par_cont = 0
		for p in l.strip().split(","):
			par_cont += 1
		
		if par_cont is 4:			
			_ne = ne()			
			_ne.set_ip(l.strip().split(",")[0])
			_ne.set_type(l.strip().split(",")[1])
			_ne.set_user(l.strip().split(",")[2])
			_ne.set_password(l.strip().split(",")[3])
			nelist.append(_ne)

for _ne in nelist:
	try:		
		if _ne.get_type() == "DX200" or _ne.get_type() == "IPA2800":
			dx_thread = threading.Thread(target = dxipa, args = (_ne.get_ip(), _ne.get_user(), _ne.get_password()))
			dx_thread.start()

		if _ne.get_type() == "mcRNC":
			dx_thread = threading.Thread(target = mcrnc, args = (_ne.get_ip(), _ne.get_user(), _ne.get_password()))
			dx_thread.start()
						
		time.sleep(10)
		while get_running(LOG_DIRE) >= max_sim_running:
			print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + str(get_running(LOG_DIRE)) + " running elements, waiting..."
			time.sleep(10)
					
	except:
		print _ne.get_ip() + " connection failure!"
	
	time.sleep(5)
	
	
		

time.sleep(10)
	
while True:
	running = False
	for d in listdir(LOG_DIRE):
		if "_running" in d:
			running = True
			break
	
	if running == False:
		break
	
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " Waiting for elements that are still running..."
	time.sleep(10)

zipf = zipfile.ZipFile(LOG_DIRE + os.sep + "NELogs_" + getDateString() + ".zip", 'w',  zipfile.ZIP_DEFLATED)

os.chdir(LOG_DIRE)
for f in listdir("."):	
	if not(isfile(join(LOG_DIRE, f))):
		try:
			zipdir(f, zipf)
		except:
			print "Error on " + f + " zip attempt!"

		try:
			shutil.rmtree(f)
		except:
			print "Error on " + f + " deletion attempt!"
			
zipf.close()			
		

print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " Finished!"



