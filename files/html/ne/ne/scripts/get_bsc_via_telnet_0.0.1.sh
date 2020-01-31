#!/bin/bash

function chkauth(){
   timeout=20
   t=0
   while :; do
      sleep 1
      if [ `cat $1 | grep "WELCOME TO" | wc -c` -gt 0 ]; then
         return 0
      fi
      if [ `cat $1 | grep "USER AUTHORIZATION FAILURE" | wc -c` -gt 0 ]; then
         return 0
      fi

      if [ `cat $1 | grep "NO FREE" | wc -c` -gt 0 ]; then
         return 0
      fi
      t=$(($t+1))
      if [ $t -gt $timeout ]; then
         echo "USER AUTHORIZATION FAILURE" >> $1
         return 0
      fi
   done
}


function chkcmd(){

   timeout=600
   t=0
   while :; do
      sleep 4
      #Normal MML Command
      if [ `tail -1 $1 | grep "^<" | wc -c` -gt 0 ]; then return 0; fi

      #Service terminal main
#      if [ `tail -1 $1 | grep "\-MAN>" | wc -c` -gt 0 ]; then return 0; fi

      #Service terminal log
#      if [ `tail -1 $1 | grep "\-LOG>" | wc -c` -gt 0 ]; then return 0; fi

      #Service terminal rem
#      if [ `tail -1 $1 | grep "\-REM>" | wc -c` -gt 0 ]; then return 0; fi

      #Service terminal rcb
#      if [ `tail -1 $1 | grep "\-RCB-" | wc -c` -gt 0 ]; then return 0; fi

      #Service terminal PCU2
#      if [ `tail -1 $1 | grep "OSE>" | wc -c` -gt 0 ]; then return 0; fi


      #Service terminal PCU1
#      if [ `tail -1 $1 | grep "\-$" | wc -c` -gt 0 ]; then return 0; fi
      t=$(($t+1))
      if [ $t -gt $timeout ]; then
         return 0
      fi

   done
}


function SendCMD(){
   log_file="."$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
   i=0
   unset cmdlist
   cmdcnt=0
   for cmd in `echo $@`; do
      i=$(($i+1))
      if [ $i -eq 1 ]; then
         ip=$cmd
      elif [ $i -eq 2 ]; then
         u=$cmd
      elif [ $i -eq 3 ]; then
         p=$cmd
      else
         cmdlist[cmdcnt]=$cmd
         cmdcnt=$(($cmdcnt+1))
      fi
   done

   cmdcnt=$(($cmdcnt-1))

   (
      echo -e "$u\n$p\n\r" && chkauth $log_file

      if [ `grep "USER AUTHORIZATION FAILURE" $log_file | wc -c` -gt 0 ]; then
         break;
      fi

      for i in `seq 0 $cmdcnt`; do
         if [ `echo ${cmdlist[i]} | grep ^Z | wc -c` -gt 0 ]; then
            echo -e "Z${cmdlist[i]}\n\r" && chkcmd $log_file
         else
            echo -e "${cmdlist[i]}\n\r" && chkcmd $log_file
         fi
      done

   ) | telnet $ip > $log_file 2>/dev/null

   cat $log_file
   rm $log_file* 2>/dev/null

   
}



function get_omu_ip() { 
   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZQRI:OMU;"
   logfile="bsclog/$n/ZQRIOMU.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
   

}


get_zwti(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWTI:PI;"
   logfile="bsclog/$n/ZWTI.log"
   rm $logfile 2>/dev/null
   echo "BSC" > "bsclog/$n/ELEMENT_TYPE"
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}

get_zqni(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZQNI;"
   logfile="bsclog/$n/ZQNI.log"
   rm $logfile 2>/dev/null
   echo "BSC" > "bsclog/$n/ELEMENT_TYPE"
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}



get_zqli(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZQLI;"
   logfile="bsclog/$n/ZQLI.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}


get_zqri(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZQRI:OMU;"
   logfile="bsclog/$n/ZQRIOMU.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}


get_zeei(){

   i=$1
   u=$2
   p=$3
   n=$4

   if [ `SendCMD  $i $u $p "ZWOS:2,665;" | grep ACTIVATED | wc -l` -gt 0 ]; then
      cmd="ZEEI:SEG=ALL;"
   else
      cmd="ZEEI;"
   fi

   logfile="bsclog/$n/ZEEI.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}

get_zero(){

   i=$1
   u=$2
   p=$3
   n=$4


   ZEEI_LOG_NAME="bsclog/$n/ZEEI.log"

   max_bts=30
   for bts_id in `grep "BTS-" $ZEEI_LOG_NAME | awk '{print $1}' | sed 's/BTS-//' `; do 
      if [ $bts_id -gt $max_bts ]; then
         max_bts=$bts_id
      fi
   done
   if [ $max_bts -gt 3000 ]; then
      max_bts=3000
   fi
   cmd="ZERO:BCF=1&&$max_bts;"



   logfile="bsclog/$n/ZERO.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}


get_zewo(){

   i=$1
   u=$2
   p=$3
   n=$4

   ZEEI_LOG_NAME="bsclog/$n/ZEEI.log"

   max_bts=30
   for bts_id in `grep "BTS-" $ZEEI_LOG_NAME | awk '{print $1}' | sed 's/BTS-//' `; do 
      if [ $bts_id -gt $max_bts ]; then
         max_bts=$bts_id
      fi
   done
   if [ $max_bts -gt 3000 ]; then
      max_bts=3000
   fi
   cmd="ZEWO:1&&$max_bts;"



   logfile="bsclog/$n/ZEWO.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}

get_zeeibcsu(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZEEI::BCSU;"
   logfile="bsclog/$n/ZEEIBCSU.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}


get_ztpi(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZTPI;"
   logfile="bsclog/$n/ZTPI.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}



get_prfile(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWQV:OMU:PRFILEGX;"
   logfile="bsclog/$n/PRFILEGX_VER.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi

}

get_fifile(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWQV:OMU:FIFILEGX;"
   logfile="bsclog/$n/FIFILEGX_VER.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


get_zusi(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZUSI;"
   logfile="bsclog/$n/ZUSI.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


get_tcsm(){

   i=$1
   u=$2
   p=$3
   n=$4


   zusilogfile="bsclog/$n/ZUSI.log"

   if [ `grep "TCSM-" $zusilogfile | wc -l` -eq 0 ]; then return 0; fi
   cmd="ZUSI:TCSM;"
   logfile="bsclog/$n/TCSM.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


get_zwqo(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWQO:CR;"
   logfile="bsclog/$n/ZWQO.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}



get_zwoi(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWOI;"
   logfile="bsclog/$n/ZWOI.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


get_zwos(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWOS;"
   logfile="bsclog/$n/ZWOS.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


get_zw7i(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZW7I:FEA,FULL:FSTATE=ON;"
   logfile="bsclog/$n/ZW7IFULL.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


get_zw7iucap(){

   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZW7I:UCAP;"
   logfile="bsclog/$n/ZW7IUCAP.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}











function start_bsc(){
   echo $4 > bsclog/$4/BSC_NAME
   echo $1 > bsclog/$4/BSC_IP
   echo "BSC" > bsclog/$4/BSC_TYPE
   echo "BSC" >  bsclog/$4/ELEMENT_TYPE
   sleep 10


   get_zqni $1 $2 $3 $4
   get_zqli $1 $2 $3 $4
   get_zqri $1 $2 $3 $4
   get_zeei $1 $2 $3 $4
   get_zero $1 $2 $3 $4
   get_zewo $1 $2 $3 $4
   get_zeeibcsu $1 $2 $3 $4
   get_ztpi $1 $2 $3 $4
   get_prfile $1 $2 $3 $4
   get_fifile $1 $2 $3 $4
   get_zusi $1 $2 $3 $4
   get_tcsm $1 $2 $3 $4
   get_zwqo $1 $2 $3 $4
   get_zwoi $1 $2 $3 $4
   get_zwos $1 $2 $3 $4
   get_zw7i $1 $2 $3 $4
   get_zwti $1 $2 $3 $4
   get_zw7iucap $1 $2 $3 $4


   sed -i "s/$4 RUNNING/$4 OK/g" status
   sleep 5
}

function update_ip(){
   #rm .ip 2>/dev/null
   if [ ! -f .ip ]; then
      cat /dev/null > .ip
   fi
   echo "Updating IP list..."
   total_bsc=`grep BSC /etc/opt/nokia/oss/diagspf/conf/diagnospf_elements.cf | wc -l`
   nbr=0
   for bsc in `grep BSC /etc/opt/nokia/oss/diagspf/conf/diagnospf_elements.cf | awk '{print $2}' | sed 's/<//g' | sed 's/>//g'`; do
      nbr=$(($nbr+1))
      echo -n "($nbr of $total_bsc) - $bsc "

      ip=""
      for ip in `exemmlmx -n $bsc -c "ZQRS:OMU:::SYM=YES;" -s 2>/dev/null | grep ESTAB | grep telnet | awk '{print $4}' | sed 's/\.telnet//g'`; do
         break;
      done
      if [ -z "$ip" ]; then
         for ip in `exemmlmx -n $bsc -c "ZQRI:OMU:EL0;" -s  2>/dev/null | grep -v "(" | grep " L " | sed 's/\// /g' | awk '{print $2}'`; do
            break;
         done
      fi

      if [ `echo $ip | wc -c ` -ge 3 ]; then
         igual=0
         for ll in `cat .ip`; do
            if [ "$ll" == "$ip" ]; then
               igual=1
            fi
         done

         if [ $igual -eq 0 ]; then
            
            echo $ip >> .ip
            echo "$ip, added."
         else
            echo "$ip, not changed! Already exists."
         fi

   #      if [ `grep $ip .ip | wc -c` -eq 0 ]; then
   #         echo $ip >> .ip
   #         echo "$ip, added."
   #      else
   #         echo "$ip, Not changed! Already exists."
   #      fi
      fi

      ip=`exemmlmx -n $bsc -c "ZQRI:OMU:EL0;" | grep " L " | grep -v "(" | awk '{print $2}' | awk  -F "/" '{print $1}'`
   done 

}



if [ ! -f .aausw 2> /dev/null ]; then
   echo ".aausw file not found!  To create (example: USER=SYSTEM):"
   echo "echo \"SYSTEM\" > .aausw"
   exit
fi

if [ ! -f .aapwd 2> /dev/null ]; then
   echo ".apwd file not found!  To create (example: PASSWORD=SYSTEM):"
   echo "echo \"SYSTEM\" > .aapwd"
   exit
fi

chmod 744 .aausw
chmod 744 .aapwd

user=`cat .aausw`
pass=`cat .aapwd`

chmod 000 .aausw
chmod 000 .aapwd


for i in `seq 0 9`; do
   rm .$i* 2>/dev/null 1>/dev/null
done

#SendCMD "10.222.165.42" $user $pass "ZDDS;" "ZRS:31,50BE" "dpcutbf" "exit" "ZE;"

rm status 2>/dev/null
cat /dev/null > status
rm -rf bsclog 2>/dev/null
clear
echo "Script started!"
if [ "$1" == "-updateip" ]; then
   update_ip
fi

for ip in `cat .ip`; do

   #Test Ping:

   if [ `ping -c 1 $ip | grep " 0% packet loss" | wc -l` -gt 0 ]; then
   #Test user and password:
      if [ `SendCMD $ip $user $pass "?" | grep "USER AUTHORIZATION FAILURE" | wc -c` -gt 0 ]; then
         echo "$ip User/Password failure!" >> status
         
      else

         abscname=`SendCMD $ip $user $pass " " | grep -E '\-.*\:' | awk '{print $2}' | sed 's/ //g'`
      
         while [ `echo $abscname | wc -c` -gt 15 ]; do
            abscname=`echo $abscname | sed 's/^.//g'`
         done

         abscname=`echo $abscname | sed 's/\.//g'`


         if [ `echo $abscname | sed 's/ //g' | wc -c` -gt 2 ]; then
            echo "$abscname RUNNING" >> status
            
            #OMU IP
            mkdir -p bsclog/$abscname
            echo "Starting $abscname..."
            start_bsc  $ip $user $pass $abscname & 
            sleep 3 
         else
            echo "$abscname $ip Failed"
            echo "$abscname $ip Failed" >> status
         fi
      fi
   else
      echo "$ip Failed"
      echo "$ip Failed" >> status

   fi
done
sleep 10
while [ `grep "RUNNING" status | wc -c` -gt 0 ]; do
   clear
   cat status
   sleep 10
done

for bsc in `grep FAILED status | awk '{print $1}'`; do
   rm -rf bsclog/$bsc 2>/dev/null
done

netact_name=`uname -n`
cd bsclog
rm *.zip 2>/dev/null
echo -n "Creating "$netact_name"_bsc.zip..."
zip -r $netact_name"_bsc.zip" * 2>/dev/null 1>/dev/null
if [ -f $netact_name"_bsc.zip" ]; then
   echo "Ok!"
   mv $netact_name"_bsc.zip" ..
else
   echo "Failed!"
fi

cd ..

