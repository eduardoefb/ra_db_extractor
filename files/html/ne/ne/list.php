<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <title>List queries</title>
      <link rel="shortcut icon" href="../eme/img/icon/nokia_favicon.png"/>
      <style>
         frame1 {
            display:block;
            padding:10px;
            border:2px solid #444;
            background-color: #ddd;
            margin:2px;
            font-family: "Verdana", Times, serif;
            font-style: normal;
            font-size: 12px;
         }
         
         frame2 {
            display:block;
            padding:10px;
            border:1px solid #444;
            background-color: #ccc;
            margin:1px;
            font-family: "Verdana", Times, serif;
            font-style: normal;
         }
      </style>
      <style type="text/css">
         table
         {
            border-collapse:collapse;
         }
         
         table, td, th
         {
            border:1px solid #888;            
         }
         th
         {
            background-color:#333;
            color:white;
            font-style: normal;
            text-align: center;
            font-size: 10px;
         }
         td{
            background-color:#eee;
            color:#333;
            font-family: "Verdana", Times, serif;
            font-style: normal;
            text-align: left;
            font-size: 11px;
         }
         p1{
            color:#aaa;
         }

         .link:hover{
            font-weight:bold;
         }
      </style>      
   </head>      
   <body>
      <?php
      
         //Include php lib files:
         include "../auth/authentication.php";
         include "print_functions/print.php";
                  
         //Start open mysql connection:
         $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));
         if (mysqli_connect_errno($con)) {
			 echo '<frame1>
			          <frame2>
			             <b>
			                <font color="red">Failed to connect to MySQL: ' . mysqli_connect_error() . '</font>
			             </b>
			          </frame2>
			       </frame1>';
			 mysqli_close($con);
			 return 0;
			 
         }
         $customer_id = $_GET['cust'];
         $query = $_GET['query'];
         $query_dir = "/opt/nokia/nedata/scripts/queries/";
      ?>

		 <!-- Links at header -->
         <a href="index.php?op=ra"><img src="../eme/img/icon/back.png" title="Home" height="36"></a> 
         &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
      
      <frame1>
		     <a href="../main.php">
			     <img src="../eme/img/nokia_logo.png" height="26">
		     </a>
		     <br><br>
		     		  
		  <frame2>
			  <?php
			     
			     $file_name = $query_dir . explode("-", $query)[0] . ".sql";
			     $query_name = explode("-", $query)[1];
			     
			     echo '<b>Query name: ' . $query . '</b>';
			     
			     echo "<br>";
			     echo "<br>";
			     $query_command = "";			     
			     $fp = fopen($file_name, "r");
			     if($fp){
					 while(!feof($fp)){						
					    $line = fgets($fp);
					    if(strstr($line, "QUERY_NAME:")){
                           $line = str_replace("QUERY_NAME:", "", $line);
                           $line = str_replace("/*", "", $line);
                           $line = trim(str_replace("*/", "", $line));  
                           if($line == $query_name){
							   
							   while($line = fgets($fp)){
								   if(strlen(trim($line)) == 0 || feof($fp)){
									   break;
								   }								   
								   
								   $line = trim($line);
								   $query_command = $query_command . ' ' . str_replace("_cid_", $customer_id, str_replace("_xml_", "xmlfiles", str_replace("_log_", "logfiles", $line)));
							   }
						      break;
						   }
					    }
					    
					 }
					 fclose($fp);					 	
					 					 
					 $res = $con->query($query_command);
					 ?>
					    <table>
							
					 <?php
					    $col_cnt = 0;					 
                        while($row = mysqli_fetch_field($res)){						 						 
						   echo '<th>' . $row->name . '</th>';
						   $col_name[$col_cnt] = $row->name;
                           $col_cnt++;
				        }
				        while($row = $res->fetch_assoc()) {
						   echo '<tr>';
						   for ($i = 0; $i < $col_cnt; $i++){
							   echo '<td>' . $row[$col_name[$i]] . '</td>';
						   }
						   echo '</tr>';
						}
				        
				        
				     ?>
				        </table>				        
				     <?php
					 
				 }
				 else{
					 echo "File read error: " . $file_name . "!";
					 return 0;
				 }
			     
			  ?>
		  </frame2>		
      </frame1>
      <?php
         #mysqli_close($con);
      ?>                  
   </body>
</html>
