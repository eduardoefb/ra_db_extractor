#!/bin/bash


function create_plot_script(){
cat > plota << EOF
#!/usr/bin/gnuplot
# set terminal png transparent nocrop enhanced size 450,320 font "arial,8" 
set key inside right top vertical Right noreverse noenhanced autotitle nobox
set datafile missing '-'
set style data linespoints
set xtics border in scale 1,0.5 nomirror rotate by -45  autojustify
set xtics  norangelimit
set xtics   ()
set title "$3" 
x = 0.0
i = 22
set term png
set terminal png size 1000,600
set output "$1"
plot '$2' using 3:xtic(2) title columnheader(2), for [i=3:3] '' using i title columnheader(i)
EOF

chmod +x plota
./plota 
}

source /opt/nokia/nedata/scripts/var.conf

apache_pw=`cat $APACHE_PW_FILE`
mkdir -p $GRAPH_IMG_DIR
rm $GRAPH_IMG_DIR/*{.csv,.png} 2>/dev/null


#Delete the invalid date "0000-00-00":
mysql -u apache -p$apache_pw nsn  << EOF
DELETE FROM totalElements WHERE totalElements.DATE = '0000-00-00'
EOF


idcnt=0
unset idlst
for idfile in `find $NE_LOG_DIR -name .id`; do
   id=`cat $idfile`
   idcnt=$(($idcnt+1))
   idlst[idcnt]=$id
done

for cust in ${idlst[*]}; do
for cname in `mysql -u apache -p$apache_pw nsn  << EOF
SELECT cliente.name AS CUSTOMER from cliente WHERE cliente.id = $cust;
EOF`; do
   cat /dev/null
done

#2G
   for str in BSC BCF FlexiEdge FlexiMultiRadio Ultrasite MetroSite TRX; do
mysql -u apache -p$apache_pw nsn > $GRAPH_IMG_DIR/$cust-$str.csv << EOF
SELECT totalElements.CustomerId as Customer,
       totalElements.DATE as DATE,
       totalElements.Quantity AS $str
 FROM totalElements WHERE totalElements.CustomerId = $cust AND totalElements.Type LIKE '%$str%' ORDER BY totalElements.Date;
EOF
   create_plot_script $GRAPH_IMG_DIR/$cust-$str.png $GRAPH_IMG_DIR/$cust-$str.csv $cname-$str
   done


#3G
   for str in RNC WBTS WCEL; do
mysql -u apache -p$apache_pw nsn > $GRAPH_IMG_DIR/$cust-$str.csv << EOF
SELECT totalElements.CustomerId as Customer,
       totalElements.DATE as DATE,
       totalElements.Quantity AS $str
 FROM totalElements WHERE totalElements.CustomerId = $cust AND totalElements.Type LIKE '%$str%'  ORDER BY totalElements.Date;
EOF
   create_plot_script $GRAPH_IMG_DIR/$cust-$str.png $GRAPH_IMG_DIR/$cust-$str.csv $cname-$str
   done


#4G
   for str in LTEBTS LNCEL; do
mysql -u apache -p$apache_pw nsn > $GRAPH_IMG_DIR/$cust-$str.csv << EOF
SELECT totalElements.CustomerId as Customer,
       totalElements.DATE as DATE,
       totalElements.Quantity AS $str
 FROM totalElements WHERE totalElements.CustomerId = $cust AND totalElements.Type LIKE '%$str%'  ORDER BY totalElements.Date;
EOF
   create_plot_script $GRAPH_IMG_DIR/$cust-$str.png $GRAPH_IMG_DIR/$cust-$str.csv $cname-$str
   done


#PACO FNS
   for str in FNS; do
mysql -u apache -p$apache_pw nsn > $GRAPH_IMG_DIR/$cust-$str.csv << EOF
SELECT totalElements.CustomerId as Customer,
       totalElements.DATE as DATE,
       totalElements.Quantity AS $str
 FROM totalElements WHERE totalElements.CustomerId = $cust AND totalElements.Type LIKE '%$str%' ORDER BY totalElements.Date;
EOF
   create_plot_script $GRAPH_IMG_DIR/$cust-$str.png $GRAPH_IMG_DIR/$cust-$str.csv $cname-$str
   done
done
