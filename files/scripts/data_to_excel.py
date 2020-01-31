#!/usr/bin/python

import mysql.connector, xlsxwriter, sys, os, argparse, datetime

#Get python_lib directory:
cfile = "/opt/nokia/nedata/scripts/var.conf"
wdir = ""
sdir = ""
fp = open(cfile, "rb")
for l in fp.readlines():
	if "export WORK_DIR=" in l:
		wdir = l.replace("export WORK_DIR=", "").strip()
fp.close()

fp = open(cfile, "rb")
for l in fp.readlines():
	if "export SCRIPT_DIR=" in l:
		sdir = l.replace("export SCRIPT_DIR=", "").strip()
		sdir = sdir.replace("$WORK_DIR", wdir)
fp.close()

sys.path.append(sdir + "/python_lib")
import db_config
	
class esheet:
	def __init__(self, wb, name, db, query):
		self.__wb = wb
		self.__name = name
		self.__ws = wb.add_worksheet(name)
		self.__col_size = []
		self.set_format()
		self.__query = query
		self.__db = db
		self.__lines = 0
		self.execute_query()
		
		
	def execute_query(self):
		self.__cursor = self.__db.cursor()
		try:
			self.__cursor.execute(self.__query)
			self.__result = self.__cursor.fetchall()		
			self.set_column_names(self.__cursor.column_names)
			ret = self.set_lines(self.__result)
			self.auto_size()		   
		except:
			self.__ws.write(0, 0, "QUERY EXECUTION ERROR!!!", self.__fmt_header);
			self.__ws.set_column(0, 0, 30)
			
				
	def set_format(self):
		self.__fmt_header = self.__wb.add_format()
		self.__fmt_header.set_bold()
		self.__fmt_header.set_font_color('#FFFFFF')
		self.__fmt_header.set_bg_color('#1f4e79')
		self.__fmt_header.set_font_size(8)
		self.__fmt_header.set_border(1)

		self.__fmt_gen = self.__wb.add_format()			
		self.__fmt_gen.set_font_color('#000000')
		self.__fmt_gen.set_bg_color('#e7e6e6')	
		self.__fmt_gen.set_font_size(8)
		self.__fmt_gen.set_border(1)
	
	def set_column_names(self, data):
		lin = col = 0;
		for x in data:
		  self.__ws.write(0, col, x, self.__fmt_header);
		  self.__col_size.append(len(x))
		  col += 1
		  			
	def set_lines(self, data):
		lin = col = 0;
		for x in self.__result: 
			lin += 1
			col = 0
			for i, y in enumerate(x):		
				self.__ws.write(lin, col, str(y), self.__fmt_gen);
				if(self.__col_size[i] < len(str(y).strip())):
					self.__col_size[i] = len(str(y).strip())
				col += 1
		
		self.__lines = lin		
	
	def auto_size(self):				
		for i, x in enumerate(self.__col_size):			
			self.__ws.set_column(i, i, x)
	
	def get_lines(self):
		return self.__lines

reload(sys)
sys.setdefaultencoding('utf8')		

parser = argparse.ArgumentParser(description='Import data from DB and create Excel Files')
required = parser.add_argument_group('First file (adv or cmrepo):')
required.add_argument("-c", nargs = 1, help="Customer ID", required = True)
required.add_argument("-d", nargs = 1, help="Destination directory", required = True)
args = parser.parse_args()

customer_id = args.c[0]
output_dir = args.d[0]

#Mysql configuation:
conf = db_config.config()

#Get customer information:
mydb = mysql.connector.connect(
  host = conf.get_mysql_host(),
  user = conf.get_mysql_user(),
  passwd = conf.get_mysql_pass()
)

cr = mydb.cursor()
cr.execute("SELECT * FROM " + conf.get_db1_name() + ".cliente WHERE " + conf.get_db1_name() + ".cliente.id = " + str(customer_id))
res = cr.fetchall()



qf = False
query = ""

query_files = []
for qf in os.listdir(sdir + "/queries" + os.sep ):	
	if len(qf) > 4:
		if qf[len(qf)-4:len(qf)] == ".sql":			
			query_files.append(qf)
	
oxlsxf = ""

for q in query_files:
	for cid, cname in res:
		ziplines = 0
		zp_name = cname.upper() + "_" + q.replace(".sql", "").upper() + ".xlsx"		
		cr.execute("DELETE FROM " + conf.get_db1_name() + ".xlsxfiles WHERE " + conf.get_db1_name() + ".xlsxfiles.name = '" + zp_name + "'")
		cr.execute("INSERT INTO " +  conf.get_db1_name() + ".xlsxfiles (" +  conf.get_db1_name() + ".xlsxfiles.name, " +  conf.get_db1_name() + ".xlsxfiles.created_date, " +  conf.get_db1_name() + ".xlsxfiles.status) VALUES ('" + str(zp_name) + "', '" + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + "', 'CREATING')")
		mydb.commit()
		print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + " --> Quering customer id: " + str(cid) + " (" + cname + ") " + cname.upper() + "_" + q.replace(".sql", "").upper() + "... (this may take time)"		
		oxlsxf = output_dir + cname.upper() + "_" + q.replace(".sql", "").upper() + ".xlsx"		
		wb = xlsxwriter.Workbook(oxlsxf)
		fp = open(sdir + "/queries" + os.sep + q, "rb")	
		lines = 0
		for l in fp.readlines():
			if "/*QUERY_NAME:" in l:
				qf = False
				query = ""
				sheet_name = l.strip().replace("QUERY_NAME:", "").split("*")[1].strip()								
						
			if l.strip().startswith("SELECT "):
				if qf == False:
				   qf = True
				   query = l.strip()
				else:
					query = str(query) + " " + str(l.strip())
									
			elif qf == True:
				query = str(query) + " " + str(l.strip())
				
			if ";" in l:
				qf = False
				query = query.replace("_log_", conf.get_db1_name()).replace("_cid_", str(cid))
				query = query.replace("_xml_", conf.get_db2_name())	
				sh = esheet(wb, sheet_name, mydb, query)
				lines = lines + sh.get_lines()
				if lines > 0:
					print str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))  + " --> " + cname + " " + sheet_name + " " + str(sh.get_lines()) + " lines"
				
						
		wb.close()
		fp.close()
		ziplines += lines
		
		if lines == 0:
			try:				
				os.remove(oxlsxf)								
				cr.execute("DELETE FROM " + conf.get_db1_name() + ".xlsxfiles WHERE " + conf.get_db1_name() + ".xlsxfiles.name = '" + zp_name + "'")
			except:
				pass
		else:			
			cr.execute("UPDATE " +  conf.get_db1_name() + ".xlsxfiles SET " +   conf.get_db1_name() + ".xlsxfiles.status = 'CREATED', " + conf.get_db1_name() + ".xlsxfiles.finished_date = '" + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + "' WHERE " + conf.get_db1_name() + ".xlsxfiles.name = '" + str(zp_name) + "';")
			
		mydb.commit()
		
