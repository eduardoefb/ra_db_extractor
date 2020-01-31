#!/bin/bash

source /opt/nokia/nedata/scripts/var.conf

db_user=`grep "mysql_user " $DB_CONFIG_FILE | awk '{print $NF}'` 
db_pass=`grep "mysql_user_pw " $DB_CONFIG_FILE | awk '{print $NF}'`

mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "DELETE FROM files WHERE files.status LIKE '%ATING' ;"
mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "DELETE FROM xlsxfiles WHERE xlsxfiles.status LIKE '%ATING' ;"
rm $SCRIPT_RUNNING_FILE 2>/dev/null

