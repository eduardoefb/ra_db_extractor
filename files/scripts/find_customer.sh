#!/bin/bash


function usage(){
	echo "Usage:"
	echo "$0 <zip file name>"
	exit
}

if [ -z "$1" ]; then
   usage
fi

source /opt/nokia/nedata/scripts/var.conf
export INPUT_FILE_NAME=$1
export TEMP_DIR=`mktemp -d`
export CUSTOMER_NAME=""


echo -n "`date` Extracting $INPUT_FILE_NAME..."
unzip $INPUT_FILE_NAME -d $TEMP_DIR 2>/dev/null 1>/dev/null
echo "Ok."
pushd $TEMP_DIR 2>/dev/null 1>/dev/null
echo -n "`date` Getting customer from file..."

for fn in `echo $INPUT_FILE_NAME | sed 's/\// /g'`; do
	cat /dev/null
done

CUSTOMER_NAME=`echo $fn | awk -F "-" '{print $1}'`
echo "cname = $CUSTOMER_NAME"
if [ -z "$CUSTOMER_NAME" ]; then
   echo "`date` Error on get customer name"
   exit
fi

if [ -d $NE_LOG_DIR"/"$CUSTOMER_NAME ]; then
	echo "`date` Found --> $CUSTOMER_NAME"
	mv -v -f * $NE_LOG_DIR"/"$CUSTOMER_NAME
	popd 2>/dev/null 1>/dev/null
	rm -rf $TEMP_DIR 2>/dev/null
else
	mv -v -f * $NE_LOG_DIR"/"$CUSTOMER_NAME
	echo "$NE_LOG_DIR"/"$CUSTOMER_NAME doesn't exist!"
fi





