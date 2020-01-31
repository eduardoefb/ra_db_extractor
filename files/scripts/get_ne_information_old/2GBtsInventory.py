#!/usr/bin/python

import getpass
import sys
import telnetlib
import os
import tempfile
import shutil
import time
import threading
import zipfile
import re
from random import choice
from string import ascii_uppercase

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

def dx_connect(ip, usr, pwd):
	tn = 0			
	try:
		tn = telnetlib.Telnet(ip, 23, 20)
		tn.read_until("ENTER USERNAME <", 10)
		tn.write(usr + "\r\n")
		tn.read_until("ENTER PASSWORD <", 10)	
		tn.write(pwd + "\r\n")		
		file_tmp = tmp_local_file(ip)	
		fp = open(file_tmp, "wb")
		fp.write(tn.read_until("WELCOME TO THE", 10))
		fp.close()
		fp = open(file_tmp, "rb")		 
		for l in fp.readlines():
			if "USER AUTHORIZATION FAILURE" in l or "DELAY OF" in l or "DELAY APPLIED" in l:
				fp.close()
				os.remove(file_tmp)
				print ip + " user authorization failure!"
				return None		
		fp.close()
		os.remove(file_tmp)		
	except:		
		return None
	return tn
	
def dx_disconnect(tn):
	tn.write("ZZZZ;\n\r")
	
def tmp_local_file(name):		
	fn = str(time.time()).replace(".","")	
	tmpfile = "tmp" + os.sep + name + "_" + fn
	return tmpfile

def tmp_string(name):		
	fn = str(time.time()).replace(".","")	
	tmpfile = name + "_" + fn
	return tmpfile

	
#Send dx200 command via telnet
def send_dx_command(tn, cmd, exp):
	time.sleep (2)
	timeout = 1200
	tn = telnetlib.Telnet(ip)
	tn.read_until("ENTER USERNAME <")
	tn.write(usr + "\r\n")
	tn.read_until("ENTER PASSWORD <")	
	tn.write(pwd + "\r\n")
	i = 0
	ret = ""
	for c in cmd:
		try:
			time.sleep(2)
			tn.write(c + "\r\n")
			ret = ret + tn.read_until(exp[i], timeout)
		except:
			try:
				time.sleep(2)
				tn.write(c + "\r\n")	
				ret = ret + tn.read_until(exp[i], timeout)				
			except:				
				ret = ret + cmd[i] + " Command execution failed!"				
				
		i = i + 1										
	return ret
	
def send_dx_command_log(tn, cmd, exp, log, name):
	i = 0
	timeout = 7200
	for c in cmd:
		print name + " " + c
		try:
			time.sleep(2)
			tn.write(c + "\r\n")
		except:
			try:
				time.sleep(2)
				tn.write(c + "\r\n")			
			except:
				print name + " " + c + " command execution failed!"
				return
				
		ret = tn.read_until(exp[i], timeout)
		fp = open(log[i], "wb")
		fp.write(ret)
		fp.close()		
		i = i + 1
	
def get_ne_type(tn, ip):
	file_tmp = tmp_local_file(ip)
	ret = "-"	
	fp = open(file_tmp, "wb")
		
	fp.write(send_dx_command(tn, ["ZZ?"], ["Z; .... END"]))
	fp.close()
	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():
		if "-" in line and ":" in line:
			ret = line[0:9].strip()
			
	fp.close()
	os.remove(file_tmp)
	return ret;
	
def get_ne_name(tn, ip):	
	file_tmp = tmp_local_file(ip)	
	ret = "-"
	fp = open(file_tmp, "wb")
	fp.write(send_dx_command(tn, ["ZZ?"], ["Z; .... END"]))
	fp.close()
	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():
		if "-" in line and ":" in line:
			ret = line[10:25].strip()
			
	fp.close()
	os.remove(file_tmp)	
	name = ret.split(" ")[0].strip();
	name = strip_non_ascii(name)
	return name
	
	
def strip_non_ascii(string):
    ''' Returns the string without non ASCII characters'''
    stripped = (c for c in string if 0 < ord(c) < 127)
    return ''.join(stripped)	
			
class bsc:
	
	def __init__(self, ip, tn, name, logdir):
		#Define workdir:		
		self.tn = tn
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		if not os.path.exists(workdir):
			os.mkdir(workdir)
						
		#Get all bts on bsc:						
		send_dx_command_log(tn, ["ZEEI;"] , ["COMMAND EXECUTED"], [workdir + os.sep + "ZEEI.log"], name)
		
		fp = open(workdir + os.sep + "ZEEI.log", "rb")
		for line in fp.readlines():
			if "BCF-" in line:				
				bcf = line.split(" ")[0].replace("BCF-", "")				
				self.get_hw_inv(bcf)													
		
		dx_disconnect(tn)
		print name + " Finished!"
		workdir_finished = workdir.replace("_running","")
		os.rename(workdir, workdir_finished)
		
	def get_hw_inv(self, bcf):		
		
		#Get D-CHANNEL
		l = send_dx_command(self.tn, ["ZEFO:" + bcf + ";"], ["COMMAND EXECUTED"])
		lines = re.split('\n', l)
		for ll in lines:
			if "D-CHANNEL LINK SET" in ll:
				dchannel = ll[20:24].strip()
				
		#Get BCSU/BCXU:
		l = send_dx_command(self.tn, ["ZEEI:BCF=" + bcf + ";"], ["COMMAND EXECUTED"])
		lines = re.split('\n', l)
		for ll in lines:
			if "BCF-" in ll:
				bcsu = ll[57:64].strip().replace("X","").strip()
				dch_state =  ll[70:73].strip().replace("X","").strip()
				
		if "WO" in dch_state:
			print "BCF = " + bcf + " Dchannel = " + dchannel + " BCSU = " + bcsu + " DCH State = " + dch_state
			
			#Get BCSU Type (BCXU or BCSU):
			l = send_dx_command(self.tn, ["ZUSI:COMP;"], ["COMMAND EXECUTED"])
			bcsu_t = ""
			if "BCSU-" in l:
				bcsu_t = "BCSU"
			elif "BCXU-" in l:
				bcsu_t = "BCXU"
				
			#Get BCSU MB addr:
			l = send_dx_command(self.tn, ["ZUSI:" + bcsu_t + "," + bcsu + ";" ], ["COMMAND EXECUTED"])
			lines = re.split('\n', l)
			for ll in lines:
				if bcsu_t + "-" in ll:					
					mbaddr = ll.split()[1]
					
					
			cmdlist = ["ZDDS:" + bcsu_t + "," + bcsu + ";",
				"ZGSC",
				"ZZE"]
				
			explist = [ "-MAN>", "-LOG>", "COMMAND EXECUTED"]
			l = send_dx_command(tn, cmdlist, explist)
			lines = re.split("\n", l)
			for ll in lines:
				print ll

		
		
		
		
			    
						
#user = raw_input("Enter your remote account: ")
#password = getpass.getpass()
try:
	nelst = open("ne.csv", "r")

except:
	
	raw_input("File ne.csv doesn't exist.  Please, generate this file and start it again.\n \
	\nExample of ne.csv content: \n \
	\n10.222.10.11,DX200,SYSTEM,SYSTEM \
	\n10.222.10.12,IPAD200,USERNAME,PASSWORD \
	\n10.222.10.13,mcRNC,_nokadmin,system\n \
	\n")
	
	sys.exit()

tot = 0
for n in nelst.readlines():
	tot += 1
	
nelst.close()

#Create a temp directory:
if os.path.exists("tmp"):
	shutil.rmtree("tmp")
	
if os.path.exists("logs"):
	shutil.rmtree("logs")

	
os.mkdir("tmp")
max_sim_thread = 50
	
#Create the log directory:
if not os.path.exists("logs"):
	os.mkdir("logs")
		
wait_time = 30
curr = 0
dir_tot = 0
dir_list = {}
nelst = open("ne.csv", "r")
for line in nelst.readlines():
	curr += 1
	if not line.startswith("#"):		
		ip = line.split(",")[0]
		plat = line.split(",")[1]
		usr = line.split(",")[2]
		pwd = line.split(",")[3]			
		logname = "logs"
		if "DX200" in plat:
			print "(" + str(curr) + " of " + str(tot) + ") Openning telnet connection to " + ip + "..."
			tn = dx_connect(ip, usr, pwd)
			if tn:
				print "Connection to " + ip + " established!"
				print "Getting " + ip + " element type..."
				ne_type = get_ne_type(tn, ip)								
				print ip + " is " + ne_type
				ne_name = get_ne_name(tn, ip)
				print ip + " is " + ne_type + " and its name is " + ne_name

				#Add ne_name to dir list, to be zipped later:
				dir_tot += 1
				dir_list[dir_tot] = ne_name			

				if "BSC" in ne_type:				
					bsc_thread = threading.Thread(target=bsc, args=(ip, tn, ne_name, logname))
					bsc_thread.start()
									
				print "Connection to " + ip + " failed!"
		
		running = max_sim_thread
		
		#Wait threads
		while running >= max_sim_thread:
			nn = 0
			for t in threading.enumerate():
				nn = nn + 1
				running = nn
				if running >= max_sim_thread:
					print "Processed NEs: " + str((curr - 1)) + " of " + str(tot)
					time.sleep(wait_time)


nn = 10
while nn > 1:
	nn = 0
	for t in threading.enumerate():
		nn = nn + 1
	
	time.sleep(10)

#Remove the temp directory:
if os.path.exists("tmp"):
	shutil.rmtree("tmp")
	
#After that, zip the log directories and remove them

#zipf = zipfile.ZipFile("logs" + os.sep + "NELogs_" + getDateString() + ".zip", 'w',  zipfile.ZIP_DEFLATED)
#os.chdir("logs")

#for x in range(1, (dir_tot + 1)):
#	try:		
		#zipdir(dir_list[x], zipf)
	#except:
		#print "Error on " + dir_list[x] + " zip attempt!"
#		
	#try:
		#shutil.rmtree(dir_list[x])
	#except:
		#print "Error on " + dir_list[x] + " deletion attempt!"
	   
#zipf.close()
		
	
raw_input("Script has been finished!")


