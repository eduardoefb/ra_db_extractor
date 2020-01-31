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

if [ ! -f files.tar.gz ]; then
	cd /tmp/
	rm -f files.tar.gz 2>/dev/null
	#Download the fil from dropbox
	#wget -O files.tar.gz https://www.dropbox.com/s/oksl891n7xf00dk/files.tar.gz?dl=1
	wget --no-check-certificate -O files.tar.gz https://efb.homelinux.org:9443/nextcloud/index.php/s/bRIz1LUiGmm98o5/download
fi

tmpdir=`mktemp -d`
tar xvf files.tar.gz -C $tmpdir
source $tmpdir/scripts/var.conf

rm -rf $HTML_DIR 2>/dev/null
mkdir -pv $HTML_DIR

rm -rf $WORK_DIR 2>/dev/null
mkdir -pv $WORK_DIR 
if [ `uname -a | grep -iE 'debian|ubuntu' | wc -l` -gt 0 ]; then
   export DEBIAN_FRONTEND=noninteractive
   LISTENING_PORT=8090
   SERVER_CONFIG_FILE="/etc/apache2/sites-available/001-nokia.conf"
   PORTS_CONFIG_FILE="/etc/apache2/ports.conf"
   apt update -y
   apt upgrade -y
   apt install apache2 mariadb-server php5 php5-mysql libapache2-mod-php5 default-jre gnuplot zip unzip python-mysql.connector python-xlsxwriter -y
   apt install apache2 mariadb-server php php-mysql libapache2-mod-php default-jre gnuplot zip unzip python-mysql.connector python-xlsxwriter -y    
   rm $SERVER_CONFIG_FILE 2>/dev/null
   cat > $SERVER_CONFIG_FILE << EOF
<VirtualHost *:$LISTENING_PORT>
	ServerAdmin webmaster@localhost
	DocumentRoot $HTML_DIR
	ErrorLog ${APACHE_LOG_DIR}/error_nokia.log
	CustomLog ${APACHE_LOG_DIR}/access_nokia.log combined
</VirtualHost>
EOF
   if ! grep "Listen $LISTENING_PORT" $PORTS_CONFIG_FILE; then
      echo "Listen $LISTENING_PORT" >> $PORTS_CONFIG_FILE
   fi
   a2ensite 001-nokia.conf    
   service apache2 restart
fi

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

/opt/nokia/nedata/scripts/reinstall_db

clear

#echo -n "Populating datbase..."
#cat $tmpdir/database/backup.sql | mysql -u root -p`cat $ROOT_PW_FILE` nsn
echo "Ok"
popd
rm -rfv $tmpdir   


#crontab:
tmpfle=`mktemp`
crontab -l >> $tmpfle

while grep -nr '/opt/nokia/nedata/scripts/check.sh' $tmpfle; do
   ln=`grep -nr '/opt/nokia/nedata/scripts/check.sh' $tmpfle  | awk -F ':' '{print $1}'`	
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
*/1 * * * * root bash -x $WORK_DIR/scripts/check.sh >> $SCRIPT_DIR/update.log 2>>$SCRIPT_DIR/update.log&
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

#Set: max_execution_time = 3000 on php.ini
change_php_ini "max_execution_time = 3000"

#Restart apache2 after the changes:
service apache2 restart


#Rc.local file:
cat << EOF > /etc/rc.local 
#!/bin/bash
sleep 5
chmod +x $WORK_DIR/scripts/clear_executions.sh
sleep 5
$WORK_DIR/scripts/clear_executions.sh
EOF
chmod +x /etc/rc.local

clear



echo "Installation Completed!"
