<?php
   $dir_a = "/opt/nokia/nedata/logs";
   $dir_a_lst = opendir($dir_a);
   while(($dir_b = readdir($dir_a_lst)) !== false){
      if(!(strstr($dir_b, "."))){
         $customer_name = $dir_b;
         $dir_b = "$dir_a/$dir_b";
         printf("$dir_b\n");
         $dir_b_lst = opendir($dir_b);
         $fp = fopen("$dir_b/.id", "r");
         $customer_id = rtrim(fgets($fp));
         fclose($fp);

         while(($dir_c = readdir($dir_b_lst)) !== false){
            if(!(strstr($dir_c, ".")) && (strstr($dir_c, "-current"))){
               $find_dir = "$dir_b/$dir_c";
               $new_name = str_replace("-current", "", $find_dir);

               rename($find_dir , "$new_name");
               printf("$customer_id $customer_name $dir_c $find_dir\n");
            }
         }
         
      }
   }
?>
