#!/bin/bash


function conf_dir(){
   CWD=$NE_LOG_DIR
   cd $CWD
   cd $1
   for d in `ls -l | sed 's/ /#/g' | grep ^d`; do
      dire=`echo $d | sed 's/#/ /g' | awk '{print $9}'`
      echo "$dire..."
      if [ ! -f "$dire/STATE" ]; then
         echo -n "STATE file missing on $dire "
         for lin in `cat $CF_FILES_DIR/$2`; do
            name=`echo $lin | awk -F "-" '{print $1}'`
            if [ `echo $dire | grep $name | wc -c` -gt 0 ]; then
               state=`echo $lin | awk -F "-" '{print $2}'`
               loc=`echo $lin | awk -F "-" '{print $3}'`
               echo $state > "$dire/STATE"
               echo -n "$dire New state=$state "
               if [ `cat "$dire/ELEMENT_TYPE" | grep "RNC" | wc -l` -gt 0 ]; then
                  echo $loc > "$dire/RNC_LOC"
                  echo -n "$dire new location=$loc"
               fi
               break;
            fi
         done
         echo " "
      fi
   done
   cd $CWD

}

source /opt/nokia/nedata/scripts/var.conf

for c in `ls $NE_LOG_DIR`; do
   if [ -f $NE_LOG_DIR/$c/.id ]; then
      conf_dir $c $c"_location.conf"
   fi
done

