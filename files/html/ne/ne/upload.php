<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <title>Upload files</title>
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
         
         //Check if it's ordering for a file upload:
         if(count($_FILES['filen']['name']) > 0){			
			$cname = $_POST['cust'];			
			if (strlen(trim($cname)) == 0){
			   echo '<a href="upload.php?op=ra"><img src="../eme/img/icon/back.png" title="Back" height="36"></a>
			          <frame1>
			            <frame2>
			               <b><font color="red">Customer must be selected!</font></b>
			               </frame2>
			         </frame1>';
			   mysqli_close($con);		        
			   return 0;	
            }
            else{
               $date = new DateTime();
               for($i = 0; $i < count($_FILES['filen']['name']); $i++) {
                  $tmpname = $_FILES['filen']['tmp_name'][$i];
                  $fname = $_FILES['filen']['name'][$i];                  
                  $uuid = uniqid();
                  $res = $con->query('SELECT id FROM cliente WHERE cliente.name = \'' . $cname. '\';' );				  
                  while ($row = $res->fetch_assoc()){
                     $cust_id = $row['id'];
                     break;
                  }                  
                  if(move_uploaded_file($tmpname, "/opt/nokia/nedata/log_tmp/$uuid-$cname-$fname")) {
                     $succ_msg = $succ_msg . "<br>" . $fname;                     						 
                     $query = 'INSERT INTO files (id,name , customer_id, status, date) VALUES ("'. $uuid .'", "' . $fname . '", "' . $cust_id . '", "NEW", "' . $date->format('Y-m-d H:i') . '");';						 						 
                     $con->query($query);
                  }
                  else{
                     $error_msg = $error_msg . "<br>" . $fname;
                  }
			   }               
		    }                        
	     }
                  
      ?>
      <a href="index.php?op=ra"><img src="../eme/img/icon/back.png" title="Home" height="36"></a>      
      <frame1>
         <a href="../main.php"><img src="../eme/img/nokia_logo.png" height="26"></a>
         <br><br>
         <frame2>
                        
            <!-- Customer and file upload --->
            <h2>Choose the file(s) to upload:</h2>
            <form enctype="multipart/form-data" action="upload.php" method="POST">
               <input type="hidden" name="MAX_FILE_SIZE" value="100000000000000">
               <input name="filen[]" type="file" multiple="multiple"/>  
               <br>
               <h2>Customer Selection:</h2>  
                  <select name="cust">
					  <option value=""></option>
                     <?php
                        #Populate customer list into listbox:
                        $result = mysqli_query($con, "SELECT * FROM cliente ");
                        while ($row = mysqli_fetch_array($result)) {
                           echo '<option value="'. $row['name'] . '">' .$row['name'] . '</option>';
					    }
                     ?>                     
                  </select>               
               &nbsp            
               <input type="submit" value="Upload" />   
            </form>                       
         </frame2>
         <br>
         <frame2>
            <h2>Log files</h2>
            <?php               
               foreach($_GET as $key => $value){
                  if (substr( $key, 0, 5 ) == "file_") {
                     $key = str_replace("file_", "", $key);
                     $key = rtrim($key, "_");						                        
                     if($value == "DELETE"){
                        $query = "UPDATE files SET files.status = 'WAITING REMOVAL' WHERE files.id = '". $key ."';" ;
                        $res = $con->query($query);
                     }
					    
                     elseif($value == "ACTIVATE"){
                        $query = "UPDATE files SET files.status = 'WAITING ACTIVATION' WHERE files.id = '". $key ."';" ;							   
                        $res = $con->query($query);							   
                     }
                     
                     elseif($value == "DEACTIVATE"){
                        $query = "UPDATE files SET files.status = 'WAITING DEACTIVATION' WHERE files.id = '". $key ."';" ;							   
                        $res = $con->query($query);							   
                     }
                  }
			   }
            ?>
            
            <?php                     
               $query = "SELECT files.id AS ID, files.date AS DATE, files.name AS NAME, cliente.name AS CUSTOMER, files.status AS STATUS FROM files, cliente WHERE files.customer_id = cliente.id;";
               $res = $con->query($query);
            ?>
                        
            <form name="form1"action="upload.php" method="get">
               <table>
                  <tr>     
                     <?php
                        $col_cnt = 0;
                        while($row = mysqli_fetch_field($res)){
							echo '<th>' . $row->name . '</th>';
                            $col_name[$col_cnt] = $row->name;
                            $col_cnt++;							
                        }
                     ?>
                     <th>ACTION</th>
                  </tr>             
                  <?php					    
                     while($row = $res->fetch_assoc()) {
                        echo '<tr>';
                        for ($i = 0; $i < $col_cnt; $i++){
                           if(strstr($row[$col_name[$i]], "WAITING")){
                              echo '<td><font color="orange"><b>' . $row[$col_name[$i]] . '</b></font></td>';
						   }
						   elseif( $row[$col_name[$i]] == "ACTIVATING" || $row[$col_name[$i]] == "DEACTIVATING"  || $row[$col_name[$i]] == "DELETING"){
                              echo '<td>
                                        <font color="blue">
                                           <div align="center">
                                              <b>' . $row[$col_name[$i]] . '</b>
                                           </div>
                                        </font>
                                    </td>';
                           }
                           else if( $row[$col_name[$i]] == "ACTIVE"){
                              echo '<td>
                                        <font color="green">
                                           <div align="center">
                                              <b>' . $row[$col_name[$i]] . '</b>
                                           </div>
                                        </font>
                                    </td>';							   
						   }
						   else if( $row[$col_name[$i]] == "NEW" || $row[$col_name[$i]] == "DELETED" || $row[$col_name[$i]] == "INACTIVE"){
                              echo '<td>                                        
                                           <div align="center">
                                              <b>' . $row[$col_name[$i]] . '</b>
                                           </div>                                        
                                    </td>';							   
						   }
						   
						   else{
                              echo '<td>' . $row[$col_name[$i]] . '</td>';
					       }
                        }
                        #Options for  logfile actions                                                
                        echo '<td>';
                        ?>
                        <?php 
                           echo '<select name="' . "file_" . $row['ID'] . '">';
                           echo '<option value="SELECT">SELECT</option>';
                           if( $row['STATUS'] == 'ACTIVE' ){							   
							   echo '<option value="DEACTIVATE">DEACTIVATE</option>';
                           }
                           else if( $row['STATUS'] == 'INACTIVE' || $row['STATUS'] == 'NEW' ){
							   echo '<option value="ACTIVATE">ACTIVATE</option>';
							   echo '<option value="DELETE">DELETE</option>';
						   }
						   
                        ?>                                     
                                </select>
                              </td>
                        <?php                      
                              
                              
                        echo '</tr>';
                     }
                        ?>
					
               </table>
               <br>
               <input type="submit" value="  OK   ">
            </form>
             
         </frame2>
         <br>
         <frame2>
            <h2>Spreadsheet files:</h2>
            <table>
				<tr>
                   <th>
					   <font size="-1">CREATED</font>
				   </th>
                   <th>
					   <font size="-1">UPDATED</font>
				   </th>				   
				   <th>
					   <font size="-1">FILE_NAME</font>
				   </th>
				   <th>
				      <font size="-1">STATUS</font>
				   </th>
				   <th>
				      <font size="-1">DOWNLOAD</font>
				   </th>				   
				</tr>
				<?php
                    $query = "SELECT xlsxfiles.created_date AS CREATED, xlsxfiles.finished_date AS PROCESSED, xlsxfiles.name AS FILE_NAME, xlsxfiles.status AS STATUS FROM xlsxfiles;";
                    $res = $con->query($query);
                    while($row = $res->fetch_assoc()) {
					    echo '<tr>';
					    echo '<td><div align="center">' . $row['CREATED'] . '</div></td>';
					    echo '<td><div align="center">' . $row['PROCESSED'] . '</div></td>';
					    echo '<td>' . $row['FILE_NAME'] . '</td>';
                        if($row['STATUS'] == "CREATED"){						  
                           echo '<td><font color="green"><b>' . $row['STATUS'] . '</b></font></td>';
                           ?>                              
                                 <td>
                                    <form name="menu" action="download_file.php" method="post">	
										<?php								   
									       echo '<input type="submit" name="fname" value="' . $row['FILE_NAME'] . '" />';
									    ?>
                                    </form>
                                 </td>                            
                           <?php
                        }
                        elseif($row['STATUS'] == "CREATING"){						  
                           echo '<td><div align="center"><font color="blue"><b>' . $row['STATUS'] . '</b></font></div></td>';
                           echo '<td><div align="center"><font color="gray"><b> - </b></font></div></td>';
                        }
                        else{
							echo '<td><div align="center"><b>' . $row['STATUS'] . '</b></div></td>';
							echo '<td><div align="center"><font color="gray"><b> - </b></font></div></td>';
							
						}				   
                        echo '</tr>';
                   }
                   mysqli_close($con);
		  		?>
            </table>              
         </frame2>
      </frame1>
   </body>
</html>
