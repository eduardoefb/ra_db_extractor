#!/bin/sh

get_zqni(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZQNI.log"
   CMD="ZQNI;"
   echo "BSC" > "$2/$3/ELEMENT_TYPE"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zqli(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZQLI.log"
   CMD="ZQLI;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}


get_zqri(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZQRIOMU.log"
   CMD="ZQRI:OMU;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}


get_zeei(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZEEI.log"
   if [ ` exemmlmx -n $3 -c "ZWOS:2,665;" | grep ACTIVATED | wc -l` -gt 0 ]; then
      CMD="ZEEI:SEG=ALL;"
   else
      CMD="ZEEI;"
   fi

   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zero(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   ZEEI_LOG_NAME="$2/$3/ZEEI.log"
   LOG_NAME="$2/$3/ZERO.log"
   max_bts=30
   for bts_id in `grep "BTS-" $ZEEI_LOG_NAME | awk '{print $1}' | sed 's/BTS-//' `; do 
      if [ $bts_id -gt $max_bts ]; then
         max_bts=$bts_id
      fi
   done
   if [ $max_bts -gt 3000 ]; then
      max_bts=3000
   fi
   CMD="ZERO:BCF=1&&$max_bts;"

   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}


get_zewo(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   ZEEI_LOG_NAME="$2/$3/ZEEI.log"
   LOG_NAME="$2/$3/ZEWO.log"
   max_bts=30
   for bts_id in `grep "BTS-" $ZEEI_LOG_NAME | awk '{print $1}' | sed 's/BTS-//' `; do 
      if [ $bts_id -gt $max_bts ]; then
         max_bts=$bts_id
      fi
   done
   if [ $max_bts -gt 3000 ]; then
      max_bts=3000
   fi
   CMD="ZEWO:1&&$max_bts;"

   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}


get_zeeibcsu(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZEEIBCSU.log"
   CMD="ZEEI::BCSU;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_ztpi(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZTPI.log"
   CMD="ZTPI;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_prfile(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/PRFILEGX_VER.log"
   CMD="ZWQV:OMU:PRFILEGX;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_fifile(){

   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/FIFILEGX_VER.log"
   CMD="ZWQV:OMU:FIFILEGX;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zusi(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZUSI.log"
   CMD="ZUSI;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_tcsm(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   ZUSI_LOG_NAME="$2/$3/ZUSI.log"
   LOG_NAME="$2/$3/TCSM.log"
   if [ `grep "TCSM-" $ZUSI_LOG_NAME | wc -l` -eq 0 ]; then return 0; fi 
   CMD="ZWTI:PI:TCSM;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zwqo(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZWQO.log"
   CMD="ZWQO:CR;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zwoi(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZWOI.log"
   CMD="ZWOI;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}


get_zwos(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZWOS.log"
   CMD="ZWOS;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zw7i(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZW7IFULL.log"
   CMD="ZW7I:FEA,FULL:FSTATE=ON;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}

get_zw7iucap(){
   if [ `grep "FAILED" $CTRL_FILE | wc -c` -gt 0 ]; then return 0; fi
   CTRL_FILE=$1
   LOG_NAME="$2/$3/ZW7IUCAP.log"
   CMD="ZW7I:UCAP;"
   mkdir -p $2/$3
   rm $LOG_NAME 2>/dev/null 1>/dev/null
   exemmlmx -n $3 -c "$CMD" > $LOG_NAME
   if [ `grep "COMMAND EXECUTED" $LOG_NAME | wc -c` -eq 0 ]; then
      sed -i 's/RUNNING/FAILED/' $CTRL_FILE
      return 0
   fi
}



finish(){
   if [ `grep "FAILED" $1 | wc -c` -gt 0 ]; then return 0; fi
   sed -i 's/RUNNING/OK/' $1
   #echo "`date` $2 Finished!"
}

run_bsc(){
   get_zqni $1 $2 $3
   get_zqli $1 $2 $3
   get_zqri $1 $2 $3
   get_zeei $1 $2 $3
   get_zero $1 $2 $3
   get_zewo $1 $2 $3
   get_zeeibcsu $1 $2 $3
   get_ztpi $1 $2 $3
   get_prfile $1 $2 $3
   get_fifile $1 $2 $3
   get_zusi $1 $2 $3
   get_tcsm $1 $2 $3
   get_zwqo $1 $2 $3
   get_zwoi $1 $2 $3
   get_zwos $1 $2 $3
   get_zw7i $1 $2 $3
   get_zw7iucap $1 $2 $3

   finish $1 $3
}


process_bsc(){
   rm .run 2>/dev/null 1>/dev/null
   echo "1" > .run
   for bsc in `ls $CTRL_DIR`; do
      if [ -f .run ]; then
         sed -i 's/0/RUNNING/' $CTRL_DIR/$bsc
         #echo "`date` Starting $bsc..."
         run_bsc $CTRL_DIR/$bsc $LOG_DIR $bsc &
         sleep 10
      fi
   done
}

check_result(){
   while [ `grep -E 'RUNNING|0'  $CTRL_DIR/* | wc -c` -gt 0 ]; do
      clear
      echo "*******Brief Status (Maximum 10 RUNNING, 10 PENDING, 10 FAILED***********"
      grep "RUNNING" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:/->/;s/RUNNING/*RUNNING*/" | head -10
      grep "0$" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/0$/PENDING/;s/:/->/" | head -10
      grep "FAILED" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:/->/;" | head -10
      echo "*************************************************************************"
      echo "Total:"
      echo "OK:       `grep "OK" $CTRL_DIR/* | wc -l`"
      echo "RUNNING:  `grep "RUNNING" $CTRL_DIR/* | wc -l`"
      echo "PENDING:  `grep "0$" $CTRL_DIR/* | wc -l`"
      echo "FAILED:   `grep "FAILED" $CTRL_DIR/* | wc -l`"
      echo "TOTAL:    `cat $CTRL_DIR/* | wc -l`"
      echo "*************************************************************************"
      sleep 5
   done

   for bsc in `grep "FAILED" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:FAILED//"`; do
      rm -rf $LOG_DIR/$bsc
   done
}

zip_dir(){
   
   ZIP_FILE=`uname -n`"_log.zip"
   echo -n "Creating $ZIP_FILE..."
   cd $LOG_DIR
   zip -r ../$ZIP_FILE * 2>/dev/null 1>/dev/null
   cd ..
   if [ -f $ZIP_FILE ]; then
      echo "Ok!"
   else
      echo "Error! Check Manually"
   fi
}

export CTRL_DIR=".bsc_ctrl"
export LOG_DIR="bsclog"

#Create the control directory
rm -rf $CTRL_DIR 2>/dev/null 1>/dev/null
rm -rf $LOG_DIR 2>/dev/null 1>/dev/null
mkdir -p $CTRL_DIR
mkdir -p $LOG_DIR

for bsc in `grep BSC /etc/opt/nokia/oss/diagspf/conf/diagnospf_elements.cf | awk '{print $2}' | sed 's/<//g' | sed 's/>//g'`; do
   echo "0" > $CTRL_DIR/$bsc
done 


#Infinite loop, finished when there is no error, or user cancel
while :; do
   process_bsc &
   check_result
   if [ `grep "FAILED" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:FAILED//" | wc -l` -gt 0 ]; then
      opt="asdf"
      while [ "$opt" != "Y" -a "$opt" != "N" ]; do
         clear
         echo "There are some failed bscs. Try again on those?(Y/N)"
         grep "FAILED" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:FAILED//"
         read opt
      done

      if [ "$opt" == "Y" ]; then
         unset bsclst
         bsclst_cnt=0
         for bsc in `grep "FAILED" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:FAILED//"`; do
            bsclst[bsclst_cnt]=$bsc
            bsclst_cnt=$(($bsclst_cnt+1))
         done
         bsclst_cnt=$(($bsclst_cnt-1))
         rm $CTRL_DIR/*
         for i in `seq 0 $bsclst_cnt`; do
            echo "0" > $CTRL_DIR/${bsclst[i]}
         done
      else
         zip_dir
         echo "Failed BSCs:"
         grep "FAILED" $CTRL_DIR/* | sed "s/$CTRL_DIR\///;s/:FAILED//"
         exit
      fi
   else
      zip_dir
      echo "Script completed. No errors found!"
      exit
   fi
done


