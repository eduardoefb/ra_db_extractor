#!/usr/bin/python

import sys

parameter_file = "par.conf"
xmlfile = sys.argv[1]
parameter_file = sys.argv[2]

act_par = []
fp = open(parameter_file, "rb")

for f in fp.readlines():
	if f[0] != "#":
		act_par.append(f.strip())

fp.close()

header = ""
fotter = ""
show_line = False
header_showed = False
is_list = False
show_fotter = False
with open(xmlfile, 'rb') as f:
	for l in f:
		if "<header>" in l or "<log dateTime=" in l or "</header>" in l:
			sys.stdout.write(l)
					
		if "<managedObject class" in l:
			header = l
			header_showed = False
			cls = l.strip().split('"')[1]
		elif "</managedObject>" in l:			
			if show_fotter:
				sys.stdout.write(l)
			show_fotter = False
					
		#Process lists:
		elif "<list name=" in l:
			is_list = True			
			par = l.strip().split('"')[1]			
			if cls + "." + par in act_par:
				show_line = True
				show_fotter = True
				if not header_showed:
					sys.stdout.write(header)
					header_showed = True
			else:				
				show_line = False		
								
		elif "</list>" in l:
			is_list = False
			if show_line:
				sys.stdout.write(l)
				show_line = False
						
		#Parameters outside lists:			
		elif is_list == False:			
			if "<p name=" in l:				
				par = l.strip().split('"')[1]								
				if cls + "." + par in act_par:					
					show_line = True
					show_fotter = True
				else:
					show_line = False
		
		#Process parameters:		
		if show_line == True and not "</managedObject>" in l and not "<managedObject class=" in l:
			if not header_showed:
				sys.stdout.write(header)
				header_showed = True
				
			sys.stdout.write(l)
