#!/bin/bash

#export SERVER=eduabati@10.9.0.2
rm files.tar.gz 2>/dev/null
pushd /home/eduabati/NetBeansProjects/Data2ExcelCli/ && ant && popd
cp -v /home/eduabati/NetBeansProjects/Data2ExcelCli/dist/Data2ExcelCli.jar files/scripts/

pushd /home/eduabati/NetBeansProjects/ParseXMLGeneral/ && ant && popd
cp -v /home/eduabati/NetBeansProjects/ParseXMLGeneral/dist/GetXmlInfo.jar files/scripts/

cp -rfvv /home/eduabati/NetBeansProjects/ParseXMLGeneral/dist/lib files/scripts/

pushd files
tar cvzf files.tar.gz *
mv files.tar.gz ../
popd

#if [ -f /home/eduabati/citrix/NELogCol.exe ]; then
    #dropbox start >/dev/null
	#cp /home/eduabati/citrix/NELogCol.exe /home/eduabati/Dropbox/Public/Scripts	
#fi

rm /home/eduabati/NextCloud/nokia/*

#Copy to nextcloud:
cp files.tar.gz /home/eduabati/NextCloud/nokia
cp update.sh /home/eduabati/NextCloud/nokia
cp install.sh /home/eduabati/NextCloud/nokia

#Copy to dropbox:
cp files.tar.gz  ~/Dropbox/Public/ra_script_new_version/
cp update.sh  ~/Dropbox/Public/ra_script_new_version/
cp install_dropbox.sh  ~/Dropbox/Public/ra_script_new_version/

#scp install.sh $SERVER:/tmp/
#scp files.tar.gz $SERVER:/tmp/
