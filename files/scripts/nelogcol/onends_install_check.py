#!/usr/bin/python

from connections import _dir, _file, log, dev_dx, dev_lin, TMP_DIRE, LOG_DIRE
from dxipa import dxipa
import sys, traceback, os

class ne:
	def __init__(self):
		return
	
	def set_ip(self, ip):
		self.ip = ip
	
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
		print "Type    : " + self._type
		print "User    : " + self._user
		print "Password: " + self._password
		

#Create a temp directory:
#if _dir(LOG_DIRE).exists:
#	_dir(LOG_DIRE).remove()
	
_dir(TMP_DIRE).remove()
_dir(TMP_DIRE).create()
_dir(LOG_DIRE).create()


#Get ne list from ne.csv
nelist = []
fp = open("ne.csv", "rb")
for l in fp.readlines():
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
		if _ne.get_type() == "linux":
			print(_ne.get_ip())
			
			if _dir(LOG_DIRE + os.sep + _ne.get_ip()).exists():
				_dir(LOG_DIRE + os.sep + _ne.get_ip()).remove()
				
			_dir(LOG_DIRE + os.sep + _ne.get_ip()).create()
			_dir(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "logs").create()
			_dir(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst").create()
			_dir(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "dump").create()
			_dir(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent").create()
			fpout = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "output.log", "w")
			fpout.write(_ne.get_ip() + "\n")
			lin = dev_lin(_ne.get_ip(), _ne.get_user(), _ne.get_password())
			
			#hostid
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "hostid.log").write(lin.tx("hostid"))
			
			#hostname
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "hostname.log").write(lin.tx("hostname"))
			
			#/tspinst/scripts/aiParameter.sh
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "aiParameter.sh").write(lin.tx("cat /tspinst/scripts/aiParameter.sh"))
			
			#IP Configuration / Route:
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "ip_addr.log").write(lin.tx("ip addr show"))
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "ip_link.log").write(lin.tx("ip link show"))
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "ip_link_details.log").write(lin.tx("ip -d l"))
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "ip_route.log").write(lin.tx("ip route"))
			
			#check tspinst
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "ls.log").write(lin.tx("ls -l /tspinst/*.{log,out}"))
			_fpp = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "ls.log")
			for lla in _fpp.readlines():
				for fname in lla.strip().split(" "):
					_x = 1				
				log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + fname.split("/")[2]).write(lin.tx("cat " + fname))
				fp_check = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + fname.split("/")[2])
				if ".err" in fname.split("/")[2]:
					print("   " + fname.split("/")[2] + ": Found! Check it!")
								
				exec_succ = False
				for line_check in fp_check.readlines():
					if "error"  in line_check or "Error" in line_check or "ERROR" in line_check:
#						print("   " + fname.split("/")[2] + ":" + line_check.strip())
						fpout.write("   " + fname.split("/")[2] + ":" + line_check.strip() + "\n")
						
					if "Script end status: executed successfully" in line_check:
						exec_succ = True


			#check tspinst/swagent
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent" + os.sep + "ls.log").write(lin.tx("ls -l /tspinst/*.{log,out}"))
			_fpp = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent" + os.sep + "ls.log")
			for lla in _fpp.readlines():
				for fname in lla.strip().split(" "):
					_x = 1				
				log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent" + os.sep + fname.split("/")[2]).write(lin.tx("cat " + fname))
				fp_check = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + fname.split("/")[2])
				if ".err" in fname.split("/")[2]:
					print("   " + fname.split("/")[2] + ": Found! Check it!")
								
				exec_succ = False
				for line_check in fp_check.readlines():
					if "error"  in line_check or "Error" in line_check or "ERROR" in line_check:
#						print("   " + fname.split("/")[2] + ":" + line_check.strip())
						fpout.write("   " + fname.split("/")[2] + ":" + line_check.strip() + "\n")
						
					if "Script end status: executed successfully" in line_check:
						exec_succ = True
						
			#check tspinst/swagent
			log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent" + os.sep + "ls.log").write(lin.tx("ls -l /tspinst/*.{log,out}"))
			_fpp = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent" + os.sep + "ls.log")
			for lla in _fpp.readlines():
				for fname in lla.strip().split(" "):
					_x = 1				
				log(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + "swagent" + os.sep + fname.split("/")[2]).write(lin.tx("cat " + fname))
				fp_check = open(LOG_DIRE + os.sep + _ne.get_ip() + os.sep + "tspinst" + os.sep + fname.split("/")[2])
				if ".err" in fname.split("/")[2]:
					print("   " + fname.split("/")[2] + ": Found! Check it!")
								
				exec_succ = False
				for line_check in fp_check.readlines():
					if "error"  in line_check or "Error" in line_check or "ERROR" in line_check:
#						print("   " + fname.split("/")[2] + ":" + line_check.strip())
						fpout.write("   " + fname.split("/")[2] + ":" + line_check.strip() + "\n")
						
					if "Script end status: executed successfully" in line_check:
						exec_succ = True						
			
																				
			_fpp.close()
		fpout.close()
			
	except:
		print _ne.get_ip() + " connection failure!"
		
		#Only to traceback the error cause (If needed)
		traceback.print_exc(file=sys.stdout)
		
exit(0)


