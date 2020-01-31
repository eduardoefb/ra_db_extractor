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
      t=$(($t+1))
      if [ $t -gt $timeout ]; then
         echo "USER AUTHORIZATION FAILURE" >> $1
         return 0
      fi
   done
}


function chkcmd(){
   timeout=20
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
         echo "USER AUTHORIZATION FAILURE" >> $1
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
   logfile="rnclog/$n/ZQRIOMU.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
   

}

function get_zw7i() { 
   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZW7I:FEA,FULL:FSTATE=ON;"
   logfile="rnclog/$n/ZW7IFULL.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
   

}

function get_wbts_main() { 
   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1SA\";"
   logfile="rnclog/$n/WBTS_MAIN.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}

function get_wbts_ip() { 
   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1SC\";"
   logfile="rnclog/$n/WBTS_IP.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


function get_target_id() { 
   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZDDE::\"ZL:1\",\"ZLE:1,MRSTREGX\",\"Z1I\";"
   logfile="rnclog/$n/TARGET_ID.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}

function get_zwqo() { 
   i=$1
   u=$2
   p=$3
   n=$4

   cmd="ZWQO:CR;"
   logfile="rnclog/$n/ZWQOCR.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}

function get_rncid() { 
   i=$1
   u=$2
   p=$3
   n=$4

   wo_omu=`SendCMD  $i $u $p "ZUSI:OMU;" | grep "WO-EX" | awk '{print $1}' | sed 's/-/,/g'`
   
   cmd="ZDFD:$wo_omu:9F20001,0;"
   logfile="rnclog/$n/F_9F020001.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -gt 0 ]; then
      rnc_id_l=`grep "\.$n\." $logfile | awk '{print $1}'`
      rnc_id_u=`grep "\.$n\." $logfile | awk '{print $2}'`

      rnc_id_l_d=`echo "ibase=16; $rnc_id_l" | bc`
      rnc_id_u_d=`echo "ibase=16; $rnc_id_u" | bc`
      rnc_id_u_d=$(($rnc_id_u_d*256))
      rnc_id=$(($rnc_id_l_d+$rnc_id_u_d));
      echo $rnc_id > "rnclog/$n/RNC_ID"
   else
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}

function get_wbts_par() { 
   i=$1
   u=$2
   p=$3
   n=$4

   wo_omu=`SendCMD  $i $u $p "ZUSI:OMU;" | grep "WO-EX" | awk '{print $1}' | sed 's/-/,/g'`
   
   cmd="ZDFD:$wo_omu:9F20002,,N;"
   logfile="rnclog/$n/F_9F020002.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}

function get_wcell_par() { 
   i=$1
   u=$2
   p=$3
   n=$4

   wo_omu=`SendCMD  $i $u $p "ZUSI:OMU;" | grep "WO-EX" | awk '{print $1}' | sed 's/-/,/g'`
   
   cmd="ZDFD:$wo_omu:9F20003,,N;"
   logfile="rnclog/$n/F_9F020003.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}


function get_zusi() { 
   i=$1
   u=$2
   p=$3
   n=$4
   
   cmd="ZUSI;"
   logfile="rnclog/$n/ZUSI.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
      sed -i "s/$n RUNNING/$n FAILED/g" status
   fi
}



function get_oms_ip() { 
   MAX_LINES=100
   i=$1
   u=$2
   p=$3
   n=$4
   cmd="ZIRO:TYPE=NET:DATE=2001-1-1;"
   logfile="rnclog/$n/ZIRO.log"
   rm $logfile 2>/dev/null
   SendCMD  $i $u $p $cmd > $logfile
#   if [ `grep "COMMAND EXECUTED" $logfile | wc -c` -eq 0 ]; then
#      sed -i "s/$n RUNNING/$n FAILED/g" status
#      cat /dev/null
#   else
      max_ips=400
      unset v_ips
      unset v_ipc
      ipt=0
      
      for i in `seq 1 $max_ips`; do
         v_ipc[i]=0
      done

#      for l in `cat $logfile | grep -A 1 " FTP " | sed 's/ /#/g'`; do
      for l in `tail -$MAX_LINES $logfile | grep -A 1 "FTP " | sed 's/ /#/g'`; do
         lb=`echo $l | sed 's/#/ /g'`
         if [ `echo $lb | grep "\." | wc -c` -gt 0 ]; then
            if [ $ipt -eq 0 ]; then
               v_ips[0]=$lb
               v_ipc[0]=1
               ipt=$(($ipt+1))
            else
               eq=0
               for i in `seq 0 $ipt`; do
                  if [ "${v_ips[i]}" == "$lb" ]; then
                     v_ipc[i]=$((${v_ipc[i]}+1))
                     eq=1
                  fi
               done
               if [ $eq -eq 0 ]; then
                  v_ips[ipt]=$lb
                  v_ipc[ipt]=1
                  ipt=$(($ipt+1))
               fi 
            fi
         fi
      done

      maior=0
      menor=200000

      for i in `seq 0 $(($ipt-1))`; do
         if [ ${v_ipc[i]} -gt $maior ]; then
            maior=${v_ipc[i]}
            id_maior=$i
         elif [ ${v_ipc[i]} -lt $menor ]; then
            menor=${v_ipc[i]}
         fi
      done

      

      echo "${v_ips[id_maior]}"  > "rnclog/$n/OMS_IP"



#   fi
}



function start_rnc(){
   echo $4 > rnclog/$4/RNC_NAME
   echo $1 > rnclog/$4/RNC_IP
   echo "RNC" > rnclog/$4/RNC_TYPE
   echo "RNC" >  rnclog/$4/ELEMENT_TYPE
   get_omu_ip $1 $2 $3 $4
   get_zw7i $1 $2 $3 $4
   get_wbts_main $1 $2 $3 $4
   get_wbts_ip $1 $2 $3 $4
   get_target_id $1 $2 $3 $4
   get_zwqo $1 $2 $3 $4
   get_rncid $1 $2 $3 $4
   get_wbts_par $1 $2 $3 $4
   get_wcell_par $1 $2 $3 $4
   get_oms_ip $1 $2 $3 $4
   get_zusi $1 $2 $3 $4
   sleep 10
   sed -i "s/$4 RUNNING/$4 OK/g" status
   sleep 5
}

function update_ip(){
   #rm .ip 2>/dev/null
   if [ ! -f .ip ]; then
      cat /dev/null > .ip
   fi
   echo "Updating IP list..."
   total_rnc=`grep RNC /etc/opt/nokia/oss/diagspf/conf/diagnospf_elements.cf | wc -l`
   nbr=0
   for rnc in `grep RNC /etc/opt/nokia/oss/diagspf/conf/diagnospf_elements.cf | awk '{print $2}' | sed 's/<//g' | sed 's/>//g'`; do
      nbr=$(($nbr+1))
      echo -n "($nbr of $total_rnc) - $rnc "

      omu_wo=`exemmlmx -n $rnc -c "ZUSI:OMU;" | grep WO-EX | awk '{print $1}' | sed 's/-/,/g'`
      ip=""
      for ip in `exemmlmx -n $rnc -c "ZQRS:$omu_wo::SYM=YES;" -s 2>/dev/null | grep ESTAB | grep telnet | awk '{print $4}' | sed 's/\.telnet//g'`; do
         break;
      done
      if [ -z "$ip" ]; then
         for ip in `exemmlmx -n $rnc -c "ZQRI:OMU:EL0;"  -s 2>/dev/null | grep -v "(" | grep " L " | sed 's/\// /g' | awk '{print $2}'`; do
            break;
         done
      fi


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


      ip=`exemmlmx -n $rnc -c "ZQRI:OMU:EL0;" | grep " L " | grep -v "(" | awk '{print $2}' | awk  -F "/" '{print $1}'`
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

#SendCMD "10.222.165.42" $user $pass "ZDDS;" "ZRS:31,50BE" "dpcutbf" "exit" "ZE;"

rm status 2>/dev/null
cat /dev/null > status
rm -rf rnclog 2>/dev/null
clear
echo "Script started!"
if [ "$1" == "-updateip" ]; then
   update_ip
fi

for ip in `cat .ip`; do
   #Test user and password:
   if [ `SendCMD $ip $user $pass "?" | grep "USER AUTHORIZATION FAILURE" | wc -c` -gt 0 ]; then
      echo "$ip User/Password failure!" >> status
      
   else
#      arncname=`SendCMD $ip $user $pass " " | grep -E '\-.*\:' | awk '{print $2}'`

      w_omu=`SendCMD  $ip $user $pass "ZUSI:OMU;" | grep "WO-EX" | awk '{print $1}' | sed 's/-/,/g'`
   
      for arncname in `SendCMD  $ip $user $pass "ZDFD:$w_omu:9F20001,0;" | grep "\.\." | awk '{print $17}'`;  do break; done;

      while [ `echo $arncname | wc -c` -gt 15 ]; do
         arncname=`echo $arncname | sed 's/^.//g'`
      done

      arncname=`echo $arncname | sed 's/\.//g'`

      arncname=`echo $arncname | sed 's/ //g'`


      if [ `echo $arncname | wc -c` -le 2 ]; then
         arncname=`SendCMD $ip $user $pass "ZDDE::\"ZL:1\",\"ZLE:1,RUOSTEQX\",\"Z1C\";" | grep "RNC name:" | awk '{print $3}' | sed 's/\x0d//g'`
         echo "LEN= `echo $arncname | wc -c`"
      fi

      echo "$arncname RUNNING" >> status
      
      #OMU IP
      mkdir -p rnclog/$arncname
      echo "Starting $arncname..."
      start_rnc  $ip $user $pass $arncname & 
      sleep 3 
   fi

done
sleep 10
while [ `grep "RUNNING" status | wc -c` -gt 0 ]; do
   clear
   cat status
   sleep 10
done

for rnc in `grep FAILED status | awk '{print $1}'`; do
   rm -rf rnclog/$rnc 2>/dev/null
done

netact_name=`uname -n`
cd rnclog
rm *.zip 2>/dev/null
echo -n "Creating "$netact_name"_rnc.zip..."
zip -r $netact_name"_rnc.zip" * 2>/dev/null 1>/dev/null
if [ -f $netact_name"_rnc.zip" ]; then
   echo "Ok!"
   mv $netact_name"_rnc.zip" ..
else
   echo "Failed!"
fi

cd ..

