<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <title>Download Menu</title>
        <link rel="shortcut icon" href="../eme/img/icon/nokia_favicon.png"/>
        <style>
            frame1 {
                display:block;
                padding:10px;
                border:2px solid #999;
                background-color: #ddd;
                margin:2px;
                font-family: "Verdana", Times, serif;
                font-style: normal;
                font-size: 12px;
            }

            frame2 {
                display:block;
                padding:10px;
                border:1px solid #aaa;
                background-color: #eee;
                margin:1px;
                font-family: "Verdana", Times, serif;
                font-style: normal;
            }


            frame3 {
                display:block;
                padding:10px;
                border:1px solid #aaa;
                background-color: #eee;
                margin:1px;
                font-family: "Verdana", Times, serif;
                font-style: normal;
                font-size: 12px;
            }


            .link:hover span{
                font-weight:bold;
                text-decoration:underline;
            }

            .link:hover{
                font-weight:bold;
            }


            <style type="text/css">
            table{
                border-collapse:collapse;
            }

            table, td, th{
                border:1px solid green;
            }

            th{
                background-color:green;
                color:white;
            }

            td{
                background-color:white;
                color: #ddd;
                font-family: "Verdana", Times, serif;
                font-style: normal;
                font-size: 12px;
            }

            p{
                color:gray;
            }
        </style>

    </style>
   </head>
   <body>
      <?php 
         include "../auth/authentication.php";
      ?>

      <?php   if(auth("download_menu.php")): ?>

      <?php 
        $author = intval(get_user_aut($_SESSION["user_id"], $_SESSION["password"]) / 10);
        if ($author < 1) {
			echo "<a href=\"" . $_SERVER['HTTP_REFERER'] . "\"><img src=\"../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";			            
            echo "<frame1>";
            echo "<a href=\"../main.php\"><img src=\"../eme/img/nokia_logo.png\" height=\"26\"></a>";
            echo "<h3><b>You have no access to this page!</b></h3>";
            exit;
         }
         ?>


            <?php log_write($_SESSION["user_id"], "Entered in download menu $fname"); ?>
            
            <?php
				echo "<a href=\"" . $_SERVER['HTTP_REFERER'] . "\"><img src=\"../../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";
            ?>
            
            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
                        
            <frame1>      
            <img src="../../eme/img/nokia_logo.png" height="26"><br>
            <h2>Download selection:</h2>
            <form name="menu" action="download.php" method="post">
               <select name="fname">
               <?php 
                  $file_list = scandir("/opt/nokia/nedata/xlsfiles/");
                  foreach($file_list as $fname){
                     if($fname != "." && $fname != ".." && strstr($fname, ".zip")){
                        echo "<option value=\"$fname\">$fname</option>";
                     }
                  }
               ?>
               </select>
            <input type="submit" value="       OK       ">
         </form>
      </frame1>
      <?php endif ?>
   </body>
</html>
