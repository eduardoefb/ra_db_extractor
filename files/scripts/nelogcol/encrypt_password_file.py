#!/usr/bin/python 

from Crypto.Cipher import AES
import base64
import sys
import getpass
import uuid

class con:
	def __init__(self):
		self.__ip = ""
		self.__type = ""
		self.__user = ""
		self.__pass = ""
	
	def get_ip(self):
		return self.__ip

	def get_type(self):
		return self.__type

	def get_user(self):
		return self.__user

	def get_pass(self):
		return self.__pass
	
	def set_ip(self, arg):
		self.__ip = arg

	def set_type(self, arg):
		self.__type = arg

	def set_user(self, arg):
		self.__user = arg

	def set_pass(self, arg):
		self.__pass = arg
		


cl = []
fin = sys.argv[1]

fp = open(fin, "r")
for l in fp.readlines():
	if l.count(",") >= 3:
		c = con()
		c.set_ip(l.strip().split(",")[0])		
		c.set_type(l.strip().split(",")[1])
		c.set_user(l.strip().split(",")[2])
		c.set_pass(l.strip().split(",")[3])
		cl.append(c)
		
fp.close()

#Create a random key:
secret_key = str(uuid.uuid4())[:16]		

fout = str(uuid.uuid4()) + "_ne.csv"
fp = open(fout, "w")
cipher = AES.new(secret_key,AES.MODE_ECB) # never use ECB in strong systems obviously


fp.write("#MAX_SIM_NE=50\n")
for c in cl:
	input_str = str(c.get_user().strip()) + "," + str(c.get_pass().strip())
	msg_text = input_str.rjust(32)	
	encoded = base64.b64encode(cipher.encrypt(msg_text)).strip()
	fp.write(c.get_ip() + "," + c.get_type() + "," + encoded.strip() + "\n")
	
fp.close()

out_fn = fout.replace("_ne.csv", "_key.txt")
outfile = open(out_fn, "w")

outfile.write("_____________________________________________________________________\n")
outfile.write("Key: " + secret_key + "\n")
outfile.write("YOU MUST SAVE THIS KEY, it will be used when you start the script!\n\n")
outfile.write("_____________________________________________________________________\n")

raw_input("\n\n " + fout + " has been created. This file contains ips and encrypted passwords\n Use the key in " + out_fn + " to the encrypted password information!\n")
outfile.close()

#print encoded.strip()
#print cipher.decrypt(base64.b64decode(encoded)).strip()

