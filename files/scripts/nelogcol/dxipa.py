#!/usr/bin/python
import os, datetime
from os import listdir
from connections import _dir, _file, log, dev_dx, dev_lin, TMP_DIRE, LOG_DIRE
import paramiko, time


class unit:
	def __init__(self):
		self.__index = ""
		self.__type = ""
		
		#__bcf is captured from message monitoring
		self.__bcf = ""
		
		#__bcf_id is the real bcf id (ZEEI in bsc)
		self.__bcf_id = ""
		self.__bsc_id = ""		
		self.__bts = ""
		self.__trx = ""
		self.__fw = ""
		self.__version = ""
		self.__serial = ""
	
	def get_bcf_id(self):
		return self.__bcf_id

	def get_bsc_id(self):
		return self.__bsc_id

	def set_bcf_id(self, arg):
		self.__bcf_id = arg

	def set_bsc_id(self, arg):
		self.__bsc_id = arg
			
	def get_fw(self):
		return self.__fw

	def get_version(self):
		return self.__version

	def get_serial(self):
		return self.__serial
	
	def set_fw(self, arg):
		self.__fw = arg

	def set_version(self, arg):
		self.__version = arg

	def set_serial(self, arg):
		self.__serial = arg
	
	def get_index(self):
		return self.__index
	
	def get_type(self):
		return self.__type
	
	def get_bcf(self):
		return self.__bcf
	
	def get_bts(self):
		return self.__bts
	
	def get_trx(self):
		return self.__trx
	
	def set_bcf(self, arg):
		self.__bcf = arg
	
	def set_bts(self, arg):
		self.__bts = arg
	
	def set_trx(self, arg):
		self.__trx = arg
	
	def set_index(self, arg):
		self.__index = arg
	
	def set_type(self, arg):
		self.__type = arg
	
	def print_all(self):		
		print "##########Unit Info:################"
		print "BSC_ID   = " + str(self.__bsc_id)
		print "Index    = " + str(self.__index)
		print "Type     = " + str(self.__type)
		print "BCF      = " + str(self.__bcf)
		print "BCF_ID   = " + str(self.__bcf_id)
		print "BTS      = " + str(self.__bts)
		print "TRX      = " + str(self.__trx)
		print "FW       = " + str(self.__fw)
		print "Version  = " + str(self.__version)
		print "Serial   = " + str(self.__serial)
		print
		
	def get_units(self):
		ret = str(self.__bsc_id) + "," + \
			  str(self.__bcf_id) + "," + \
			  str(self.__index) + "," + \
			  str(self.__type) + "," + \
			  str(self.__bcf) + "," + \
			  str(self.__bts) + "," + \
			  str(self.__trx) + "," + \
			  str(self.__fw) + "," + \
			  str(self.__version) + "," + \
			  str(self.__serial)
		return ret
		
def is_ascii(int_val):
	ret = False
	if (int_val >= ord('A')  and int_val <= ord('Z'))  \
		or (int_val >= ord('0')  and int_val <= ord('9')) \
		or (int_val >= ord('a')  and int_val <= ord('z')) \
		or int_val == ord(':') :	
		ret = True
			
	return ret
	
def conv(stream):
	msg = False
	ret = []
	for f in stream:
		if "MONITORED MESSAGE:" in f:
			msg = True
		elif msg == True and len(f.strip()) > 1:
			for d in f.strip().split():
				ret.append((int(d, 16)))
		else:
			msg = False
	return ret


def get_units_from_msg(msg, serial,bsc_id, bcf_id):
	start_read = False
	
	#get intex of first msg:
	for d in range(len(msg)):
		if msg[d] == 0 and msg[d - 1] == 0x9d:
			start_read = True
			d += 4
			break

	unit_len = 18
	hw_report = False
	units = []
	if start_read:
		utype = ""
		for i in range(d, len(msg)):
			if msg[i] == 0x5b and msg[i - 1] == 0x5f:
				hw_report = True
				i += 1
				msg_len = msg[i]			
								
			if hw_report == True:						
				u = unit()
				u.set_bsc_id(bsc_id)
				u.set_bcf_id(bcf_id)
				for j in range(i, i + unit_len):				
					if j >= len(msg):
							break			
					if is_ascii(msg[j]):					
						utype = utype + chr(msg[j])
					else:
						if len(utype) > 0:						
							u.set_index(msg[i + 17])
							u.set_bcf(msg[i + 18])
							u.set_bts(msg[i + 19])
							u.set_trx(msg[i + 20])
							u.set_type(utype)
							units.append(u)
							if serial == 1:
								
								#Firmware:
								strtmp = ""
								for k in range(24, 30):
									if (i + k ) > len(msg):
										break
									if is_ascii(msg[i + k]):										
										strtmp = strtmp + chr(msg[i + k])								
								u.set_fw(strtmp)

								#Version:
								strtmp = ""
								for k in range(43, 51):
									if (i + k ) > len(msg):
										break
									if is_ascii(msg[i + k]):
										strtmp = strtmp + chr(msg[i + k])								
								u.set_version(strtmp)

								#Serial:
								strtmp = ""
								is_zero = True
								for k in range(59, 76):
									if (i + k ) > len(msg):
										break
									if is_ascii(msg[i + k]):
										if chr(msg[i + k]) != "0" or len(strtmp) > 0 or k == 76:
											strtmp = strtmp + chr(msg[i + k])
																	
								u.set_serial(strtmp)

						hw_report = False
						utype = ""
				i = j	
	return units
		
def inq_hw_list(con, bcf, bsc_cnumber, sw_ver, fname):	
	#get omusig number:
	packet_abis = False
	for p in stream_to_text(con, "ZEFO:" + str(bcf) + ";"):
		if "D-CHANNEL LINK SET" in p:
			dch = p.split()[3]	
		if "PACKET ABIS" in p:
			packet_abis = True
				
	#get
	sran = False
	for p in stream_to_text(con, "ZEEI:BCF=" + str(bcf) + ";"):
		if "BCF-" in p:
			bcxu = p[57:65].strip().replace("X", "")
			bcf_type = p[10:23].strip()
			if "SBTS-" in p:
				sran = True	
				
	#Sran don't respond hw request:
	if sran == True:
		return
		
	bcxu_t = False
	if "BCXU-" in con.tx("ZUSI:COMP;"):
		bcxu_t = True
	
	if bcxu_t:
		bcsu = "BCXU"
	else:
		bcsu = "BCSU"
	
	
	for l in stream_to_text(con, "ZUSI:" + bcsu + "," + str(bcxu) + ";"):
		if "WO-EX" in l:
			mb_addr = l.split()[1]
	
	
	#Set command string:
	data = []
	if int(sw_ver.split()[1].split(".")[0]) >= 7:
		#bts id:
		data.append("0000")

		#trx:
		data.append("00")

		#bscid:
		data.append("00000000")

		#unit_index:
		data.append("00")

		#call_seq:
		data.append("00000000")

		#spare:
		data.append("00000000")

	#dchannel	
	data.append(("%.4x" % (int(dch))).upper())
	
	#reference:
	data.append("0000")

	#Msg desc:
	data.append("8080")
	
	#seq nbr:
	data.append("00")

	#len indication:
	data.append("0B")

	#default:
	data.append("9C")
	data.append("00")
	data.append("372D")
	data.append("535F")
	
	#normal inquiry
	data.append("0101")  
	
	s = ""
	ss = ""
	for d in data:
		if len(d) == 2:
			s = str(s) + str(d) + ","
		elif len(d) == 4:	
			s = str(s) + "XW" + str(d) + ","
		elif len(d) > 4:
			i = 0
			while i < len(d):
				ss = ss + d[i]
				i +=1 
				if i % 4 == 0:				
					s = str(s) + "XW" + str(ss) + ","
					ss = ""
				
	s = s[:len(s) - 1]
	sfam = "226"
	if packet_abis == True:
		dfam = "6BA"
	else:
		dfam = "11E"
		
	cmd = "ZOSD:" + mb_addr + "," + sfam + ",4,0,*," + mb_addr + "," + dfam + ",,,11,0030,5991,,," + s
					
	con.connect()
	cmd_list = []
	cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])
	cmd_list.append(["ZOEQ", ">"])
	cmd_list.append(["ZOEBR::7FFF", ">"])
	cmd_list.append(["ZOEC::R:(NUM=5992)AND(DATW00=" + ("%.4x" % (int(dch))).upper()  + ")", ">"])
	cmd_list.append(["ZOEM", ">"])
	cmd_list.append([cmd, ">"])
	cmd_list.append(["ZZE;", "COMMAND EXECUTED"])
	
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " BCF " + str(bcf) + " Querying the units;"
	con.sendlist(cmd_list)
	
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " BCF " + str(bcf) + " Waiting for bcf response..."
	time.sleep(2)	
	con.disconnect()	
	if "Message count: 0" in con.tx("ZDDE:" + bcsu + "," + bcxu + ":\"ZOEI\";"):
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " BCF " + str(bcf) + " Waiting for bcf response..."
		time.sleep(4)
		if "Message count: 0" in con.tx("ZDDE:" + bcsu + "," + bcxu + ":\"ZOEI\";"):			
			print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " No response from bcf..."
			return
				
	#get intex of first msg:
	units = get_units_from_msg(conv(stream_to_text(con, "ZDDE:" + bcsu + "," + bcxu + ":\"ZOES\", \"ZOEG\";")), 0, 0, 0)
	
	cmd_list = []
	cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])	
	if len(units) > 0:
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " BCF " + str(bcf) + " Found " + str(len(units)) + " Units;"
		con.connect()
		cmd_list = []
		cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])
		cmd_list.append(["ZOEQ", ">"])
		cmd_list.append(["ZOEBR::7FFF", ">"])
		cmd_list.append(["ZOEC::R:(NUM=5992)AND(DATW00=" + ("%.4x" % (int(dch))).upper()  + ")", ">"])
		cmd_list.append(["ZOEM", ">"])		
		
		cmd_list.append(["ZZE;", "COMMAND EXECUTED"])
		con.sendlist(cmd_list)		
		
		time.sleep(2)
		con.disconnect()		
		
	for u in units:		
		#Set command string:
		data = []

		if int(sw_ver.split()[1].split(".")[0]) >= 7:
			#bts id:
			data.append("0000")

			#trx:
			data.append("00")

			#bscid:
			data.append("00000000")

			#unit_index:
			data.append("00")

			#call_seq:
			data.append("00000000")

			#spare:
			data.append("00000000")

		#dchannel	
		data.append(("%.4x" % (int(dch))).upper())
		
		#reference:
		data.append("0000")

		#Msg desc:
		data.append("8080")
		
		#seq nbr:
		data.append("00")

		#len indication:
		data.append("1f")

		#default:
		data.append("9C")
		data.append("00")
		data.append("392D")
		data.append("535F")
		
		#total data enquiry inquiry
		data.append("0001") 
		
		#hardware identity:
		
		#Info element type:
		data.append("5B5F")
		
		#Len:
		data.append("14")
		
		#Unity type:
		for ch in u.get_type():
			data.append(format(ord(ch), 'x').upper())
		
		if len(u.get_type()) < 16:
			for i in range(len(u.get_type()), 16):
				data.append("20")

		data.append(("%.2x" % (int(u.get_index()))).upper())
		data.append(("%.2x" % (int(u.get_bcf()))).upper())
		data.append(("%.2x" % (int(u.get_bts()))).upper())
		data.append(("%.2x" % (int(u.get_trx()))).upper())

		s = ""
		ss = ""
		for d in data:
			if len(d) == 2:
				s = str(s) + str(d) + ","
			elif len(d) == 4:	
				s = str(s) + "XW" + str(d) + ","
			elif len(d) > 4:
				i = 0
				while i < len(d):
					ss = ss + d[i]
					i +=1 
					if i % 4 == 0:				
						s = str(s) + "XW" + str(ss) + ","
						ss = ""
		
		s = s[:len(s) - 1]
		cmd = "ZOSD:" + mb_addr + "," + sfam + ",4,0,*," + mb_addr + "," + dfam + ",,,11,0030,5991,,," + s
		cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])
		cmd_list.append([cmd, ">"])
		cmd_list.append(["ZZZE;", "COMMAND EXECUTED"])
				
		
	time.sleep(2)		
	con.connect()
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " BCF " + str(bcf) + " Querying the " + str(len(units)) + " Units;"
	con.sendlist(cmd_list)
	time.sleep(1)
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + con.name + " BCF " + str(bcf) + " Waiting for bcf response..."			
	con.disconnect()
	
		
	units = get_units_from_msg(conv(stream_to_text(con, "ZDDE:" + bcsu + "," + bcxu + ":\"ZOES\", \"ZOEG\";")), 1, bsc_cnumber, bcf)
		
				
	for u in units:		
		fp = open(fname, "a")
		fp.write(u.get_units() + "\n")
		fp.close()
		
def stream_to_text(device, cmd):
	ret = []
	lin = ""
	for c in device.tx(cmd):
		if c == '\n':			
			ret.append(lin.rstrip())
			lin = ""
		elif c != '\r':
			lin = lin + str(c)			
	
	return ret


class rnc:
	def __init__(self, ipa):
		self = ipa
		self.tmp_file.clear()
		fp = self.tmp_file.get_fp()
		
		self.write_on_file(self.work_dir.get_name() + os.sep + "RNC_IP", self.ip)
		self.write_on_file(self.work_dir.get_name() + os.sep + "ELEMENT_TYPE", "RNC")
		self.write_on_file(self.work_dir.get_name() + os.sep + "RNC_TYPE", "RNC")
		self.write_on_file(self.work_dir.get_name() + os.sep + "RNC_NAME", self.name)
		
		log(self.work_dir.get_name() + os.sep + "TARGET_ID.log").write(self.ne.tx("ZDDE::\"ZL:1\",\"ZLE:1,MRSTREGX\",\"Z1I\";"))
		log(self.work_dir.get_name() + os.sep + "RNC_ID.log").write(self.ne.tx("ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1C\";"))
		log(self.work_dir.get_name() + os.sep + "WBTS_IP.log").write(self.ne.tx("ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1SC\";"))
		
class bsc:
	def __init__(self, dx):
		self = dx
		zeei = "ZEEI;"
		
		self.write_on_file(self.work_dir.get_name() + os.sep + "BSC_IP", self.ip)
		self.write_on_file(self.work_dir.get_name() + os.sep + "ELEMENT_TYPE", "BSC")
		self.write_on_file(self.work_dir.get_name() + os.sep + "BSC_TYPE", "BSC")
		self.write_on_file(self.work_dir.get_name() + os.sep + "BSC_NAME", self.name)	
											
		self.tmp_file.clear()
		fp = self.tmp_file.get_fp()
		
		fp.write(self.ne.tx("ZWOS:2,665;"))
		fp.close()
		
		self.tmp_file.open()
		fp = self.tmp_file.get_fp()
		
		for line in fp.readlines():
			if " ACTIVATED" in line:
				zeei = "ZEEI:SEG=ALL;"
		fp.close()		
		
		
		bsc_lst = []
		bsc_lst.append(["ZEEI.log", zeei])
		bsc_lst.append(["Q3VERSION.log", "ZDFD:OMU:88E;"])
		for logname, cmd in bsc_lst:
			if self.check_logs() == True:
				log(self.work_dir.get_name() + os.sep + logname).write(self.ne.tx(cmd))
			else:
				return
		
		#Get BCF Inventory:#########
		for p in stream_to_text(self.ne, "ZWQO:CR;"):
			if " BU " in p:
				sw_ver = p[45:61].strip()
				
		bsc_cnumber = ""
		if sw_ver.split()[0] == "SG":			
			bcf_hw_file = self.work_dir.get_name() + os.sep + "BCF_HARDWARE.csv"
			
			tid = False
			for p in stream_to_text(self.ne, "ZQNI;"):
				if "CON  TYPE     SW  C-NUM   ID  NAME" in p:
					tid = True
				elif tid and len(p.strip()) > 1:
					bsc_name = p.split()[4]
					bsc_cnumber = p.split()[3]
					tid = False
					break
			self.ne.set_name(self.name)
			
			#get bcf list:
			bcfl = []
			for p in stream_to_text(self.ne, "ZEEI;"):
				if "BCF-" in p:
					bcfl.append(p.split()[0].replace("BCF-", ""))
			
			for bcf in bcfl:	
				inq_hw_list(self.ne, bcf, bsc_cnumber, sw_ver, bcf_hw_file)

											
		#Get maximum bts id:
		fp = open(self.work_dir.get_name() + os.sep + "ZEEI.log", "rb")
		out = fp.readlines()
		max_bts = 10
		bts_list=[]
		for line in out:
			if "BTS-" in line and not "SBTS-" in line:
				bts = line.split("BTS-")[1].split(" ")[0]
				bts_list.append(bts)			
				if int(bts) > max_bts:
					max_bts = int(bts)		
		max_bcf = max_bts												
		if int(max_bcf) > 3000:
			max_bcf = 3000
																		   
		fp.close()		
		#END OF BCF Inventory:#########	
		
		bsc_lst = []

		for b in bts_list:
			bsc_lst.append(["ZERO.log", "ZERO:BTS=" + str(b) + ";"])
			bsc_lst.append(["ZEQO.log", "ZEQO:BTS=" + str(b) + ":ALL;"])
			
		bsc_lst.append(["ZEWO.log", "ZEWO:1&&" + str(max_bcf) + ";"])
		bsc_lst.append(["ZEEIBCSU.log", "ZEEI::BCSU;"])
		bsc_lst.append(["ZEBP.log", "ZEBP;"])
							
		gbip = False
		if "FEATURE STATE:.............ON" in self.ne.tx("ZW7I:FEA,FULL:FEA=7;"):
			gbip = True
		
		if gbip == True:
			bsc_lst.append(["ZFXI.log", "ZFXI:NSEI=0&&65535;"])
		
		if not "BCXU" in self.ne.tx("ZUSI:COMP;"):		
			bsc_lst.append(["ZFXO.log", "ZFXO:NSEI=0&&65535;"])

		for logname, cmd in bsc_lst:
			if self.check_logs() == True:
				log(self.work_dir.get_name() + os.sep + logname).write(self.ne.tx(cmd))
			else:
				break	
			

class mcrnc:
	def __init__ (self, ip, _user, _password):
		self.ip = ip
		self.name = "-"
		self._user = _user
		self._password = _password				
		self.ne = dev_lin(ip, _user, _password)
		self._type = "mcRNC"
		self.ne.tx("set cli built-in rows -1")		
		self.name = self.get_line(self.ne.tx("show radio-network omsconn"), "RNC name:").replace("PRNC name:", "").replace("RNC name:", "").strip()
		
		if len(self.name) == 0:
			wdir = LOG_DIRE + os.sep + self.ip + "_failed"
			os.mkdir(wdir)			
			return
			
		wdir = LOG_DIRE + os.sep + self.name + "_running"

		#Creating the working directory:		
		if os.path.exists(str(wdir).replace("_running", "")):			
			return		
		
		self.work_dir = _dir(wdir)
		print "Dire = " + self.work_dir.get_name()

		self.write_on_file(self.work_dir.get_name() + os.sep + "RNC_IP", self.ip)
		self.write_on_file(self.work_dir.get_name() + os.sep + "ELEMENT_TYPE", "RNC")
		self.write_on_file(self.work_dir.get_name() + os.sep + "RNC_TYPE", "mcRNC")
		self.write_on_file(self.work_dir.get_name() + os.sep + "RNC_NAME", self.name)				
				
		#Get Logs:		
		self.ne.set_name(self.name)
		log(self.work_dir.get_name() + os.sep + "set_cli_built.log").write(self.ne.tx("set cli built-in rows -1"))
		log(self.work_dir.get_name() + os.sep + "omscon.log").write(self.ne.tx("show radio-network omsconn,"))
		log(self.work_dir.get_name() + os.sep + "licence_target_id.log").write(self.ne.tx("show license target-id,"))
		log(self.work_dir.get_name() + os.sep + "licences.log").write(self.ne.tx("show license all"))
		log(self.work_dir.get_name() + os.sep + "sw_delivery_id.log").write(self.ne.tx("show sw-manage app-sw-mgmt builds"))
		log(self.work_dir.get_name() + os.sep + "features.log").write(self.ne.tx("show license feature-mgmt usage all"))
		log(self.work_dir.get_name() + os.sep + "ss7.log").write(self.ne.tx("show signaling ss7 local-as all"))
		log(self.work_dir.get_name() + os.sep + "hw_inv.log").write(self.ne.tx("show hardware inventory list detailed"))
		log(self.work_dir.get_name() + os.sep + "hw_state.log").write(self.ne.tx("show hardware state list"))
		log(self.work_dir.get_name() + os.sep + "func_unit.log").write(self.ne.tx("show has functional-unit unit-info"))
		log(self.work_dir.get_name() + os.sep + "ZWOI.log").write(self.ne.tx("show app-parameter configuration-parameter"))
		log(self.work_dir.get_name() + os.sep + "ZWOS.log").write(self.ne.tx("show app-parameter feature-optionality"))
		
		os.rename(self.work_dir.get_name(), self.work_dir.get_name().replace("_running", ""))
				
	def write_on_file(self, fname, string):
		fp = open(fname, "wb")
		fp.write(string)
		fp.close()						
			
	
	def get_line(self, string, search):
		lin = ""
		for c in string:
			if '\n' in c:
				if search in lin:				
					return lin
				lin = ""
			else:
				lin = lin + str(c)
		return ""
							
class dxipa:
	def __init__(self, ip, _user, _password):
		
		self._type = "-"
		self.failed = False				
		#Init ne_list_dictionary:
		self.netypelist = {}		
		self.netypelist["mcBSC"] = "DX200"
		self.netypelist["BSC"] = "DX200"
		self.netypelist["BSC2i"] = "DX200"
		self.netypelist["BSC3i"] = "DX200"
		self.netypelist["FlexiBSC"] = "DX200"
		self.netypelist["Flexi NS"] = "DX200"
		self.netypelist["SGSN"] = "DX200"
		self.netypelist["RNC"] = "IPA2800"
		
		self.ip = ip
		self._user = _user
		self._password = _password		
		self.ne = dev_dx(ip, _user, _password)
						
		#Tmp file:
		self.tmp_file = _file(self.ip)

		#Type and name:
		self.set_type()
		
		if self._type == "-":
			wdir = LOG_DIRE + os.sep + self.ip + "_failed"
			os.mkdir(wdir)			
			return
		
		self.ne.set_name(self.name)
		wdir = LOG_DIRE + os.sep + self.name + "_running"
		try:
			self.platform = self.netypelist[self._type]
		except:
			self.platform = "-"
			
		#Creating the working directory:				
		if os.path.exists(str(wdir).replace("_running", "")):			
			return
		
		
		self.work_dir = _dir(wdir)
												
		#Get logs related to DX/IPA plataforms:
		if "BSC" in self._type:
			_bsc = bsc(self)
			
		if "RNC" in self._type:
			_rnc = rnc(self)
				
						
		ipa_dx_lst = []	
		ipa_dx_lst.append(["ZUSI.log", "ZUSI;"])
		ipa_dx_lst.append(["ZQRIOMU.log", "ZQRI:OMU;"])
		ipa_dx_lst.append(["PRFILE_VER.log", "ZWQV:OMU:PRFILEGX;"])
		ipa_dx_lst.append(["FIFILE_VER.log", "ZWQV:OMU:FIFILEGX;"])
		ipa_dx_lst.append(["ZDOI.log", "ZDOI::M;"])
		ipa_dx_lst.append(["ZWQO.log", "ZWQO:CR;"])
		ipa_dx_lst.append(["ZWOI.log", "ZWOI;"])
		ipa_dx_lst.append(["ZWOS.log", "ZWOS;"])
		ipa_dx_lst.append(["ZW7IFULL.log", "ZW7I:FEA,FULL:FSTATE=ON;"])
		ipa_dx_lst.append(["ZW7ILIC.log", "ZW7I:LIC,FULL;"])
		ipa_dx_lst.append(["ZW7IUCAP.log", "ZW7I:UCAP;"])
		ipa_dx_lst.append(["ZNET.log", "ZNET;"])
		
		dx_lst = []
		dx_lst.append(["ZWTI.log", "ZWTI:PI;"])
		dx_lst.append(["ZQNI.log", "ZQNI;"])
		dx_lst.append(["ZQLI.log", "ZQLI;"])
		dx_lst.append(["ZTPI.log", "ZTPI;"])
		
		ipa_lst = []
		ipa_lst.append(["ZWFI.log", "ZWFI:P;"])
		ipa_lst.append(["ZWFL.log", "ZWFL:P;"])
				
		if self.platform == "DX200" or self.platform == "IPA2800":						
			for logname, cmd in ipa_dx_lst:
				if self.check_logs() == True:
					log(self.work_dir.get_name() + os.sep + logname).write(self.ne.tx(cmd))
				else:
					break
							
		if self.platform == "DX200":			
			for logname, cmd in dx_lst:
				if self.check_logs() == True:
					log(self.work_dir.get_name() + os.sep + logname).write(self.ne.tx(cmd))
				else:
					break
		
		if self.platform == "IPA2800":		
			for logname, cmd in ipa_lst:
				if self.check_logs() == True:
					log(self.work_dir.get_name() + os.sep + logname).write(self.ne.tx(cmd))
				else:
					break
			
		if self.check_logs() == True:
			#Get Licences:						
			self.get_file("W0-LICENCE/*.XML", "LICENCE")
									
			#Get PRFILE and FIFILE:		
			self.get_file("W0-LFILES/PRFILE*.IMG", "LFILES")
			self.get_file("W0-LFILES/FIFILE*.IMG", "LFILES")
			self.get_file("W0-LFILES/FIFILE*.txt", "LFILES")
			self.get_file("W0-LFILES/FIFILE*.TXT", "LFILES")
			self.get_file("W0-LFILES/XIPIF*.XML", "LFILES")
			self.get_file("W0-LFILES/POCIP*.IMG", "LFILES")	
		
		if self.check_logs() == True:
			os.rename(self.work_dir.get_name(), self.work_dir.get_name().replace("_running", ""))
		else:
			os.rename(self.work_dir.get_name(), self.work_dir.get_name().replace("_running", "_failed"))
			
		try:
			self.disconnect()
		except:
			pass			
						
	def check_logs(self):
		if self.failed == True:
			return False
		ret = True
		dire = self.work_dir.get_name()		
		for f in listdir(dire):
			if ".log" in f:
				fn = dire + os.sep + f			
				fp = open(fn, "rb")	
				for l in fp.readlines():
					if "COMMAND EXECUTION FAILED" in l:															
						self.failed = True
						fp.close()
						return ret
				fp.close()
		return ret
									
	def disconnect(self):
		try:
			self.ne.disconnect()
		except:
			pass
		
	def get_type(self):
		return self._type
	
	def get_name(self):
		return self.name
		
	def set_type(self):
		#_fp = _file(self.ip)
		fp = self.tmp_file.get_fp()
		fp.write(self.ne.tx("ZZ?", "Z; .... END"))		
		self.tmp_file.close()
	
		self.tmp_file.open()		
		fp = self.tmp_file.get_fp()				
		for line in fp.readlines():
			if "-" in line and ":" in line:
				self._type = line[0:9].strip()
				self.name = line[10:25].strip().split(' ')[0]
			
		self.tmp_file.close()		
		
	def set_name(self, name):
		self.name = name
		
	def get_name(self):
		return self.name
	
	def set_targetid(self, targetid):
		self.targetid = targetid
	
	def get_targetid(self):
		return self.targetid

	def write_on_file(self, fname, string):
		fp = open(fname, "wb")
		fp.write(string)
		fp.close()		
				
	def get_file(self, file_path, dest_dir):
		
		log_dir = _dir(self.work_dir.get_name() + os.sep + dest_dir)
		
		self.tmp_file.clear()
		fp = self.tmp_file.get_fp()
		
		
		fp.write(self.ne.tx("ZDDE::\"ZL:M\",\"ZLP:M,MAS\",\"ZMX:" + file_path + "\";"))
		self.tmp_file.close()
									
		self.tmp_file.open()
		fp = self.tmp_file.get_fp()
		
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
		ind = 0
		for f in filelist:
			ind += 1
			self.tmp_file.clear()
			fp = self.tmp_file.get_fp()
			
			fp.write(self.ne.tx("ZDDE::\"ZMTE:W0-" + dire + f + "\";"))
			fp.close()
								
			file_fp = open(self.work_dir.get_name() + os.sep + dest_dir + os.sep + f, "wb")
			self.tmp_file.open()
			fp = self.tmp_file.get_fp()
			
			for lin in fp.readlines():				
				if "NO SUCH FILE" in lin:		
					break
				elif ":  " in lin:
					for val in lin[5:56].strip().split(" "):
						try:
							file_fp.write("%c" % int(val, 16))
						except:
							print "Error on file " + f + " for IP: " + self.ip + " name: " + self.name + " ;"
						
			self.tmp_file.close()
			file_fp.close()
