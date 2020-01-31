#!/bin/bash
source /opt/nokia/nedata/scripts/var.conf
fname="$WORK_DIR/database_backup/`date  +'%Y%m%d%H%m%S'`.sql"
mysqldump -u root -p`cat $ROOT_PW_FILE` nsn > $fname
echo "Backup created:"
echo "Filename: $fname"
if [ -f $fname ]; then
	echo "To recovery the database using this backup, try:"
	echo "cat $fname | mysql -u apache -p\`cat $APACHE_PW_FILE\` nsn"
else
	echo "Backup creation has failed!"
fi




