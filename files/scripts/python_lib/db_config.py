#!/usr/bin/python

class config:
	def __init__(self):
		self.__config_file = "/opt/nokia/nedata/scripts/var.conf"
		self.__work_dir = ""
		self.__cf_files_dir = ""
		self.__db_config_file = ""
		self.__mysql_user = ""
		self.__mysql_pass = ""
		self.__mysql_host = "127.0.0.1"
		self.__db1_name = ""
		self.__db2_name = ""

		#Get WORK_DIR variable:
		fp = open(self.__config_file, "rb")
		for l in fp.readlines():
			if "export WORK_DIR" in l:
				self.__work_dir = l.strip().split("=")[1].strip()
		fp.close()
		
		#Get CF_FILES variable:
		fp = open(self.__config_file, "rb")
		for l in fp.readlines():
			if "export CF_FILES_DIR" in l:
				self.__cf_files_dir =  l.strip().replace("$WORK_DIR", self.__work_dir).split("=")[1].strip().replace("\"", "")				
		fp.close()				

		#Get CF_FILES variable:
		fp = open(self.__config_file, "rb")
		for l in fp.readlines():
			if "export CF_FILES_DIR" in l:
				self.__cf_files_dir =  l.strip().replace("$WORK_DIR", self.__work_dir).split("=")[1].strip().replace("\"", "")				
		fp.close()
		
		#Get DB_CONFIG_FILE	variable:
		fp = open(self.__config_file, "rb")
		for l in fp.readlines():
			if "export DB_CONFIG_FILE" in l:
				self.__db_config_file = l.strip().replace("$CF_FILES_DIR", self.__cf_files_dir).split("=")[1].strip().replace("\"", "")				
		fp.close()
		
		#Get DB1_NAME and DB2_NAME
		fp = open(self.__config_file, "rb")
		for l in fp.readlines():
			if "export DB1_NAME" in l:
				self.__db1_name = l.strip().split("=")[1].replace("\"", "")
			if "export DB2_NAME" in l:
				self.__db2_name = l.strip().split("=")[1].replace("\"", "")				
		fp.close()		
		
		#Get mysql_user and mysql_pass from db_config_file:
		fp = open(self.__db_config_file, "rb")
		for l in fp.readlines():
			if not l[0] == "#":
				if "mysql_user = " in l:
					self.__mysql_user = l.strip().split("=")[1].strip()
				elif "mysql_user_pw = " in l:
					self.__mysql_pass = l.strip().split("=")[1].strip()
	
	def get_mysql_user(self):
		return self.__mysql_user
		
	def get_mysql_pass(self):
		return self.__mysql_pass
	
	def get_mysql_host(self):
		return self.__mysql_host
	
	def get_db1_name(self):
		return self.__db1_name

	def get_db2_name(self):
		return self.__db2_name		
	
