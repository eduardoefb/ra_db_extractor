#!/bin/bash

#functions:

function f_customer(){
	rm $SCRIPT_DIR/cust_run 2>/dev/null
	echo 1 > $SCRIPT_DIR/cust_run
	$SCRIPT_DIR/find_customer.sh $f >> $SCRIPT_DIR/update.log
	rm $SCRIPT_DIR/cust_run 2>/dev/null

}

function update_log(){
	rm $SCRIPT_DIR/log_run 2>/dev/null
	echo 1 > $SCRIPT_DIR/log_run
	$PARSE_LOG_CMD >> $SCRIPT_DIR/update.log
	rm $SCRIPT_DIR/log_run 2>/dev/null
}

function update_xml(){
    rm $SCRIPT_DIR/xml_run 2>/dev/null
    echo 1 > $SCRIPT_DIR/xml_run
    for f in `find $NE_LOG_DIR"/" -name .id`; do
        id=`cat $f` 
        path=`echo $f | sed 's/\.id//g'`
        echo "Finding XML, DAT, CSV for parsing on $path" >> $SCRIPT_DIR/update.log
        $PARSE_XML_CMD  -i $path*{.xml,.dat,.csv} -c $id >> $SCRIPT_DIR/update.log
    done
    rm $SCRIPT_DIR/xml_run 2>/dev/null
}

function dropbox_stop(){
	su - $DROPBOX_USER << EOF
	dropbox stop 2>/dev/null
EOF
}

function dropbox_start(){
	su - $DROPBOX_USER << EOF
	dropbox start 2>/dev/null
EOF
}


function get_dropbox_link(){
	dropbox_stop
	sleep 30
	dropbox_start
	sleep 10
	su - $DROPBOX_USER > $WORK_DIR/scripts/dropbox_link << EOF
dropbox sharelink ~/Dropbox/Public/RA_Data
EOF
}


#Constants:
source /opt/nokia/nedata/scripts/var.conf
export SCRIPT_RUNNING_FILE_INDICATION=$TMP_LOG_UPLOAD_DIR"/run"


#Variables:
unset customer
unset cust_changed


#Check if the file $SCRIPT_RUNNING_FILE_INDICATION exists, if yes, start script. If no: stop
if [ ! -f $SCRIPT_RUNNING_FILE_INDICATION ]; then
   exit
fi

#Remove the current_database directories:
for dire in $(find $WORK_DIR/logs -name *-current_database); do
	rm -rfv $dire
done


rm $SCRIPT_RUNNING_FILE_INDICATION
#Copy the files, if exists

for f in `ls $TMP_LOG_UPLOAD_DIR/*.zip 2>/dev/null`; do
   f_customer $f &   
    sleep 10
    while [ -f $SCRIPT_DIR/cust_run ]; do            
        lin=`tail -1 $SCRIPT_DIR/update.log` # > /tmp/status        
        lin1=`echo Processing: $f`            
        rm /tmp/status 2>/dev/null
        echo $lin1 > /tmp/status
        mv /tmp/status $SCRIPT_EXEC_STATUS_FILE        
        sleep 5
    done   
	rm $f 2>/dev/null
done

#Find the directories where customer logs are located:
changes=0
for fle in `find $NE_LOG_DIR"/" -name .id`; do
    cid=`cat $fle`
    cid=$(($cid-1))
    cname=`echo $fle | awk -F '/' '{print $6}'`
    customer[cid]=$cname
    cust_changed[cid]=0
    cust_changed[cid]=`ls -l $NE_LOG_DIR"/"$cname"/" | grep -v "\.old" | grep -v "\-current" | grep -v total | wc -l`
    changes=$(($changes+${cust_changed[cid]}))
done

#If there is no changes, abort script:
if [ $changes -eq 0 ]; then
   exit
fi

#If there are changes, continue the script:

#Update dropbox shared link:
get_dropbox_link

#Stop dropbox:
dropbox_stop

#Start script, if $SCRIPT_RUNNING_FILE doesn't exist
if [ ! -f $SCRIPT_RUNNING_FILE ]; then
	echo "1" > $SCRIPT_RUNNING_FILE

   #Remove tmp files:
   rm $SCRIPT_DIR/update.log 2>/dev/null
   cat /dev/null >> $SCRIPT_DIR/update.log
   
   #remove #current_database files:
   #find /opt/nokia/nedata/logs/ -name *-current_database -exec rm -rf {}; 2>/dev/null
   
   echo "Updating state information files..." > $SCRIPT_EXEC_STATUS_FILE
	$SCRIPT_DIR/chk_state.sh > $SCRIPT_DIR/update.log

    #Remove old files:
    for fle in `find $NE_LOG_DIR"/" -name .id`; do
        cid=`cat $fle`
        cid=$(($cid-1))
        cname=`echo $fle | awk -F '/' '{print $7}'`
    	rm -rfv $NE_LOG_DIR"/"$cname"/*-old" >> $SCRIPT_DIR/update.log
    done

    #This php script will get the data from log files:
    update_log&
    sleep 10
    while [ -f $SCRIPT_DIR/log_run ]; do            
        lin=`tail -1 $SCRIPT_DIR/update.log` # > /tmp/status
        if [ `echo $lin | grep -i "(" | wc -l` -gt 0 ]; then
            lin1=`echo Updating: $lin`            
            rm /tmp/status 2>/dev/null
            echo $lin1 > /tmp/status
            mv /tmp/status $SCRIPT_EXEC_STATUS_FILE
        fi
        sleep 5
    done
	

    #This function will call the java xml parser to get the data from xml files:
    update_xml&
    sleep 10
    while [ -f $SCRIPT_DIR/xml_run ]; do            
        lin=`tail -1 $SCRIPT_DIR/update.log` # > /tmp/status
        if [ `echo $lin | grep -i $NE_LOG_DIR"/" | wc -l` -gt 0 ]; then
            lin1=`echo Updating: $lin | sed 's/$NE_LOG_DIR//g'`            
            rm /tmp/status 2>/dev/null
            echo $lin1 > /tmp/status
            mv /tmp/status $SCRIPT_EXEC_STATUS_FILE
        fi
        sleep 5
    done

    if [ `cat $SCRIPT_DIR/update.log | wc -l` -eq 0 ]; then
        for file_ext in csv dat xml; do
            if [ `find $NE_LOG_DIR"/" -name *.$file_ext | wc -l` -gt 0 ]; then
                echo "Found $file_ext files to parse" >> $SCRIPT_DIR/update.log
            fi
        done
    fi

    if [ `cat $SCRIPT_DIR/update.log | wc -l` -gt 0 ]; then
        rm -rf $SCRIPT_DIR/xlsfiles 2>/dev/null
        mkdir -p $SCRIPT_DIR/xlsfiles
        cid=0
        rm -rf $SCRIPT_DIR/xlsfiles/ 2>/dev/null
        $SCRIPT_DIR/creategraph.sh 2>/dev/null
        for c in ${customer[*]}; do 
            if [ ${cust_changed[cid]} -gt 0 ]; then  
                rm /tmp/status 2>/dev/null
                echo "Creating excel files for $c..." > /tmp/status
                mv /tmp/status $SCRIPT_EXEC_STATUS_FILE

                mkdir -p $SCRIPT_DIR/xlsfiles/$c
                $GENERATE_DATA_CMD -c $(($cid+1)) -d $SCRIPT_DIR/xlsfiles/$c/ >> $SCRIPT_DIR/update.log 2 >> $SCRIPT_DIR/update.log

                #Copy files to history directory:
                mkdir -p $SCRIPT_DIR/xls_history/$c/
                cp -r $SCRIPT_DIR/xlsfiles/$c/* $SCRIPT_DIR/xls_history/$c/
                
                #Copy files to dropbox shared directory:
                cp -r $SCRIPT_DIR/xlsfiles/$c/ /home/$DROPBOX_USER/Dropbox/Public/RA_Data/

                #Copy files to the XLS_DL_DIR/
                mkdir -p $XLS_DL_DIR 2>/dev/null
                rm -rf $XLS_DL_DIR/$c.zip 2>/dev/null
                pushd $SCRIPT_DIR/xlsfiles/
                zip -r $XLS_DL_DIR/$c.zip $c/*
                popd
                chown -R apache.apache $XLS_DL_DIR"/" 2>/dev/null 
                sleep 5
            fi
            cid=$(($cid+1))            
        done    
   fi
   sleep 10
   rm $SCRIPT_RUNNING_FILE   
   echo "Updated" > $SCRIPT_EXEC_STATUS_FILE

   #Copy files from XLS_DL_DIR
   #Start Dropbox:
   dropbox_start
	
fi

