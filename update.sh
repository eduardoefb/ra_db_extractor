#!/bin/bash

function change_php_ini(){
   php_ini_file=`find /etc/  -name php.ini | grep apache`
   req=$1
   par=`echo $req | awk '{print $1}'`
   if ! grep -w "$req" $php_ini_file >/dev/null; then
      l=`grep -w $par $php_ini_file`
      sed -i "s/$l/$req/g" $php_ini_file
   fi
}

function check_internet_connection(){
	echo -n "Checking your internet connection..."
	if ! ping -c 1 8.8.8.8  2>/dev/null 1>/dev/null; then
		echo "NOK! Check it and try again!"
		exit
	fi
	echo "Ok"
	echo -n "Checking your dns server(s)..."
	if ! ping -c 1 www.dropbox.com 2>/dev/null 1>/dev/null; then
		echo "NOK! Check it and try again!"
		exit
	fi
	echo "Ok"	
}

if [ "$USER" != "root" ]; then
   echo "You must be root!!!"
   exit
fi

check_internet_connection
cd /tmp/
rm files.tar.gz 2>/dev/null
#Download the fil from dropbox
wget -O files.tar.gz https://www.dropbox.com/s/oksl891n7xf00dk/files.tar.gz?dl=1


tmpdir=`mktemp -d`
tar xvf files.tar.gz -C $tmpdir
source $tmpdir/scripts/var.conf

#Create the directories:
mkdir -pv $HTML_DIR/{ne,mysql_functions}
mkdir -pv $WORK_DIR/{logs,scripts,users,log_tmp,conf,xlsfiles,database_backup}
mkdir -pv $WORK_DIR/scripts/xls_history
pushd $tmpdir/html
cp -rfv * $HTML_DIR
pushd $tmpdir/scripts
cp -rfv * $WORK_DIR/scripts
pushd $tmpdir/conf
cp -rfv * $WORK_DIR/conf
chown -Rv $LINUX_APACHE_USER:$LINUX_APACHE_GROUP $WORK_DIR
chown -Rv $LINUX_APACHE_USER:$LINUX_APACHE_GROUP $HTML_DIR

/opt/nokia/nedata/scripts/manager_customer add OI
/opt/nokia/nedata/scripts/manager_customer add TIM
/opt/nokia/nedata/scripts/manager_customer add CLARO
/opt/nokia/nedata/scripts/manager_customer add ALGAR
clear
echo "Ok"
popd
rm -rfv $tmpdir   


#crontab:
tmpfle=`mktemp`
crontab -l >> $tmpfle

while grep -nr '/opt/nokia/nedata/scripts/update.sh' $tmpfle; do
   ln=`grep -nr '/opt/nokia/nedata/scripts/update.sh' $tmpfle  | awk -F ':' '{print $1}'`	
   sed -i "$ln"'d' $tmpfle
done

while grep -nr '#Update database every 5 minutes:' $tmpfle; do
   ln=`grep -nr '#Update database every 5 minutes:' $tmpfle  | awk -F ':' '{print $1}'`	
   sed -i "$ln"'d' $tmpfle
done
crontab $tmpfle

rm /etc/cron.d/nokia 2>/dev/null

cat > /etc/cron.d/nokia << EOF
#Update database every minute:"
*/1 * * * * root $WORK_DIR/scripts/update.sh 2>/dev/null 1>/dev/null&
EOF

rm $tmpfle 2>/dev/null


#Set: file_uploads = On  on php.ini
change_php_ini "file_uploads = On"

#Set: upload_max_filesize = 1000M on php.ini
change_php_ini "upload_max_filesize = 1000M"

#Set: max_file_uploads = 20 on php.ini
change_php_ini "max_file_uploads = 20"

#Set: post_max_size = 1000M on php.ini
change_php_ini "post_max_size = 1000M"


#Correct mysql tables:
mysql -u root -p`cat /opt/nokia/nedata/users/.root` nsn 1>/dev/null 2>/dev/null << EOF
	ALTER TABLE rnc ALTER COLUMN oms_ip SET DEFAULT "-";
	ALTER TABLE rnc ADD COLUMN oms_ip_sec VARCHAR(20) DEFAULT "-";
EOF


echo "Installation Completed!"

#cat << EOF
#Important:
#Check your php.ini file and change the values to allow file upload (use: updatedb && locate php.ini to find:
#file_uploads = On
#upload_max_filesize = 1000M
#max_file_uploads = 20
#post_max_size = 1000M
#EOF
