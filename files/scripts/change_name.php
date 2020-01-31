<?php
   include '/var/www/htdocs/bsc_functions/get_bsc_name.php';
   include '/var/www/htdocs/bsc_functions/get_rnc_name.php';
   include '/var/www/htdocs/bsc_functions/get_omu_ip.php';
   include '/var/www/htdocs/bsc_functions/get_sw_version.php';
   include '/var/www/htdocs/bsc_functions/get_bsc_capacity.php';

   $APACHE_LOC="/var/bscdata/users/.apache";
   $fp = fopen($APACHE_LOC, "r");
   $apache_p = fgets($fp);
   fclose($fp);
   $apache_p = trim($apache_p);

   $con =   mysqli_connect(localhost,apache,$apache_p,nsn); 
   if (mysqli_connect_errno()){
      echo "Failed to connect to MySQL: " . mysqli_connect_error();
      exit;
   }

   $dir_a = "/var/www/htdocs/bsc/logs";
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
