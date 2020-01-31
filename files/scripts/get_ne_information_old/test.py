#!/usr/bin/python

"""
Network element log collector version 0.0.1  2016/03/07

Suports: BSC, RNC, Flexi NS
"""

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

def copy_sftp_file(ip, user, pwd, remotePath, localPath):
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
	try:
		ssh.connect(ip,username=user,password=pwd)
		### Copy remote file to server        
		sftp = ssh.open_sftp()
		sftp.get(remotePath,localPath)
		sftp.close()
		ssh.close()
		return ["OK",0,0]
	except IOError as e:
		traceback.print_exc()
		flash(str(e)+" IOERROR")
		return ["IOERROR: " + str(e),0,0]
	except Exception as e:
		traceback.print_exc()
		flash(str(e)+" OTHER EXCEPTION")
		return ["Error: " + str(e),0,0]    

def ssh_connect(ip, usr, pwd):
	nbytes = 4096
	hostname = ip
	port = 22
	username = usr
	password = pwd
	
	client = paramiko.Transport((hostname, port))
	client.connect(username=username, password=password)
	return client
		
def ssh_disconnect(client):
	client.close()
	
def ssh_command_log(client, cmdlist, loglist, name):

	i = 0
	nbytes = 4096
	session = client.open_channel(kind='session')
	
	for command in cmdlist:
		print name + " " + command
		stdout_data = []
		stderr_data = []
		session = client.open_channel(kind='session')
		session.exec_command(command)
		while True:
			if session.recv_ready():
				stdout_data.append(session.recv(nbytes))
			if session.recv_stderr_ready():
				stderr_data.append(session.recv_stderr(nbytes))
			if session.exit_status_ready():
				break
				
		fp = open(loglist[i], "wb")
		fp.write(''.join(stdout_data))
		fp.close()		
		i = i + 1
								
	session.close()

def chk_fhascli(client):
	cmdl = ["uname -a"]
	if "Linux" in ssh_command(client, cmdl):
		return False
		
	return True
	
def ssh_command(client, cmdlist):

	i = 0
	nbytes = 4096

	ret = ""
	for command in cmdlist:
		stdout_data = []
		stderr_data = []
		session = client.open_channel(kind='session')
		session.exec_command(command)
		while True:
			if session.recv_ready():
				stdout_data.append(session.recv(nbytes))
			if session.recv_stderr_ready():
				stderr_data.append(session.recv_stderr(nbytes))
			if session.exit_status_ready():
				break					
		ret = ret.join(stdout_data)										
	session.close()
	return ret

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
		traceback.print_exc()
		return None
	return tn
	
def dx_disconnect(tn):
	tn.write("ZZZZ;\n\r")
	
def tmp_local_file(name):		
	fn = str(time.time()).replace(".","")	
	tmpfile = TMP_DIRE + os.sep + name + "_" + fn
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
		time.sleep(2)
		tn.write(c + "\r\n")
		ret = ret + tn.read_until(exp[i], timeout)
				
		i = i + 1										
	return ret
	
	
def chk_command(tn, cmd, name):
	file_tmp = tmp_local_file(name + "_" + cmd[1:4])
	ret = False
	fp = open(file_tmp, "wb")			
	fp.write(send_dx_command(tn, [cmd[0:3] + "?;"], ["<" + cmd[1:3] + "_>"]))
	fp.close()	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():
		if (cmd[3:4] + ": " in line) or (cmd[3:4] + "; " in line) :
			ret = True
			break	
	fp.close()	
	os.remove(file_tmp)		
	return ret
	
#def send_dx_command_log(tn, cmd, exp, log, name):
#	i = 0
#	timeout = 21600
#	for c in cmd:
#		print name + " " + c
#		time.sleep(2)
#		tn.write(c + "\r\n")			
#		ret = tn.read_until(exp[i], timeout)
#		fp = open(log[i], "wb")
#		fp.write(ret)
#		fp.close()									
#		i = i + 1
		
def send_dx_command_log(inf):		
	try:
		for x in inf:		
			tn = x[0]
			cmd = x[1]		
			log = x[2]
			exp = x[3]
			name = x[4]
			timeout = x[5]					
			print name + " " + cmd
			time.sleep(2)
			tn.write(cmd + "\r\n")			
			ret = tn.read_until(exp, timeout)
			fp = open(log, "ab")
			fp.write(ret)
			fp.close()
	except:
		traceback.print_exc()
		pass
	
			
	
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
    """ Returns the string without non ASCII characters"""
    stripped = (c for c in string if 0 < ord(c) < 127)
    return ''.join(stripped)	
			
							
class fns:	
	def __init__(self, ip, tn, name, logdir):
		#Define workdir:		
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		try:
			if not os.path.exists(workdir):
				os.mkdir(workdir)
		except:
			print "Error on directory " + workdir + " creation! "
			traceback.print_exc()
			return
			
					
		try:			
			#FNS_IP file:
			fp = open(workdir + os.sep + "FNS_IP", "wb")
			fp.write(ip)
			fp.close()

			#ELEMENT_TYPE file:
			fp = open(workdir + os.sep + "ELEMENT_TYPE", "wb")
			fp.write("FlexiNS")
			fp.close()
			
			#FNS_NAME file:
			fp = open(workdir + os.sep + "FNS_NAME", "wb")
			fp.write(name)
			fp.close()
			
			inf = []
			inf.append([tn, "ZUSI;", workdir + os.sep + "ZUSI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQNI;", workdir + os.sep + "ZQNI.log", "COMMAND EXECUTED", name, 21600])			
			inf.append([tn, "ZDOI::M;", workdir + os.sep + "ZDOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQO:CR;", workdir + os.sep + "ZWQO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOI;", workdir + os.sep + "ZWOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOS;", workdir + os.sep + "ZWOS.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQO:CR;", workdir + os.sep + "ZWQO.log", "COMMAND EXECUTED", name, 21600])			
			inf.append([tn, "ZW7I:FEA,FULL:FSTATE=ON;", workdir + os.sep + "ZW7IFULL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:LIC,FULL;", workdir + os.sep + "ZW7ILIC.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:UCAP;", workdir + os.sep + "ZW7IUCAP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWTI:P;", workdir + os.sep + "ZWTIP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZNET;", workdir + os.sep + "ZNET.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWVI;", workdir + os.sep + "ZWVI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEJH;", workdir + os.sep + "ZEJH.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZMXP;", workdir + os.sep + "ZMXP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZCFI:::ALL;", workdir + os.sep + "ZCFI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQRI;", workdir + os.sep + "ZQRI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWTI:PI;", workdir + os.sep + "ZWTI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZUSI;", workdir + os.sep + "ZUSI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZKAI;", workdir + os.sep + "ZKAI.log", "COMMAND EXECUT", name, 21600])
			inf.append([tn, "ZNBI;", workdir + os.sep + "ZNBI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQRJ;", workdir + os.sep + "ZQRJ.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZTPI;", workdir + os.sep + "ZTPI.log", "COMMAND EXECUTED", name, 21600])			
			send_dx_command_log(inf)
												
			inf = []		
			fp = open(workdir + os.sep + "ZMXP.log", "r")
			plmn_s = False
			for l in fp.readlines():	
				if "PLMN NAME" in l:
					plmn_s = True
				elif len(l.strip()) < 1:
					plmn_s = False
				elif l.strip() is "COMMAND EXECUTED":
					plmn_s = False
					break
				elif not "--" in l  and plmn_s:						
					inf.append([tn, "ZMXP:" + l.strip().split()[0] + ",ALL;", workdir + os.sep + "ZMXP_FULL.log", "COMMAND EXECUTED", name, 21600])
					fp.close()
			
			#Only 2G related commands:
			if self.has2g(workdir + os.sep + "ZUSI.log"):				
				inf.append([tn, "ZKAO;", workdir + os.sep + "ZKAO.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZFWO:NSEI=0&&65535;", workdir + os.sep + "ZFWO.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZEJL:NSEI=0&&65535;", workdir + os.sep + "ZEJL.log", "COMMAND EXECUTED", name, 21600])
			
			
			#Only 3G related commands:	
			if self.has3g(workdir + os.sep + "ZUSI.log"):
				inf.append([tn, "ZE6I;", workdir + os.sep + "ZE6I.log", "COMMAND EXECUTED", name, 21600])				
				inf.append([tn, "ZE6I::RT=ALL;", workdir + os.sep + "ZE6I_FULL.log", "COMMAND EXECUTED", name, 21600])				
				inf.append([tn, "ZE5I;", workdir + os.sep + "ZE5I.log", "COMMAND EXECUTED", name, 21600])
			
				
			#Only common 2G and 3G commands:
			if self.has3g(workdir + os.sep + "ZUSI.log") or self.has2g(workdir + os.sep + "ZUSI.log"):
				inf.append([tn, "ZFWI:PGI=;", workdir + os.sep + "ZFWIPGI.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZFWI:PAPU=;", workdir + os.sep + "ZFWIPAPU.log", "COMMAND EXECUTED", name, 21600])				
				inf.append([tn, "ZOPJ;", workdir + os.sep + "ZOPJ.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZGHI;", workdir + os.sep + "ZGHI.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZGHH;", workdir + os.sep + "ZGHH.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZKAQ:INT:LIA=SGSN;", workdir + os.sep + "ZKAQ_SGSN.log", "COMMAND EXECUTED", name, 21600])
			

			#Only commands related to MME:
			if self.has4g(workdir + os.sep + "ZUSI.log"):			
				inf.append([tn, "ZKAQ:INT:LIA=MME;", workdir + os.sep + "ZKAQ_MME.log", "COMMAND EXECUTED", name, 21600])				
				inf.append([tn, "ZB6I;", workdir + os.sep + "ZB6I.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZB6I::RT=FULL;", workdir + os.sep + "ZB6I_FULL.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZB6O:TAMAP;", workdir + os.sep + "ZB6O.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZOHI:::FULL;", workdir + os.sep + "ZOHI.log", "COMMAND EXECUTED", name, 21600])
				inf.append([tn, "ZBIV:INT;", workdir + os.sep + "ZBIV.log", "COMMAND EXECUTED", name, 21600])														
			send_dx_command_log(inf)
																																																																																																		
			dxipa().get_file(name, tn, workdir, "ASWDIR", "W0-ASWDIR/*.INI", ip)
			dxipa().get_file(name, tn, workdir, "FNSINI", "W0-ASWDIR/FNSINI/*.*", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/T4IL*.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/TA1LSTNX.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/FXC*NX.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/XIPIF*.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/POCIP*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/PRFI*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/FIFI*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LICENCE", "W0-LICENCE/*.XML", ip)
											
			dx_disconnect(tn)
			ssh_disconnect(tn)
			time.sleep(10)
			print name + " Finished!"		
			workdir_finished = workdir.replace("_running","")
			try:
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir
				traceback.print_exc()
		except:
			print name + " Failed!"	
			traceback.print_exc()
			workdir_finished = workdir.replace("_running","_failed")
			try:
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir
					
	def has2g(self, zusi_log):				
		ret = False
		fp = open(zusi_log, "rb")
		for l in fp.readlines():
			if ("GBU-" in l) and ("WO-EX" in l):
				ret = True
				break				
		fp.close()
		return ret
		
		
	def has3g(self, zusi_log):
		ret = False
		fp = open(zusi_log, "rb")
		for l in fp.readlines():
			if ("IPPU-" in l) and ("WO-EX" in l):
				ret = True
				break				
		fp.close()
		return ret		

	def has4g(self, zusi_log):
		ret = False
		fp = open(zusi_log, "rb")
		for l in fp.readlines():
			if ("IPDU-" in l) and ("WO-EX" in l):
				ret = True
				break				
		fp.close()
		return ret	
		
		
		

				
				
					
			
class sgsn:
	
	def __init__(self, ip, tn, name, logdir):
		#Define workdir:		
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		try:
			if not os.path.exists(workdir):
				os.mkdir(workdir)
		except:
			print "Error on directory " + workdir + " creation! "
			return

		try:
			#RNC_IP file:
			fp = open(workdir + os.sep + "SGSN_IP", "wb")
			fp.write(ip)
			fp.close()

			#ELEMENT_TYPE file:
			fp = open(workdir + os.sep + "ELEMENT_TYPE", "wb")
			fp.write("SGSN")
			fp.close()
			
			#RNC_NAME file:
			fp = open(workdir + os.sep + "SGSN_NAME", "wb")
			fp.write(name)
			fp.close()
		
			inf = []
			inf.append([tn, "ZUSI;", workdir + os.sep + "ZUSI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQNI;", workdir + os.sep + "ZQNI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDOI::M;", workdir + os.sep + "ZDOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQO:CR;", workdir + os.sep + "ZWQO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOI;", workdir + os.sep + "ZWOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOS;", workdir + os.sep + "ZWOS.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQO:CR;", workdir + os.sep + "ZWQO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:FEA,FULL:FSTATE=ON;", workdir + os.sep + "ZW7IFULL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:LIC,FULL;", workdir + os.sep + "ZW7ILIC.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:UCAP;", workdir + os.sep + "ZW7IUCAP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWTI:P;", workdir + os.sep + "ZWTIP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZNET;", workdir + os.sep + "ZNET.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWVI;", workdir + os.sep + "ZWVI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEJH;", workdir + os.sep + "ZEJH.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZMXP;", workdir + os.sep + "ZMXP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZCFI:::ALL;", workdir + os.sep + "ZCFI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQRI;", workdir + os.sep + "ZQRI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWTI:PI;", workdir + os.sep + "ZWTI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZUSI;", workdir + os.sep + "ZUSI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZKAI;", workdir + os.sep + "ZKAI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZNBI;", workdir + os.sep + "ZNBI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZOPJ;", workdir + os.sep + "ZOPJ.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZE6I;", workdir + os.sep + "ZE6I.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZE6I::RT=ALL;", workdir + os.sep + "ZE6I_FULL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZFWI:PGI=;", workdir + os.sep + "ZFWIPGI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZFWI:PAPU=;", workdir + os.sep + "ZFWIPAPU.log", "COMMAND EXECUTED", name, 21600])			
			inf.append([tn, "ZFWO:NSEI=0&&65535;", workdir + os.sep + "ZFWO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEJL:NSEI=0&&65535;", workdir + os.sep + "ZEJL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZGHI;", workdir + os.sep + "ZGHI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZGHH;", workdir + os.sep + "ZGHH.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQRJ;", workdir + os.sep + "ZQRJ.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZTPI;", workdir + os.sep + "ZTPI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZE5I;", workdir + os.sep + "ZE5I.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDDE::\"ZL:M\",\"ZLP:M,MAS\",\"ZMX:W0-LFILES/*.XML\";", workdir + os.sep + "LFILES_XML.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDDE::\"ZL:M\",\"ZLP:M,MAS\",\"ZMX:W0-ASWDIR/*.INI\";", workdir + os.sep + "ASWDIR_INI.log", "COMMAND EXECUTED", name, 21600])
			send_dx_command_log(inf)
			
			inf = []		
			fp = open(workdir + os.sep + "ZMXP.log", "r")
			plmn_s = False
			for l in fp.readlines():	
				if "PLMN NAME" in l:
					plmn_s = True
				elif len(l.strip()) < 1:
					plmn_s = False
				elif l.strip() is "COMMAND EXECUTED":
					plmn_s = False
					break
				elif not "--" in l  and plmn_s:						
					inf.append([tn, "ZMXP:" + l.strip().split()[0] + ",ALL;", workdir + os.sep + "ZMXP_FULL.log", "COMMAND EXECUTED", name, 21600])
					fp.close()			
			send_dx_command_log(inf)					
																		
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/XIPIF*.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/POCIP*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/PRFI*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/FIFI*.IMG", ip)						
			dxipa().get_file(name, tn, workdir, "LICENCE", "W0-LICENCE/*.XML", ip)
											
			dx_disconnect(tn)
			ssh_disconnect(tn)
			time.sleep(10)
			print name + " Finished!"		
			workdir_finished = workdir.replace("_running","")
			try:				
				os.rename(workdir, workdir_finished)			
			except:
				print "Error on rename " + workdir
		except:
			workdir_finished = workdir.replace("_running","_failed")
			try:
				print name + " Failed!"
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir

				




class rnc:
	
	def __init__(self, ip, tn, name, logdir):
		#Define workdir:		
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		try:
			if not os.path.exists(workdir):
				os.mkdir(workdir)
		except:
			print "Error on directory " + workdir + " creation! "
			return
				
		try:		
			#RNC_IP file:
			fp = open(workdir + os.sep + "RNC_IP", "wb")
			fp.write(ip)
			fp.close()

			#ELEMENT_TYPE file:
			fp = open(workdir + os.sep + "ELEMENT_TYPE", "wb")
			fp.write("RNC")
			fp.close()

			#RNC_TYPE_TYPE file:
			fp = open(workdir + os.sep + "RNC_TYPE", "wb")
			fp.write("RNC")
			fp.close()
			
			#RNC_NAME file:
			fp = open(workdir + os.sep + "RNC_NAME", "wb")
			fp.write(name)
			fp.close()
									
			inf = []
			inf.append([tn, "ZUSI;", workdir + os.sep + "ZUSI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDDE::\"ZL:1\",\"ZLE:1,MRSTREGX\",\"Z1I\";", workdir + os.sep + "TARGET_ID.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1C\";", workdir + os.sep + "RNC_ID.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1SC\";", workdir + os.sep + "WBTS_IP.log", "COMMAND EXECUTED", name, 21600])			
			inf.append([tn, "ZDOI::M;", workdir + os.sep + "ZDOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQO:CR;", workdir + os.sep + "ZWQO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOI;", workdir + os.sep + "ZWOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOS;", workdir + os.sep + "ZWOS.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:FEA,FULL:FSTATE=ON;", workdir + os.sep + "ZW7IFULL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:LIC,FULL;", workdir + os.sep + "ZW7ILIC.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:UCAP;", workdir + os.sep + "ZW7IUCAP.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWFI:P;", workdir + os.sep + "ZWFI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWFL:P;", workdir + os.sep + "ZWFL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZNET;", workdir + os.sep + "ZNET.log", "COMMAND EXECUTED", name, 21600])						
			send_dx_command_log(inf)														   
		
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/XIPIF*.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/POCIP*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/PRFI*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/FIFI*.IMG", ip)								
			dxipa().get_file(name, tn, workdir, "LICENCE", "W0-LICENCE/*.XML", ip)
							
			dx_disconnect(tn)
			time.sleep(10)		
			print name + " Finished!"		
			workdir_finished = workdir.replace("_running","")
			os.rename(workdir, workdir_finished)
		except:
			workdir_finished = workdir.replace("_running","_failed")
			print name + " Failed!"
			try:
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir			
									
class mcrnc:
	
	def __init__(self, ip, tn, name, logdir, targetid):
		#Define workdir:		
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		try:
			if not os.path.exists(workdir):
				os.mkdir(workdir)
		except:
			print "Error on directory " + workdir + " creation! "
			return
				
		try:
			#RNC_IP file:
			fp = open(workdir + os.sep + "RNC_IP", "wb")
			fp.write(ip)
			fp.close()
			
			#RNC_TargetID file:
			fp = open(workdir + os.sep + "TARGET_ID", "wb")
			fp.write(targetid)
			fp.close()		

			#ELEMENT_TYPE file:
			fp = open(workdir + os.sep + "ELEMENT_TYPE", "wb")
			fp.write("RNC")
			fp.close()

			#RNC_TYPE_TYPE file:
			fp = open(workdir + os.sep + "RNC_TYPE", "wb")
			fp.write("mcRNC")
			fp.close()
			
			#RNC_NAME file:
			fp = open(workdir + os.sep + "RNC_NAME", "wb")
			fp.write(name)
			fp.close()
																							   
		
			cmdlist = ["set cli built-in rows -1", 		
				"show license all",
				"show sw-manage app-sw-mgmt builds",
				"show license feature-mgmt usage all",
				"show signaling ss7 local-as all",						
				"show hardware inventory list detailed",
				"show hardware state list",
				"show has functional-unit unit-info",
				"show app-parameter configuration-parameter",
				"show app-parameter feature-optionality"]
						
			loglist = [workdir + os.sep + "set_cli_built.log",
				workdir + os.sep + "licences.log",
				workdir + os.sep + "sw_delivery_id.log",						
				workdir + os.sep + "features.log",
				workdir + os.sep + "ss7.log",
				workdir + os.sep + "hw_inv.log",
				workdir + os.sep + "hw_state.log",			
				workdir + os.sep + "func_unit.log",
				workdir + os.sep + "ZWOI.log",
				workdir + os.sep + "ZWOS.log"]
									
			ssh_command_log(tn, cmdlist, loglist, name)		
			time.sleep(10)
			ssh_disconnect(tn)
			print name + " Finished!"		
			workdir_finished = workdir.replace("_running","")
			os.rename(workdir, workdir_finished)
		except:
			workdir_finished = workdir.replace("_running","_failed")
			print name + " Failed!"
			try:
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir
				
				
									
class fng:
	
	def __init__(self, ip, tn, name, logdir, targetid):
		#Define workdir:		
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		try:
			if not os.path.exists(workdir):
				os.mkdir(workdir)
		except:
			print "Error on directory " + workdir + " creation! "
			return
				
		try:
			#RNC_IP file:
			fp = open(workdir + os.sep + "FNG_IP", "wb")
			fp.write(ip)
			fp.close()
			
			#RNC_TargetID file:
			fp = open(workdir + os.sep + "TARGET_ID", "wb")
			fp.write(targetid)
			fp.close()		

			#ELEMENT_TYPE file:
			fp = open(workdir + os.sep + "ELEMENT_TYPE", "wb")
			fp.write("FNG")
			fp.close()

			#RNC_TYPE_TYPE file:
			fp = open(workdir + os.sep + "RNC_TYPE", "wb")
			fp.write("FlexiNG")
			fp.close()
			
			#RNC_NAME file:
			fp = open(workdir + os.sep + "RNC_NAME", "wb")
			fp.write(name)
			fp.close()
																							   
		
			cmdlist = ["set cli built-in rows -1", 		
				"show license all",
				"show networking address",
				"show networking vrf",
				"show ng access-point *",						
				"show hardware inventory list detailed",
				"show networking instance gn address",
				"show networking instance s11 address",
				"show networking instance gx address",
				"show hardware state list"]
						
			loglist = [workdir + os.sep + "set_cli_built.log",
				workdir + os.sep + "licences.log",
				workdir + os.sep + "networking_addresses.log",						
				workdir + os.sep + "networking_vrf.log",
				workdir + os.sep + "access_point.log",
				workdir + os.sep + "hw_inv.log",
				workdir + os.sep + "gn.log",
				workdir + os.sep + "s11.log",
				workdir + os.sep + "gx.log",
				workdir + os.sep + "hw_state.log"]
									
			ssh_command_log(tn, cmdlist, loglist, name)		
			time.sleep(10)
			ssh_disconnect(tn)
			print name + " Finished!"		
			workdir_finished = workdir.replace("_running","")
			os.rename(workdir, workdir_finished)
		except:
			workdir_finished = workdir.replace("_running","_failed")
			print name + " Failed!"
			try:
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir				
									
class netact_old:
	def __init__(self, ip, tn, ne_name, logname, _usr, _pwd):
					
		racclimx_path = "/opt/nokianms/bin/racclimx.sh "
		class_filter = "'LNBTS,LNCEL,LNMME,MRBTS,A2NE,A2ST,A2UT,ADJG,ADJI,ADJL,ADJS,AMGR,ANBA,ANTL,BFD,BFDGRP,BTSSCW,CCFA,CERTH,CESIF,CMOB,COCO,ETHLK,FMCG,FMCI,FMCS,FTM,HOPG,HOPI,HOPL,HOPS,IAIF,IEIF,IHCP,IMAG,INTP,IPNB,IPNO,IPQM,IPRM,IPRT,IUCS,IUO,IUPS,IUPSIP,IUR,IVIF,L2SWI,LCELGW,LCELW,MRBTS,OSPFV2,PPTT,PWNE,QOS,RMOD,RNAC,RNC,BSC,RNFC,RNHSPA,RNMOBI,RNPS,RNRLC,RNTRM,SMOD,STPG,SYNC,TCTT,TMPAR,TOPIK,TRDE,TWAMP,UNIT,VCCT,VCTT,VPCT,VPTT,WAC,WBTS,WCEL,WRAB'"		
		xml_name = ne_name + "_" + getDateString()
		absolute_xml_name = "/var/opt/nokia/oss/global/racops/export/" + xml_name + ".xml"
		
		if os.path.isfile(LOG_DIRE + os.sep + xml_name + ".zip"):
			ssh_disconnect(tn)
			return
																			
		cmd = "nohup " + racclimx_path + " -op Import_Export -fileFormat RAML2 -importExportOperation actualExport -fileName " + xml_name + ".xml -classFilter " + class_filter + "&"
					
		cmdlist = [cmd]			
		loglist = [TMP_DIRE + os.sep + ne_name + "_export.log"]
		ssh_command_log(tn,cmdlist,loglist,ne_name);
					
		#Wait xml to finish:
		loop = True
		ct = 0
		while loop:
			ct += 1			
			time.sleep(30)
			file_tmp = tmp_local_file(ip)
			cmdlist = ["tail -10 " + absolute_xml_name]
			loglist = [file_tmp]
			ssh_command_log(tn, cmdlist, loglist, ne_name)						
			ft = open(file_tmp, "rb")
			for lli in ft.readlines():				
				if "</raml>" in lli:
					loop = False
					break									
			if ct > 40:
				break								
			ft.close()																																			
			
		#When finished, zip the file:
		cmdlist = ["zip -j /tmp/" + xml_name + ".zip " + absolute_xml_name, 
			"rm " + absolute_xml_name]														
		loglist = [TMP_DIRE + os.sep + ne_name + "_xml.log",
			TMP_DIRE + os.sep + ne_name + "_rm.log"]
		ssh_command_log(tn,cmdlist,loglist,ne_name);
		
		#And download the zip file:
		src = "/tmp/" + xml_name + ".zip"
		dst = LOG_DIRE + os.sep + xml_name + ".zip" 					
		try:
			print "Getting " + src + " from " + ip
			copy_sftp_file(ip, _usr, _pwd, src, dst)	
			print "Ok!"
		except:
			print "Error!"
			
		ssh_disconnect(tn)	
		
									
class netact:
	def __init__(self, ip, tn, ne_name, logname, _usr, _pwd):
					
		racclimx_path = "/opt/oss/bin/racclimx.sh"
		class_filter = "'LNBTS,LNCEL,LNMME,MRBTS,A2NE,A2ST,A2UT,ADJG,ADJI,ADJL,ADJS,AMGR,ANBA,ANTL,BFD,BFDGRP,BTSSCW,CCFA,CERTH,CESIF,CMOB,COCO,ETHLK,FMCG,FMCI,FMCS,FTM,HOPG,HOPI,HOPL,HOPS,IAIF,IEIF,IHCP,IMAG,INTP,IPNB,IPNO,IPQM,IPRM,IPRT,IUCS,IUO,IUPS,IUPSIP,IUR,IVIF,L2SWI,LCELGW,LCELW,MRBTS,OSPFV2,PPTT,PWNE,QOS,RMOD,RNAC,RNC,BSC,RNFC,RNHSPA,RNMOBI,RNPS,RNRLC,RNTRM,SMOD,STPG,SYNC,TCTT,TMPAR,TOPIK,TRDE,TWAMP,UNIT,VCCT,VCTT,VPCT,VPTT,WAC,WBTS,WCEL,WRAB'"		
		xml_name = ne_name + "_" + getDateString()
		absolute_xml_name = "/var/opt/oss/global/racops/export/" + xml_name + ".xml"
		
		if os.path.isfile(LOG_DIRE + os.sep + xml_name + ".zip"):
			ssh_disconnect(tn)
			return
																			
		cmd = "nohup " + racclimx_path + " -op Import_Export -fileFormat RAML2 -importExportOperation actualExport -fileName " + xml_name + ".xml -classFilter " + class_filter + "&"
					
		cmdlist = [cmd]			
		loglist = [TMP_DIRE + os.sep + ne_name + "_export.log"]
		ssh_command_log(tn,cmdlist,loglist,ne_name);
					
		#Wait xml to finish:
		loop = True
		ct = 0
		while loop:
			ct += 1			
			time.sleep(30)
			file_tmp = tmp_local_file(ip)
			cmdlist = ["tail -10 " + absolute_xml_name]
			loglist = [file_tmp]
			ssh_command_log(tn, cmdlist, loglist, ne_name)						
			ft = open(file_tmp, "rb")
			for lli in ft.readlines():				
				if "</raml>" in lli:
					loop = False
					break									
			if ct > 40:
				break								
			ft.close()																																			
			
		#When finished, zip the file:
		cmdlist = ["zip -j /tmp/" + xml_name + ".zip " + absolute_xml_name, 
			"rm " + absolute_xml_name]														
		loglist = [TMP_DIRE + os.sep + ne_name + "_xml.log",
			TMP_DIRE + os.sep + ne_name + "_rm.log"]
		ssh_command_log(tn,cmdlist,loglist,ne_name);
		
		#And download the zip file:
		src = "/tmp/" + xml_name + ".zip"
		dst = LOG_DIRE + os.sep + xml_name + ".zip" 					
		try:
			print "Getting " + src + " from " + ip
			copy_sftp_file(ip, _usr, _pwd, src, dst)	
			print "Ok!"
		except:
			print "Error on " + src + " file download!"
			
		ssh_disconnect(tn)			


class dxipa():
	def __init__(self):
		self.netype = 0
					
	def get_file(self, name, tn, workdir, destdir, fname, ip):		
		dire = ""
		if not os.path.exists(workdir + os.sep + destdir):
			os.mkdir(workdir + os.sep + destdir)
			
		file_tmp = tmp_local_file(ip)
		inf = []
		inf.append([tn, "ZDDE::\"ZL:M\",\"ZLP:M,MAS\",\"ZMX:" + fname + "\";", file_tmp, "COMMAND EXECUTED", name, 21600])
		send_dx_command_log(inf)
							
		fp = open(file_tmp, "rb")
		ft = False
		filelist = []
		for line in fp.readlines():			
			if "DIRECTORY OF" in line:
				dire = line.split()[2]
			if "YY-MM-DD" in line:
				ft = True
			elif "TOTAL   " in line:
				ft = False
			elif ft == True:
				if not "LETTERGX" in line:	 # blacklist LETTERGX because it's very big and has no util information			
					filelist.append(line.split()[1] + line.split()[2])
		fp.close()
		
		for f in filelist:			
			inf = []
			inf.append([tn, "ZDDE::\"ZMTE:W0-" + dire + f + "\";", workdir + os.sep + destdir + os.sep + f + ".log", "COMMAND EXECUTED", name, 21600])
			send_dx_command_log(inf)
			
			fp = open(workdir + os.sep + destdir + os.sep + f + ".log", "rb")
			lic = open(workdir + os.sep + destdir + os.sep + f, "wb")
			linex = ""			
			for lin in fp.readlines():				
				if "NO SUCH FILE" in lin:		
					break
				elif ":  " in lin:
					for val in lin[5:56].strip().split(" "):
						try:
							lic.write("%c" % int(val, 16))
						except:
							print "Error on file " + fname + " for IP: " + ip + " name: " + name + " ;"
																		
			fp.close()
			lic.close()
			time.sleep(2)
			try:
				os.remove(workdir + os.sep + destdir + os.sep + f + ".log")
			except:
				print name + " failed to remove " + workdir + os.sep + destdir + os.sep + f + ".log"

						
class bsc:
	
	def __init__(self, ip, tn, name, logdir):
		#Define workdir:		
		workdir = logdir + os.sep + name + "_running"
		
		#Create the directory:
		try:
			if not os.path.exists(workdir):
				os.mkdir(workdir)
		except:
			print "Error on directory " + workdir + " creation! "
			return
		
		try:										
			zeei = "ZEEI;"
			tmp_log = tmp_local_file(name)		
			fp = open(tmp_log, "wb")
			fp.write(send_dx_command(tn, ["ZWOS:2,665;"], ["COMMAND EXECUTED"]))
			fp.close()		
			fp = open(tmp_log, "rb")
			seg = 0
			for line in fp.readlines():
				if " ACTIVATED" in line:
					zeei = "ZEEI:SEG=ALL;"
			fp.close()
			os.remove(tmp_log)						
			
			#BSC_IP file:
			fp = open(workdir + os.sep + "BSC_IP", "wb")
			fp.write(ip)
			fp.close()

			#ELEMENT_TYPE file:
			fp = open(workdir + os.sep + "ELEMENT_TYPE", "wb")
			fp.write("BSC")
			fp.close()

			#BSC_TYPE_TYPE file:
			fp = open(workdir + os.sep + "BSC_TYPE", "wb")
			fp.write("BSC")
			fp.close()
			
			#BSC_NAME file:
			fp = open(workdir + os.sep + "BSC_NAME", "wb")
			fp.write(name)
			fp.close()
													
			inf = []
			inf.append([tn, "ZQNI;", workdir + os.sep + "ZQNI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZDFD:OMU:88E;", workdir + os.sep + "Q3VERSION.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQLI;", workdir + os.sep + "ZQLI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZQRI:OMU;", workdir + os.sep + "ZQRIOMU.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, zeei, workdir + os.sep + "ZEEI.log", "COMMAND EXECUTED", name, 21600])
			send_dx_command_log(inf)
																	
			#Get max bts-id number from ZEEI.log. The value is initiated with 10
			max_bts = 10;  
			max_bcf = 10;
			fp = open(workdir + os.sep + "ZEEI.log", "rb")
			out = fp.readlines()
			
			for line in out:
				if "BTS-" in line:
					bts = line.split("BTS-")[1].split(" ")[0]				
					if int(bts) > max_bts:
						max_bts = int(bts)
			
			max_bcf = max_bts												
			if int(max_bcf) > 3000:
				max_bcf = 3000
																			   
			fp.close()
			
			inf = []
			inf.append([tn, "ZERO:BTS=1&&" + str(max_bts) + ";", workdir + os.sep + "ZERO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEQO:BTS=1&&" + str(max_bts) + ":ALL;", workdir + os.sep + "ZEQO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEWO:1&&" + str(max_bcf) + ";", workdir + os.sep + "ZEWO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEEI::BCSU;", workdir + os.sep + "ZEEIBCSU.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZTPI;", workdir + os.sep + "ZTPI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQV:OMU:PRFILEGX;", workdir + os.sep + "PRFILE_VER.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWQV:OMU:FIFILEGX;", workdir + os.sep + "FIFILE_VER.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZUSI;", workdir + os.sep + "ZUSI.log", "COMMAND EXECUTED", name, 21600])			
			inf.append([tn, "ZDOI::M;", workdir + os.sep + "ZDOI.log", "COMMAND EXECUTED", name, 21600])			
			inf.append([tn, "ZWQO:CR;", workdir + os.sep + "ZWQO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOI;", workdir + os.sep + "ZWOI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWOS;", workdir + os.sep + "ZWOS.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZWTI:PI;", workdir + os.sep + "ZWTI.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:FEA,FULL:FSTATE=ON;", workdir + os.sep + "ZW7IFULL.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZW7I:LIC,FULL;", workdir + os.sep + "ZW7ILIC.log", "COMMAND EXECUTED", name, 21600])	
			inf.append([tn, "ZW7I:UCAP;", workdir + os.sep + "ZW7IUCAP.log", "COMMAND EXECUTED", name, 21600])	
			inf.append([tn, "ZNET;", workdir + os.sep + "ZNET.log", "COMMAND EXECUTED", name, 21600])	
			send_dx_command_log(inf)
						
		    #Gb:
			gbip = False
			inf = []
			inf.append([tn, "ZW7I:FEA,FULL:FEA=7;", workdir + os.sep + "ZW7I_FEA_7.log", "COMMAND EXECUTED", name, 21600])
			send_dx_command_log(inf)
			
			fp = open(workdir + os.sep + "ZW7I_FEA_7.log", "rb")			
			for line in fp.readlines():
				if "FEATURE STATE:.............ON" in line:
					gbip = True
			fp.close()
			
									
			if gbip:
				inf.append([tn, "ZFXI:NSEI=0&&65535;", workdir + os.sep + "ZFXI.log", "COMMAND EXECUTED", name, 21600])
				
			inf.append([tn, "ZFXO:NSEI=0&&65535;", workdir + os.sep + "ZFXO.log", "COMMAND EXECUTED", name, 21600])
			inf.append([tn, "ZEBP;", workdir + os.sep + "ZEBP.log", "COMMAND EXECUTED", name, 21600])
			send_dx_command_log(inf)						
														
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/XIPIF*.XML", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/POCIP*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/PRFI*.IMG", ip)
			dxipa().get_file(name, tn, workdir, "LFILES", "W0-LFILES/FIFI*.IMG", ip)						
			dxipa().get_file(name, tn, workdir, "LICENCE", "W0-LICENCE/*.XML", ip)
			
			dx_disconnect(tn)
			print name + " Finished!"
			time.sleep(2)		
			workdir_finished = workdir.replace("_running","")
			try:
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir
		except:
			workdir_finished = workdir.replace("_running","_failed")
			try:
				print name + " Failed!"
				os.rename(workdir, workdir_finished)
			except:
				print "Error on rename " + workdir
										
						
def get_ne_name_mc_rnc(tn, ip):
	ret = "unknow"
	ssh_command(tn, ["set cli built-in rows -1"])	
	file_tmp = tmp_local_file(ip)
	fp = open(file_tmp, "wb")
	fp.write(ssh_command(tn, ["show radio-network omsconn"]))
	fp.close()
	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():
		if "RNC name:" in line:
			ret = line[20:75].strip()
		
	fp.close()
	os.remove(file_tmp)
		
	return ret

def get_ne_name_fng(tn, ip):
	ret = "unknow"
	ssh_command(tn, ["set cli built-in rows -1"])	
	file_tmp = tmp_local_file(ip)
	fp = open(file_tmp, "wb")
	fp.write(ssh_command(tn, ["show config host CLA-0"]))
	fp.close()	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():
		print line		
		if "fsLogicalNetworkElemId" in line:
			print line
			ret = line.split()[1]
			break
		
	fp.close()
	os.remove(file_tmp)		
	return ret

def get_ne_name_linux(tn, ip):
	ret = "unknow"	
	file_tmp = tmp_local_file(ip)
	fp = open(file_tmp, "wb")
	fp.write(ssh_command(tn, ["uname -n"]))
	time.sleep(2)
	fp.write(ssh_command(tn, ["uname -n"]))
	time.sleep(2)
	fp.write(ssh_command(tn, ["uname -n"]))
	time.sleep(2)
	fp.write(ssh_command(tn, ["uname -n"]))
	time.sleep(2)
	fp.write(ssh_command(tn, ["uname -n"]))
	time.sleep(2)	
	fp.close()
	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():		
		if not "uname -n" in line:
			ret = line.strip()		
	fp.close()
	os.remove(file_tmp)	
	return ret
				
				
def get_ne_target_id_mc_rnc(tn, ip):
	ret = "unknow"
	ssh_command(tn, ["set cli built-in rows -1"])	
	file_tmp = tmp_local_file(ip)
	fp = open(file_tmp, "wb")
	fp.write(ssh_command(tn, ["show license target-id"]))
	fp.close()
	
	fp = open(file_tmp, "rb")
	for line in fp.readlines():		
		if "Target ID " in line:			
			ret = line[20:75].strip()			
		
	fp.close()
	os.remove(file_tmp)
		
	return ret
		
def get_ne_type_flexi_platform(tn, ip):
	ret = "FlexiNG"
	cmdl = ["set cli built-in rows -1"]
	l = ssh_command(tn, cmdl)	
	if "CFPU-" in l:
		ret = "mcRNC"
	elif "CLA-" in l:
		ret = "FlexiNG"
		
	return ret
	
#Global:  LOG_DIRE and TMP_DIRE
TMP_DIRE = "tmp"
LOG_DIRE = "logs"


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


if os.path.exists(LOG_DIRE) and os.path.isdir(LOG_DIRE):
	while True:
		rm_conf = raw_input("Directory " + LOG_DIRE + "already exists. \
		\nDo you want to remove it? (Yes/No)\
		\nYes --> Remove the directory and subdirectories\n\
		          and get all logs from beginner;\n\
		\nNo  --> Keep the directory and remove only the\n\
		          subdirectories that contain \"_running\" on its name.\
		\nOption:")
		
		if "Yes" in rm_conf or "No" in rm_conf:	
			break;
		else:
			print "\nInvalid option. Please:  \"Yes\" or \"No\""
	
	if "Yes" in rm_conf:
		if os.path.exists(LOG_DIRE):
			shutil.rmtree(LOG_DIRE)
	else:
		for fi in os.listdir(LOG_DIRE):
			if "_running" in fi or "_failed" in fi:
				try:
					shutil.rmtree(LOG_DIRE + os.sep + fi)
				except:
					print fi + " removal failed!"
					
tot = 0
for n in nelst.readlines():
	tot += 1
	
nelst.close()

#Create a temp directory:
if os.path.exists(TMP_DIRE):
	shutil.rmtree(TMP_DIRE)
			
os.mkdir(TMP_DIRE)
max_sim_thread = 40
	
#Create the log directory:
if not os.path.exists(LOG_DIRE):
	os.mkdir(LOG_DIRE)
		
wait_time = 5
curr = 0
dir_tot = 0
dir_list = {}
nelst = open("ne.csv", "r")
for line in nelst.readlines():
	curr += 1
	if not line.startswith("#") and len(line.strip()) > 2:		
		ip = line.split(",")[0]
		plat = line.split(",")[1]
		usr = line.split(",")[2]
		pwd = line.split(",")[3]			
		logname = LOG_DIRE
		if "DX200" in plat or "IPA2800" in plat:
			print "(" + str(curr) + " of " + str(tot) + ") Openning telnet connection to " + ip + "..."
			tna = dx_connect(ip, usr, pwd)
			if tna:
				print "Connection to " + ip + " established!"
				print "Getting " + ip + " element type..."
				try:
					ne_type = get_ne_type(tna, ip)								
				except:
					print "Error on connection to ip: " + ip + ";"
									
				print ip + " is " + ne_type
				
				try:
					ne_name = get_ne_name(tna, ip)
				except:
					print "Error on connection to ip: " + ip + ";"
					
					
				print ip + " is " + ne_type + " and its name is " + ne_name

				#Add ne_name to dir list, to be zipped later:
				dir_tot += 1
				dir_list[dir_tot] = ne_name
				
				running_dire =  LOG_DIRE + os.sep + ne_name + "_running"
				work_dire = LOG_DIRE + os.sep + ne_name
								
				if os.path.isdir(running_dire):
					shutil.rmtree(running_dire)
				
				if os.path.isdir(work_dire):
					dx_disconnect(tna)
				else:			
					if "BSC" in ne_type:				
						bsc_thread = threading.Thread(target=bsc, args=(ip, tna, ne_name, logname))						
						bsc_thread.start()						
					elif "RNC" in ne_type:
						rnc_thread = threading.Thread(target=rnc, args=(ip, tna, ne_name, logname))						
						rnc_thread.start()
					elif "Flexi NS" in ne_type:
						fns_thread = threading.Thread(target=fns, args=(ip, tna, ne_name, logname))						
						fns_thread.start()
					elif "SGSN" in ne_type:
						sgsn_thread = threading.Thread(target=sgsn, args=(ip, tna, ne_name, logname))					
						sgsn_thread.start()															
						
			else:
				print "Connection to " + ip + " failed!"
		
		elif "mcRNC" in plat:
			print "(" + str(curr) + " of " + str(tot) + ") Openning ssh connection to " + ip + "..."
			usr = usr.strip()
			pwd = pwd.strip()
			try:
				tna = ssh_connect(ip, usr, pwd)
			except:
				print "User auth failure on " + ip
				tna = 0
				
			if tna:
				print "Connection to " + ip + " established!"				
				if chk_fhascli(tna):
					print "Getting " + ip + " element type..."												
					ne_type = get_ne_type_flexi_platform(tna, ip)
					print ip + " is " + ne_type
					ne_name = get_ne_name_mc_rnc(tna, ip)
					
					#Add ne_name to dir list, to be zipped later:
					dir_tot += 1
					dir_list[dir_tot] = ne_name			
					
					print ip + " is " + ne_type + " and its name is " + ne_name
					ne_target_id = get_ne_target_id_mc_rnc(tna, ip) 						
					print "NE_type = " + ne_type
					
					running_dire =  LOG_DIRE + os.sep + ne_name + "_running"
					failed_dire =  LOG_DIRE + os.sep + ne_name + "_failed"					
					work_dire = LOG_DIRE + os.sep + ne_name
								
					if os.path.isdir(running_dire):
						shutil.rmtree(running_dire)
																								
					if os.path.isdir(failed_dire):
						shutil.rmtree(failed_dire)						
				
					if os.path.isdir(work_dire):														
						ssh_disconnect(tna)
					else:
						if "mcRNC" in ne_type:
							mcrnc_thread = threading.Thread(target=mcrnc, args=(ip, tna, ne_name, logname, ne_target_id))
							mcrnc_thread.start()
					
				else:
					print "Must be fhasclish user!"
					ssh_disconnect(tna)
					
					
		elif "FlexiNG" in plat:
			print "(" + str(curr) + " of " + str(tot) + ") Openning ssh connection to " + ip + "..."
			usr = usr.strip()
			pwd = pwd.strip()
			tna = ssh_connect(ip, usr, pwd)
			if tna:
				print "Connection to " + ip + " established!"				
				if chk_fhascli(tna):
					print "Getting " + ip + " element type..."												
					ne_type = get_ne_type_flexi_platform(tna, ip)
					print ip + " is " + ne_type
					ne_name = get_ne_name_fng(tna, ip)
					
					#Add ne_name to dir list, to be zipped later:
					dir_tot += 1
					dir_list[dir_tot] = ne_name			
					
					print ip + " is " + ne_type + " and its name is " + ne_name
					ne_target_id = get_ne_target_id_mc_rnc(tna, ip) 						
					print "NE_type = " + ne_type
					
					running_dire =  LOG_DIRE + os.sep + ne_name + "_running"
					failed_dire =  LOG_DIRE + os.sep + ne_name + "_failed"					
					work_dire = LOG_DIRE + os.sep + ne_name
								
					if os.path.isdir(running_dire):
						shutil.rmtree(running_dire)
																								
					if os.path.isdir(failed_dire):
						shutil.rmtree(failed_dire)						
				
					if os.path.isdir(work_dire):														
						ssh_disconnect(tna)
					else:
						if "FlexiNG" in ne_type:
							fng_thread = threading.Thread(target=fng, args=(ip, tna, ne_name, logname, ne_target_id))
							fng_thread.start()
					
				else:
					print "Must be fhasclish user!"
					ssh_disconnect(tna)				

		elif "Netact_old" in plat:
			print "(" + str(curr) + " of " + str(tot) + ") Openning ssh connection to " + ip + "..."
			usr = usr.strip()
			pwd = pwd.strip()
			tna = ssh_connect(ip, usr, pwd)
			if tna:
				print "Connection to " + ip + " established!"				
				ne_name = get_ne_name_linux(tna, ip)
				print ip + " name is " + ne_name																			
				netact_old_thread = threading.Thread(target=netact_old, args=(ip, tna, ne_name, logname, usr, pwd))
				netact_old_thread.start()
				
		elif "Netact" in plat:
			print "(" + str(curr) + " of " + str(tot) + ") Openning ssh connection to " + ip + "..."
			usr = usr.strip()
			pwd = pwd.strip()
			tna = ssh_connect(ip, usr, pwd)
			if tna:
				print "Connection to " + ip + " established!"				
				ne_name = get_ne_name_linux(tna, ip)
				print ip + " name is " + ne_name																			
				netact_thread = threading.Thread(target=netact, args=(ip, tna, ne_name, logname, usr, pwd))
				netact_thread.start()						
				
				
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
if os.path.exists(TMP_DIRE):
	shutil.rmtree(TMP_DIRE)
	
#After that, zip the log directories and remove them

zipf = zipfile.ZipFile(LOG_DIRE + os.sep + "NELogs_" + getDateString() + ".zip", 'w',  zipfile.ZIP_DEFLATED)
os.chdir(LOG_DIRE)

for x in range(1, (dir_tot + 1)):
	try:		
		zipdir(dir_list[x], zipf)
	except:
		print "Error on " + dir_list[x] + " zip attempt!"
		
	try:
		shutil.rmtree(dir_list[x])
	except:
		print "Error on " + dir_list[x] + " deletion attempt!"
	   
zipf.close()
		
	
raw_input("Script has been finished!")


