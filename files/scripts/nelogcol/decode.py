from Crypto.Cipher import AES
import base64
import sys
import getpass
import uuid


pwd_encoded = raw_input('ENTER ENCODED VALUE:')
key  = raw_input('ENTER THE KEY:')

cipher = AES.new(key,AES.MODE_ECB)
decoded = cipher.decrypt(base64.b64decode(pwd_encoded)).strip()

print decoded
