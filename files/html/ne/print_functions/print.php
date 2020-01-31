<?php
   function count_tcsm_type($tc_type, $c_id, $con) {
      $query_tmp = "SELECT BSCNAME, CNUMBER, TCSM_CNT
                     FROM( 
                        SELECT COUNT(tcsm.bsc_cnumber_fk) AS TCSM_CNT, bsc.cnumber AS CNUMBER, bsc.name AS BSCNAME 
                          FROM tcsm 
                            RIGHT JOIN bsc 
                              ON bsc.cnumber = tcsm.bsc_cnumber_fk AND tcsm.tc_type = '$tc_type' AND tcsm.state <> 'SE-NH' 
                              INNER JOIN cliente 
                                 ON cliente.id = bsc.cliente_fk AND cliente.id = $c_id GROUP BY(bsc.cnumber)) AS TCSM 
                                 ORDER BY BSCNAME;";

      $result = mysqli_query($con, $query_tmp);
      $nbr_bscs = 1;
      while ($row = mysqli_fetch_array($result)) {
         $tcsm_t[$nbr_bscs] = $row['TCSM_CNT'];
         $nbr_bscs++;
      }
      $tcsm_t[$nbr_bscs] = -1;
      return $tcsm_t;
   }

   function count_bts_type($bts_type, $c_id, $con) {
      $query_tmp = "SELECT BSCNAME, CNUMBER, TYPE_CNT
                   FROM( 
                     SELECT COUNT(bcf.bcf_type) AS TYPE_CNT, bsc.cnumber AS CNUMBER, bsc.name AS BSCNAME 
                        FROM bcf 
                          RIGHT JOIN bsc 
                            ON bsc.cnumber = bcf.bsc_cnumber AND bcf.bcf_type = '$bts_type' 
                          INNER JOIN cliente 
                            ON cliente.id = bsc.cliente_fk AND cliente.id = $c_id GROUP BY(bsc.cnumber)) AS ULTRA 
                          ORDER BY BSCNAME;";

      $result = mysqli_query($con, $query_tmp);
      $nbr_bscs = 1;
      while ($row = mysqli_fetch_array($result)) {
         $bts_t[$nbr_bscs] = $row['TYPE_CNT'];
         $nbr_bscs++;
      }
      $bts_t[$nbr_bscs] = -1;
      return $bts_t;
   }

   function hit_print($fp, $nbr, $el_name, $el_ip) {
      fprintf($fp, "
   [CONNECTION_%s]
   NAME=%s
   PORT=%s
   PROMPTCHECK=BOTH
   ECHOCHECK=ON
   TIMEOUT=20
   SUFFIX=\\r
   TYPE=1
   RATE=9600
   PARITY=EVEN
   DATABITS=7
   PROMPTDELAY=0
   BREAK=\"CTRL-Y,CTRL-C\"
   DEFAULTKEY=\"\\r\"
   SSH_USED=0
   SSH_LOGINTYPE=SHARED_SECRETS
   SSH_VERSION=1
   SSH_PORT=22
   SSH_PRIVATEKEYFILE=\"\"
   SSH_CMDLINEPARAMS=\"\"
   SSH_SECLEVEL=0
   SSH_OVERRIDESETTINGS=0
   SSH_LOGFILEHANDLING=APPEND
   USERNAMEQ=\"ENTER USERNAME < \"
   PASSWORDQ=\"ENTER PASSWORD < \"
   USERNAME=\"\"
   PASSWORD=\"\"
   USERNAMEQ_2ND=\"\"
   PASSWORDQ_2ND=\"\"
   USERNAME_2ND=\"\"
   PASSWORD_2ND=\"\"
   EXTRAQ=\"\"
   EXTRAA=\"\"
   EXTRAQ2=\"\"
   EXTRAA2=\"\"
   PROMPT_1=\"\"
   PROMPT_2=\"\"
   PROMPT_3=\"\"
   REVIVAL_1=\"\\r\"
   REVIVAL_2=\"\\r\"
   REVIVAL_3=\"\\r\"
   REVIVAL_4=\"\\r\"
   STOPBITS=2
   FLOW=Xon/Xoff", $nbr, $el_name, $el_ip);
   }

   function hit3_print($fp, $nbr, $el_name, $el_ip) {
      fprintf($fp, "[CONNECTION_%s]
   NAME=%s
   PORT=%s
   PROTOCOL=DX_TELNET
   PROMPTCHECK=BOTH
   ECHOCHECK=ON
   TIMEOUT=20
   POOLREFRESHINTERVAL=0
   SUFFIX=\"\\r\"
   BREAK=\"CTRL-Y,CTRL-C\"
   DEFAULTKEY=\"\\r\"
   USERNAMEQ=\"ENTER USERNAME < \b \"
   PASSWORDQ=\"ENTER PASSWORD < \b \"
   USERNAME=\"\"
   PASSWORD=\"00160E0AB85A431314154F3966BC111B1C1D451F20215323242546B3CA32320059\"
   USERNAMEQ_2ND=\"\"
   PASSWORDQ_2ND=\"\"
   USERNAME_2ND=\"\"
   PASSWORD_2ND=\"00160E0AB85A431314154F3966BC111B1C1D451F20215323242546B3CA32320059\"
   PROMPT_1=\"\"
   PROMPT_2=\"\"
   PROMPT_3=\"\"
   REVIVAL_1=\"\\r\"
   REVIVAL_2=\"\\r\"
   REVIVAL_3=\"\\r\"
   REVIVAL_4=\"\\r\"
   DEF_TERM_OPTIONS=1\n", $nbr, $el_name, $el_ip);
   }

   function header_table($hdr, $label, $name, $ini) {

      if($ini){
         echo "<a href=\"" . $_SERVER['HTTP_REFERER'] . "\"><img src=\"../../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";
         echo "<frame1>";
      }

      $name = str_replace("_", " ", $name);
      if($ini){
         echo "<a href=\"../main.php\"><img src=\"../eme/img/nokia_logo.png\" height=\"26\"></a>";
      }

      echo "<h2>$name</h2>";
      echo "<table>";
      echo "<tr>";
      echo "<th><FONT Face=\"Verdana\" <FONT SIZE=-2><div align=\"center\">NBR</div></FONT></FONT></th>";
      foreach ($hdr as $n) {
         echo "<th><FONT Face=\"Verdana\" <FONT SIZE=-2><div align=\"center\">$n</div></FONT></FONT></th>";
      }
   }

   function print_csv($fp, $hdr, $nbr) {
      if ($nbr > 0) {
         $str = $nbr;
      } else {
         $str = "NBR";
      }
      foreach ($hdr as $n) {
         $str = "$str,$n";
      }
      fprintf($fp, "%s\n", $str);
   }

   function print_table($pos, $hdr, $nbr) {
      $h_color = "#444444";

      switch ($pos) {
         case 1: $p = "left";
            break;
         case 2: $p = "right";
            break;
         default: $p = "center";
            break;
      }
      echo "<tr>";
      echo "<td><FONT Face=\"Verdana\"COLOR=\"$h_color\"<FONT SIZE=-2><div align=\"$pos\"> $nbr </div></FONT></FONT></td>";
      foreach ($hdr as $n) {
         echo "<td><FONT Face=\"Verdana\"COLOR=\"$h_color\"<FONT SIZE=-2><div align=\"$pos\"> $n </div></FONT></FONT></td>";
      }
   }

   function close_table() {
      echo "</tr>";
      echo "</table>";
   }

   function get_customer($con, $cust) {
      $result = mysqli_query($con, "SELECT cliente.name AS NAME FROM cliente WHERE cliente.id = '$cust'");
      while ($row = mysqli_fetch_array($result)) {
         $name = $row['NAME'];
         break;
      }
      return $name;
   }

   function print_gen($con, $cust, $html, $query, $csv_name, $ini) {
      if (!$html) {
         $custname = get_customer($con, $cust);
         $csv_fname = sprintf("csv_files/%s_%s.csv", $custname, $csv_name);
      }

      if (file_exists($csv_fname) && !$html) {
         echo "<a class=\"link\" href=\"$csv_fname\">Download file: $csv_fname<br></a>";
         return $csv_fname;
      }

      $nbr = 0;
      $result = mysqli_query($con, $query);

      $cnt = 0;
      while ($property = mysqli_fetch_field($result)) {
         $fields[$cnt] = $property->name;
         $cnt++;
      }

      if ($html) {
         if (strstr($csv_name, "Label:")) {
            $csv_name = str_replace("Label:", "", $csv_name);
            header_table($fields, $csv_name, $csv_name, $ini);
         } else {
            header_table($fields, "", $csv_name, $ini);
         }
      } else {
         $fp = fopen($csv_fname, 'w');
         print_csv($fp, $fields, 0);
      }

      while ($row = mysqli_fetch_assoc($result)) {
         $nbr++;
         if ($html) {
            print_table(0, $row, $nbr);
         } else {
            print_csv($fp, $row, $nbr);
         }
      }

      close_table();
      fclose($fp);
      if (!$html)
         echo "<a class=\"link\" href=\"$csv_fname\">Download file: $csv_fname<br></a>";
      return $csv_fname;
   }

 
   function hit2_file($con, $cust, $html) {
      $custname = get_customer($con, $cust);
      $hit_fname = sprintf("csv_files/%s_HIT2.INI", $custname);
      if (!file_exists($hit_fname)) {
         $fp = fopen($hit_fname, 'w');
         $nbr = 0;
         $query = "select bsc.name AS NAME, bsc.ip AS IP FROM bsc, cliente WHERE bsc.cliente_fk = cliente.id AND cliente.id = $cust AND bsc.ip <> \"X.25\" ORDER BY bsc.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $el_name = $row['NAME'];
            $el_ip = $row['IP'];
            hit_print($fp, $nbr, $el_name, $el_ip);
         }
         $query = "select rnc.name AS NAME, rnc.ip AS IP FROM rnc, cliente WHERE rnc.cliente_fk = cliente.id AND cliente.id = $cust AND rnc.ip <> \"X.25\" ORDER BY rnc.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $el_name = $row['NAME'];
            $el_ip = $row['IP'];
            hit_print($fp, $nbr, $el_name, $el_ip);
         }
         $query = "select fns.name AS NAME, fns.ip AS IP FROM fns, cliente WHERE fns.customer_fk = cliente.id AND cliente.id = $cust ORDER BY fns.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $el_name = $row['NAME'];
            $el_ip = $row['IP'];
            hit_print($fp, $nbr, $el_name, $el_ip);
         }
         
         
         fclose($fp);
      }
      echo "<a class=\"link\" href=\"$hit_fname\">Download file: $hit_fname (HIT2 NI File - BSC and RNC)<br></a>";
      return $hit_fname;
   }

   function hit3_file($con, $cust, $html) {
      $custname = get_customer($con, $cust);
      $hit_fname = sprintf("csv_files/%s_hit3_devices.ini", $custname);
      if (!file_exists($hit_fname)) {
         $fp = fopen($hit_fname, 'w');
         $nbr = 0;
         $query = "select bsc.name AS NAME, bsc.ip AS IP FROM bsc, cliente WHERE bsc.cliente_fk = cliente.id AND cliente.id = $cust AND bsc.ip <> \"X.25\" ORDER BY bsc.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $el_name = $row['NAME'];
            $el_ip = $row['IP'];
            hit3_print($fp, $nbr, $el_name, $el_ip);
         }
                           
         $query = "select rnc.name AS NAME, rnc.ip AS IP FROM rnc, cliente WHERE rnc.cliente_fk = cliente.id AND cliente.id = $cust AND rnc.ip <> \"X.25\" ORDER BY rnc.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $el_name = $row['NAME'];
            $el_ip = $row['IP'];
            hit3_print($fp, $nbr, $el_name, $el_ip);
         }

         $query = "select fns.name AS NAME, fns.ip AS IP FROM fns, cliente WHERE fns.customer_fk = cliente.id AND cliente.id = $cust ORDER BY fns.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $el_name = $row['NAME'];
            $el_ip = $row['IP'];            
            hit3_print($fp, $nbr, $el_name, $el_ip);
         }         
         
         

         
         fclose($fp);
      }
      echo "<a class=\"link\" href=\"$hit_fname\">Download file: $hit_fname (HIT3 NI File - BSC and RNC)<br></a>";
      return $hit_fname;
   }

   function tang_file($con, $cust, $html) {
      $custname = get_customer($con, $cust);
      $tang_fname = sprintf("csv_files/%s_TANG.INI", $custname);
      if (!file_exists($tang_fname)) {
         $fp = fopen($tang_fname, 'w');
         $nbr = 0;
         $query = "select bsc.name AS NAME, bsc.ip AS IP FROM bsc, cliente WHERE bsc.cliente_fk = cliente.id AND cliente.id = $cust AND bsc.ip <> \"X.25\" ORDER BY bsc.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $tang_str[$nbr] = sprintf("Connection%s=%s,Telnet,%s,,,\n", $nbr, $row['NAME'], $row['IP']);
         }
         $query = "select rnc.name AS NAME, rnc.ip AS IP FROM rnc, cliente WHERE rnc.cliente_fk = cliente.id AND cliente.id = $cust AND rnc.ip <> \"X.25\" ORDER BY rnc.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;
            $tang_str[$nbr] = sprintf("Connection%s=%s,Telnet,%s,,,\n", $nbr, $row['NAME'], $row['IP']);
         }
                  
         $query = "select fns.name AS NAME, fns.ip AS IP FROM fns, cliente WHERE fns.customer_fk = cliente.id AND cliente.id = $cust ORDER BY fns.name;";
         $result = mysqli_query($con, $query);
         while ($row = mysqli_fetch_array($result)) {
            $nbr++;                        
            $tang_str[$nbr] = sprintf("Connection%s=%s,Telnet,%s,,,\n", $nbr, $row['NAME'], $row['IP']);
         }
         fprintf($fp, "[CONNECTIONS]\n");
         fprintf($fp, "Connections=%s\n", $nbr);
         for ($i = 1; $i <= $nbr; $i++) {			
            fprintf($fp, "%s", $tang_str[$i]);
         }
      }
      fclose($fp);
      echo "<a class=\"link\" href=\"$tang_fname\">Download file: $tang_fname (HIT2 NI File - BSC and RNC)<br></a>";
      return $tang_fname;
   }
?>

