#!/bin/bash
source /opt/nokia/nedata/scripts/var.conf


if [ -f $SCRIPT_RUNNING_FILE ]; then
	exit
fi


for c in `ls $NE_LOG_DIR`; do
	if [ -f $NE_LOG_DIR/$c/.id ]; then
		id=`cat $NE_LOG_DIR/$c/.id`
		
        rm /tmp/status 2>/dev/null
        echo "Creating excel files for $c..." > /tmp/status
        mv /tmp/status $SCRIPT_EXEC_STATUS_FILE

        mkdir -p $SCRIPT_DIR/xlsfiles/$c
        $GENERATE_DATA_CMD -c $id -d $SCRIPT_DIR/xlsfiles/$c/

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
	fi
done
echo "Updated" > $SCRIPT_EXEC_STATUS_FILE

