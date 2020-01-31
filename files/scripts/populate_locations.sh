#!/bin/bash

source /opt/nokia/nedata/scripts/var.conf

mysql_user=`grep "mysql_user " $DB_CONFIG_FILE | awk '{print $NF}'`
mysql_pass=`grep "mysql_user_pw " $DB_CONFIG_FILE | awk '{print $NF}'`


#Drop and create table:
mysql -u $mysql_user -p"$mysql_pass" $DB1_NAME << EOF
   DROP TABLE IF EXISTS locations;

   CREATE TABLE locations (
	   customer_id VARCHAR(10) NOT NULL,
	   string VARCHAR(20) DEFAULT "-",
	   state VARCHAR(20) DEFAULT "-",
	   location VARCHAR(40) DEFAULT "-"	   
   ); 
   
EOF


for f in `ls $CF_FILES_DIR/*_location.conf`; do
   customer=`echo $f | awk -F '/' '{gsub("_location.conf", ""); print $NF}'`      
   customer_id=`mysql -sN -u $mysql_user -p"$mysql_pass" << EOF
      SELECT $DB1_NAME.cliente.id FROM $DB1_NAME.cliente WHERE $DB1_NAME.cliente.name = '$customer';
EOF`
  
   for l in `cat $f`; do      
      string=`echo $l | awk -F '-' '{print $1}'`
      state=`echo $l | awk -F '-' '{print $2}'`
      location=`echo $l | awk -F '-' '{print $3}'`
      echo -n "Creating: $customer_id $customer $string $state $location ..."
      mysql -u $mysql_user -p"$mysql_pass" $DB1_NAME << EOF
      INSERT INTO locations (customer_id, string, state, location) VALUES ('$customer_id', '$string', '$state', '$location');      
EOF
      echo "DONE"
   done
done
