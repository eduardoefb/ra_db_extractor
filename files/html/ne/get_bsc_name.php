<?php
   function get_bsc_name($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "CON  TYPE     SW  C-NUM   ID  NAME         LOCATION          CHA  STATE  CTYP")){
            $lin = fgets($fp);
            $lin = fgets($fp);
            sscanf($lin, "%*s %*s %*s %*s %s %*s", $ret_val);
            return($ret_val);
         }
      }
      fclose($fp);
      return "-";
   }


   function get_q3version($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "OMC000000D1")){
            $lin = fgets($fp);
            sscanf($lin, "%*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %*s %s", $ret_val);
            fclose($fp);
            return($ret_val);
         }
      }
      fclose($fp);
      return "-";
   }


   function get_bsc_target_id($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      $offset = 0;
      $line_found = 0;
      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "CON  TYPE     SW  C-NUM   ID  NAME         LOCATION          CHA  STATE  CTYP"))
            $line_found = 1;
         else if($line_found)
            $offset++;
         
         if($offset == 2){
            #"000  BSC       5  715420      BSC02ALV     ALVORADA");
            sscanf($lin, "%*s %*s %*s %s %*s %*s", $ret_val);
            return($ret_val);
         }

      }
      fclose($fp);
      return "-";
   }


   function get_bsc_location($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      $offset = 0;
      $line_found = 0;
      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "CON  TYPE     SW  C-NUM   ID  NAME         LOCATION          CHA  STATE  CTYP"))
            $line_found = 1;
         else if($line_found)
            $offset++;
         
         if($offset == 2){
            #"000  BSC       5  715420      BSC02ALV     ALVORADA");
            sscanf($lin, "%*s %*s %*s %*s %*s %s", $ret_val);
            return($ret_val);
         }

      }
      fclose($fp);
      return "-";
   }

   function get_bsc_state($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         return "UNKNOW";
      }
      $lin = fgets($fp);
      fclose($fp);
      return trim($lin);
   }

   function get_bsc_type($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "-") && strstr($lin, ":") && !strstr($lin, "#HIT")){
            sscanf($lin, "%s %*s", $ret_val);
            return $ret_val;
         }

      }
      fclose($fp);
      return "-";
   }

   function get_bsc_date($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "-") && strstr($lin, ":") && !strstr($lin, "#HIT")){
            sscanf($lin, "%*s %*s %s", $ret_val);
            return $ret_val;
         }

      }
      fclose($fp);
      return "-";
   }

   function get_prf_ver($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "PRFILEGX.PAC")){
            sscanf($lin, "%*s %s %*s", $fv);
            sscanf($lin, "%*s %*s %*s %*s %*s %*s %s", $cid);
            $ret_val = sprintf("%s/%s",$fv, $cid); 
            return $ret_val;
         }

      }
      fclose($fp);
      return "-";

   }

   function get_fif_ver($filename){
      $fp = fopen($filename, "r");
      if(!$fp){
         echo "<br>$filename not found!</br>";
         return 0;
      }

      while(!feof($fp)){
         $lin = fgets($fp);
         if(strstr($lin, "FIFILEGX.PAC")){
            sscanf($lin, "%*s %s %*s", $fv);
            sscanf($lin, "%*s %*s %*s %*s %*s %*s %s", $cid);
            $ret_val = sprintf("%s/%s",$fv, $cid); 
            return $ret_val;
         }

      }
      fclose($fp);
      return "-";

   }


?>
