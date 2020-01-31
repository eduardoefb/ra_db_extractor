<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <title>Execution logs</title>      
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

         frame3 {
            display:block;
            padding:10px;
            border:1px solid #444;
            background-color: #aaa;
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
		  <a href="upload.php?op=ra"><img src="../eme/img/icon/back.png" title="Back" height="36"></a>
		  &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp  
		  <a href="logs.php"><img src="../eme/img/icon/refresh.png" title="Refresh" height="28"></a>
		  <frame1>
			 <a href="../main.php">
			     <img src="../eme/img/nokia_logo.png" height="26">
		     </a>
		     <br><br>
		     <frame2>
				 <h2>Execution log:</h2>
				 <frame3>
					 <?php
					    $log_file = " tail -30 /opt/nokia/nedata/scripts/update.log 2>&1";					    
					    #$fp = fopen($log_file, "r");
					    $fp = popen($log_file, 'r');
					    if($fp){
							while(!feof($fp)){
								$line = fgets($fp);
								echo $line . '<br>';
						    }
						    fclose($fp);
						}
					 ?>
				 </frame3>
		     </frame2>
		  </frame1>
		  &nbsp &nbsp 
		  
      </body> 
</html>
