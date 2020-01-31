#!/usr/bin/python 

from Crypto.Cipher import AES
import base64
import sys
import getpass
import uuid

user = raw_input('ENTER USERNAME:')

pwd1 = "1"
pwd2 = "2"

while pwd1 != pwd2:
	pwd1 = getpass.getpass('ENTER PASSWORD:')
	pwd2 = getpass.getpass('ENTER PASSWORD VERIFICATION:')
	if pwd1 != pwd2:		
		raw_input("PASSWORDS DON'T MATCH!")


resp = "k"
while True:
	resp = raw_input('''DO YOU WANT TO ENTER A NEW KEY FOR PASSWORD ENCRYPTION?
   1 -> NO, A NEW KEY WILL BE GENERATED;
   2 -> YES, YOU WILL ENTER YOUR OWN KEY
YOUR RESPONSE:''')
	if resp == "1" or resp == "2":
		break
	else:
		print "Invalid response!"
	

if resp == "2":
	key1 = "1"	
	key2 = "2"
	print
	print "KEY MUST BE EITHER 16, 24, OR 32 BYTES LONG!"
	while key1 != key2:
		while True:
			key1 = getpass.getpass('ENTER KEY:')			
			if len(key1) == 16 or len(key1) == 24 or len(key1) == 32:
				break
			else:
				print
				print "KEY MUST BE EITHER 16, 24, OR 32 BYTES LONG!"
						
		while True:
			key2 = getpass.getpass('ENTER KEY VERIFICATION:')
			if len(key2) == 16 or len(key2) == 24 or len(key2) == 32:
				break
			else:
				print
				print "KEY MUST BE EITHER 16, 24, OR 32 BYTES LONG!"
		
		
		if key1 != key2:		
			raw_input("KEYS DON'T MATCH!")

	secret_key = str(key1)
else:
	secret_key = str(uuid.uuid4())[:16]		
input_str = str(user.strip()) + "," + str(pwd1.strip())
msg_text = input_str.rjust(32)


cipher = AES.new(secret_key,AES.MODE_ECB) # never use ECB in strong systems obviously
encoded = base64.b64encode(cipher.encrypt(msg_text)).strip()

out_fn = str(uuid.uuid4()) + ".txt"
outfile = open(out_fn, "w")

outfile.write("_____________________________________________________________________\n")
outfile.write("Encoded password: " + encoded.strip() + "\n")
outfile.write("Key: " + secret_key + "\n")
outfile.write("YOU MUST SAVE THIS KEY, it will be used when you start the script!\n\n")
outfile.write("Example:\n")
outfile.write("10.20.0.2:22,DX200," + encoded.strip() + "\n") 
outfile.write("10.20.1.3:22,IPA2800," + encoded.strip() + "\n")
outfile.write("10.20.2.4:22,mcRNC," + encoded.strip() + "\n")
outfile.write("_____________________________________________________________________\n")

raw_input("\n\n " + out_fn + " has been created. \nThis file has the encrypted password information!\n")

#print encoded.strip()
#print cipher.decrypt(base64.b64decode(encoded)).strip()

