<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <title>Network element information</title>      
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
           #Define variables:
           $query_dir = "/opt/nokia/nedata/scripts/queries/";
                   
           $op = $_GET['op'];   
         ?>
		  
		 <!-- Links at header -->
         <a href="../main.php"><img src="../eme/img/icon/home.png" title="Home" height="36"></a>
         &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
         <!--
         <a href="charts/index.php"><img src="../eme/img/icon/graph.png" title="Average network growth" height="36"></a>
         &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
         -->
         <a href="upload.php"><img src="../eme/img/icon/upload.png" title="Upload and manage logs" height="36"></a>       
         &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp           
         <a href="download_menu.php"><img src="../eme/img/icon/xlsx.png" title="Download complete information" height="36"></a>        		
         <frame1>
		     <a href="../main.php">
			     <img src="../eme/img/nokia_logo.png" height="26">
		     </a>
		     <br>
		     <br>
		     <frame2>
				 <?php 
				    if($op == "ra"){						
				 ?>
				       <h2>Radio access information:</h2>
                       <br>
                       <b>Select the customer:</b>
                       <form name="sel_dir" action=list.php method="get">
						  <select name="cust">
							  <?php
                                 $res = mysqli_query($con, "SELECT * FROM cliente ");
                                 while ($row = mysqli_fetch_array($res)) {
                                    $id = $row['id'];
                                    $name = $row['name'];
                                    echo $name;
                                    echo '<option value="' . $id . '">' . $name . '</option>';
                                 }      
							  ?>
						  </select>
                          <br><br>
                          <b>Select the query:</b>
                          <br>
                          <select name="query">
                             <?php                             
                                $query_file_list = scandir($query_dir);                                                        
                                for($i = 0; $i < sizeof($query_file_list); $i++){								 
								    if(strstr($query_file_list[$i], ".sql")){
                                       $fname_display = str_replace(".sql", "", $query_file_list[$i]);
                                       $fp = fopen($query_dir . $query_file_list[$i], "r");
                                       if($fp){
                                          while (!feof($fp)){								
									         $line = fgets($fp);
									         if(strstr($line, "QUERY_NAME:")){
   										        $line = str_replace("QUERY_NAME:", "", $line);
										        $line = str_replace("/*", "", $line);
                                                $line = trim(str_replace("*/", "", $line));                                                									        
									            echo '<option value="' . $fname_display . '-' . $line . '">' . $fname_display . '-' . $line . '</option>';									      
										     }
									      
                                          }
									   fclose($fp);
								    }
								    else{
										echo "open error!";
									}
                                    
								}								 
							 }                             
                          ?>                          
                          </select>
                          <br><br>
                          <input type="submit" value="   OK   ">
                       </form>		    

                          
				 <?php
			        }
				 ?>				 			     
		     </frame2>
		                                                      

         </frame1>
      </body>
</html>
