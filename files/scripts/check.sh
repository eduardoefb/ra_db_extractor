#!/bin/bash

function remove_from_xml(){ 
   uuid=$1
   source /opt/nokia/nedata/scripts/var.conf

   #Check files inside tmp_log and delete the files that are not in sql:
   db_user=`grep "mysql_user " $DB_CONFIG_FILE | awk '{print $NF}'` 
   db_pass=`grep "mysql_user_pw " $DB_CONFIG_FILE | awk '{print $NF}'`
   unset tables
   tables=()
   for t in `mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SHOW TABLES;" `; do
      tables+=($t)      
   done
   
   for t in ${tables[*]}; do
      mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "DELETE FROM $t WHERE file_uuid = '$uuid' ;"
   done   
}

function remove_from_log(){ 
   uuid=$1
   source /opt/nokia/nedata/scripts/var.conf

   #Check files inside tmp_log and delete the files that are not in sql:
   db_user=`grep "mysql_user " $DB_CONFIG_FILE | awk '{print $NF}'`
   db_pass=`grep "mysql_user_pw " $DB_CONFIG_FILE | awk '{print $NF}'`
   
   tables=(trx bts bcf bsc_fifile bsc_to_licence bsc_lk_file bsc_prfile plugin_units_bsc units_bsc bsc)
      
   for t in ${tables[*]}; do
      mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "DELETE FROM $t WHERE file_uuid = '$uuid' ;"
   done
   
   tables=(rnc_to_licence rnc_lk_file hw_mcrnc wbts units_rnc rnc_to_licence rnc_prfile rnc_fifile rnc_lk_file rnc)
      
   for t in ${tables[*]}; do
      mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "DELETE FROM $t WHERE file_uuid = '$uuid' ;"
   done   
   
     
}

function extract_file(){
	source /opt/nokia/nedata/scripts/var.conf
	filename=$1
	uuid=$2	
	customer_name=`echo $filename | awk -F '-' '{print $2}'`	
	tmp_dir=`mktemp -d`
	unzip $filename -d $tmp_dir
	cwd=`pwd`
	cd $tmp_dir
	for f in `ls`; do
	   mv $f $NE_LOG_DIR/$customer_name/$uuid"-"$f
	done
	cd $cwd
	rm -rf $tmp_dir
}

source /opt/nokia/nedata/scripts/var.conf

#Check if script is alrady running.  If yes, quit:
if [ -f $SCRIPT_RUNNING_FILE ]; then
   exit
fi

#Create running file:
touch $SCRIPT_RUNNING_FILE

#Check files inside tmp_log and delete the files that are not in sql:
db_user=`grep "mysql_user " $DB_CONFIG_FILE | awk '{print $NF}'`
db_pass=`grep "mysql_user_pw " $DB_CONFIG_FILE | awk '{print $NF}'`

#If there is some jobs in activating, stop:
if [ `mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT files.id FROM files WHERE files.status = 'ACTIVATING'" | wc -l` -gt 0 ]; then
   exit
fi


#Delete files
for file in `ls $TMP_LOG_UPLOAD_DIR/*.zip | awk '{print $NF}'`; do
   filename=`echo $file | awk -F '/' '{print $NF}'`
   uuid=`echo $filename | awk -F '-' '{print $1}'`
   
   if [ `mysql -u $db_user -p$db_pass $DB1_NAME -e "SELECT * FROM files WHERE files.id = '$uuid'" | wc -l` -eq 0 ]; then
      rm -v $file
      remove_from_xml $uuid
      remove_from_log $uuid
   fi
done


clist=()
cname=()

#Delete filenames from database after removal:
mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "DELETE FROM files WHERE files.status = 'DELETED'" 

#Remove files that are in 'WAITING REMOVAL':
for uuid in `mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT files.id FROM files WHERE files.status = 'WAITING REMOVAL'"  `; do
   #Chage flag to deactivating:
   mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "UPDATE files SET files.status = 'DELETING' WHERE files.id = '$uuid'" 
   rm -v $TMP_LOG_UPLOAD_DIR/$uuid-*.zip
   
   #Remove objects using this file uuid:
   remove_from_xml $uuid
   remove_from_log $uuid      
   mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "UPDATE files SET files.status = 'DELETED' WHERE files.id = '$uuid'"  

done

#Activate files with status "WAITING DEACTIVATION"
for uuid in `mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT files.id FROM files WHERE files.status = 'WAITING DEACTIVATION'" `; do
   customer_id=`mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT files.customer_id FROM files WHERE files.id = '$uuid'"`
   customer_name=`mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT cliente.name FROM cliente WHERE cliente.id = '$customer_id'" `

   #Chage flag to deactivating:
   mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "UPDATE files SET files.status = 'DEACTIVATING' WHERE files.id = '$uuid'"  
   
   #Remove objects using this file uuid:
   remove_from_xml $uuid
   remove_from_log $uuid  

   exists=0
   for c in ${clist[*]}; do
      if [ "$c" == "$customer_id" ]; then
         exists=1
      fi
   done
   
   if [ $exists -eq 0 ]; then
      clist+=$customer_id
      cname+=$customer_name
   fi    
   
   #Chage flag to inactive:
   mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "UPDATE files SET files.status = 'INACTIVE' WHERE files.id = '$uuid'" 
done

#Activate files with status "WAITING ACTIVATION"
for uuid in `mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT files.id FROM files WHERE files.status = 'WAITING ACTIVATION'" `; do
   customer_id=`mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT files.customer_id FROM files WHERE files.id = '$uuid'" `
   customer_name=`mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "SELECT cliente.name FROM cliente WHERE cliente.id = '$customer_id'" `
   
   #Change flag to activating:
   mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "UPDATE files SET files.status = 'ACTIVATING' WHERE files.id = '$uuid'" 

   #check if customer is arleady in clist, if not, add:
   exists=0
   for c in ${clist[*]}; do
      if [ "$c" == "$customer_id" ]; then
         exists=1
      fi
   done
   
   if [ $exists -eq 0 ]; then
      clist+=$customer_id
      cname+=$customer_name
   fi
   
   #Remove processed_files:
   find $NE_LOG_DIR -name "*-current_database" -exec rm -rf {} \;  2>/dev/null
   extract_file $TMP_LOG_UPLOAD_DIR/$uuid*.zip $uuid   
   cd $NE_LOG_DIR   
   for f in `find -name "*.xml"`; do
      ff=`echo $f | sed 's/\.xml/\.full/g'`
      mv $f $ff
      
      echo "`date` Extracting object files from $f ..." 
      $OBJECT_CLASS_FILTER_SCRIPT $ff $OBJECT_CLASS_FILTER_FILE  >> $f
      rm -f $ff      
   done
   
   $PARSE_CMD $NE_LOG_DIR/$customer_name/ 
   mysql -Ns -u $db_user -p$db_pass $DB1_NAME -e "UPDATE files SET files.status = 'ACTIVE' WHERE files.id = '$uuid'" 
done

echo "`date` Parse finished. Genearting xlsx files ..."
ind=0

#Remove itens that have no "name"
for tables in `mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SHOW TABLES;" | grep -v "_"`; do
   mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "DELETE FROM $tables WHERE "$tables".name = '-' ;" 2>/dev/null
done

#Remove duplications:
rmdup=1

if [ $rmdup -eq 1 ]; then
   while :; do
      dups=0
      for tables in `mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SHOW TABLES;" | grep -v "_"`; do
         for dn in `mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SELECT distName, COUNT(*) AS times, IF (COUNT(*)>1,\"duplicated\", \" \") AS duplicated FROM $tables GROUP BY CONCAT(distName,name)" | grep "duplicated" | awk '{print $1}'`; do      
            dups=$(($dups+1))
            ver=`mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SELECT _version from $tables WHERE distName = '$dn' ORDER BY _version LIMIT 1"`
            name=`mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SELECT _version, name from $tables WHERE distName = '$dn' ORDER BY _version LIMIT 1" |awk '{print $2}'`         
            fuuid=`mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SELECT _version, file_uuid from $tables WHERE distName = '$dn' ORDER BY _version LIMIT 1" |awk '{print $2}'`         
            echo "`date` Removing duplication: $dn Version: $ver Name: $name $fuuid"
            mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "DELETE FROM $tables WHERE distName = '$dn' AND _version = '$ver' AND name = '$name'" 2>/dev/null
            for tab in `mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "SHOW TABLES;" | grep "_"`; do
               echo "`date` Removing duplication: $dn Version: $ver Name: $name $fuuid from tabble $tab"           
               mysql -Ns -u $db_user -p$db_pass $DB2_NAME -e "DELETE FROM $tab WHERE distName = '$dn' AND file_uuid = '$fuuid'" 2>/dev/null
            done
         done      
      done
      echo $dups
      if [ $dups -eq 0 ]; then
         break
      fi
   done
fi

for c in ${clist[*]}; do   
   rm -rf $WORK_DIR/xlsfiles/${cname[ind]}/  2>/dev/null
   rm -rf $XLS_DL_DIR/${cname[ind]}.zip 2>/dev/null
   mkdir -pv $WORK_DIR/xlsfiles/${cname[ind]}/   
   
   
   #$GENERATE_DATA_CMD -c $(($c)) -d $WORK_DIR/xlsfiles/${cname[ind]}/
   $GENERATE_DATA_CMD -c $(($c)) -d $WORK_DIR/xlsfiles/
   
   
   cwd=`pwd`
   cd $XLS_DL_DIR/   
   cp ${cname[ind]}*.xlsx ${cname[ind]}/
   zip -r $XLS_DL_DIR/${cname[ind]}.zip ${cname[ind]}/*   
   cd $cwd $XLS_DL_DIR/${cname[ind]}
   rm -rf 
   ind=$(($ind+1))
   
done
echo "`date` XLSX files created ..."

#Delete running file:
rm $SCRIPT_RUNNING_FILE 2>/dev/null


