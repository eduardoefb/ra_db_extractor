#!/usr/bin/python

from connections import _dir, _file, log, dev_dx, dev_lin, TMP_DIRE, LOG_DIRE
import sys, traceback, os, time
import datetime

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
		
def inq_hw_list(bcf, bsc_cnumber):	
	#get omusig number:
	packet_abis = False
	for p in stream_to_text(bsc, "ZEFO:" + str(bcf) + ";"):
		if "D-CHANNEL LINK SET" in p:
			dch = p.split()[3]	
		if "PACKET ABIS" in p:
			packet_abis = True
				
	#get
	sran = False
	for p in stream_to_text(bsc, "ZEEI:BCF=" + str(bcf) + ";"):
		if "BCF-" in p:
			bcxu = p[57:65].strip()
			bcf_type = p[10:23].strip()
			if "SBTS-" in p:
				sran = True	
				
	#Sran don't respond hw request:
	if sran == True:
		return
		
	bcxu_t = False
	if "BCXU-" in bsc.tx("ZUSI:COMP;"):
		bcxu_t = True
	
	if bcxu_t:
		bcsu = "BCXU"
	else:
		bcsu = "BCSU"
	
	
	for l in stream_to_text(bsc, "ZUSI:" + bcsu + "," + str(bcxu) + ";"):
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
					
	bsc.connect()
	cmd_list = []
	cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])
	cmd_list.append(["ZOEQ", ">"])
	cmd_list.append(["ZOEBR::7FFF", ">"])
	cmd_list.append(["ZOEC::R:(NUM=5992)AND(DATW00=" + ("%.4x" % (int(dch))).upper()  + ")", ">"])
	cmd_list.append(["ZOEM", ">"])
	cmd_list.append([cmd, ">"])
	cmd_list.append(["ZZE;", "COMMAND EXECUTED"])
	
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " BCF " + str(bcf) + " Querying the units;"
	bsc.sendlist(cmd_list)
	
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " BCF " + str(bcf) + " Waiting for bcf response..."
	time.sleep(2)	
	bsc.disconnect()	
	if "Message count: 0" in bsc.tx("ZDDE:" + bcsu + "," + bcxu + ":\"ZOEI\";"):
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " BCF " + str(bcf) + " Waiting for bcf response..."
		time.sleep(4)
		if "Message count: 0" in bsc.tx("ZDDE:" + bcsu + "," + bcxu + ":\"ZOEI\";"):			
			print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " No response from bcf..."
			return
				
	#get intex of first msg:
	units = get_units_from_msg(conv(stream_to_text(bsc, "ZDDE:" + bcsu + "," + bcxu + ":\"ZOES\", \"ZOEG\";")), 0, 0, 0)
	
	cmd_list = []
	cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])	
	if len(units) > 0:
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " BCF " + str(bcf) + " Found " + str(len(units)) + " Units;"
		bsc.connect()
		cmd_list = []
		cmd_list.append(["ZDDS:" + bcsu + "," + bcxu + ";" , ">"])
		cmd_list.append(["ZOEQ", ">"])
		cmd_list.append(["ZOEBR::7FFF", ">"])
		cmd_list.append(["ZOEC::R:(NUM=5992)AND(DATW00=" + ("%.4x" % (int(dch))).upper()  + ")", ">"])
		cmd_list.append(["ZOEM", ">"])		
		
		cmd_list.append(["ZZE;", "COMMAND EXECUTED"])
		bsc.sendlist(cmd_list)		
		
		time.sleep(2)
		bsc.disconnect()		
		
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
		cmd_list.append(["ZZE;", "COMMAND EXECUTED"])
				
		
	time.sleep(2)		
	bsc.connect()
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " BCF " + str(bcf) + " Querying the " + str(len(units)) + " Units;"
	bsc.sendlist(cmd_list)
	print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " " + bsc.name + " BCF " + str(bcf) + " Waiting for bcf response..."			
	time.sleep(1)
		
	units = get_units_from_msg(conv(stream_to_text(bsc, "ZDDE:" + bcsu + "," + bcxu + ":\"ZOES\", \"ZOEG\";")), 1, bsc_cnumber, bcf)
	bsc.disconnect()		
				
	for u in units:
		#u.print_all()
		print(u.get_units())
		
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


#bcf = 6
bsc = dev_dx("10.52.5.4:22", "SYSTEM", "FBSC4SYSTEM") #lab (bsc17)

#bcf = 268
#bsc = dev_dx("127.0.0.1:10726", "Z75414", "654321")  #bsc53iga (gsm18)

#bcf = 127
#bsc = dev_dx("127.0.0.1:10615", "Z75414", "654321")  #bsc02pcs (bsc16)

bsc.set_timeout(1000)

for p in stream_to_text(bsc, "ZWQO:CR;"):
	if " BU " in p:
		sw_ver = p[45:61].strip()

bsc_name = ""
bsc_cnumber = ""
if sw_ver.split()[0] != "SG":
	print "Software version not supported"	
else:
	tid = False
	for p in stream_to_text(bsc, "ZQNI;"):
		if "CON  TYPE     SW  C-NUM   ID  NAME" in p:
			tid = True
		elif tid and len(p.strip()) > 1:
			bsc_name = p.split()[4]
			bsc_cnumber = p.split()[3]
			tid = False
			break
	bsc.set_name(bsc_name)
	
	#get bcf list:
	bcfl = []
	for p in stream_to_text(bsc, "ZEEI;"):
		if "BCF-" in p:
			bcfl.append(p.split()[0].replace("BCF-", ""))
	
	for bcf in bcfl:	
		inq_hw_list(bcf, bsc_cnumber)





			
