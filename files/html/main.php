<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <link rel="shortcut icon" href="eme/img/icon/nokia_favicon.png"/>
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
   <title>Main</title>
   </head>
   <body>
      <?php
      include 'auth/authentication.php';
      function menu() { 
         log_write($_SESSION["user_id"], "Entered in Main page");
         echo "<frame1>"; 
         echo "<img src=\"eme/img/nokia_logo.png\" height=\"26\"><br><br>";
         echo "<frame2>";
         echo "<a class=\"link\" href=\"ne/index.php?op=ra\">Radio Access Information</a>";
		 echo "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp";
         echo "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp";
         #echo "<a class=\"link\" href=\"ne/index.php?op=paco\">Packet core Information</a>";
		 #echo "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp";
         echo "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp";
         echo "</frame2>";
         echo "<br><a href=\"logoff.php\"><img src=\"eme/img/icon/logoff.png\" title=\"Logoff\" height=\"36\"></a>";

         echo "</frame1>";
      }


      //Redirect if android or iphone:
      if(strstr($_SERVER['HTTP_USER_AGENT'], "Android") || 
         strstr($_SERVER['HTTP_USER_AGENT'], "iPhone") ||
         strstr($_SERVER['HTTP_USER_AGENT'], "iPad")
         ){
            echo "<meta http-equiv=\"refresh\" content=\"0; url=m/main.php\" />";
         return 0;
      }

      //Internet explorer not supported:
       if(strstr($_SERVER['HTTP_USER_AGENT'], "MSIE 7.0") || strstr($_SERVER['HTTP_USER_AGENT'], "MSIE 8.0")){
         echo "<h2>Internet explorer 7.0 and 8.0 not supported!</h2><br>Supported browsers:<br> - Internet Explorer 9.0<br> - Google Chrome<br> - Firefox<br>";
         return 0;
      }


      if (auth("main.php")) {
         $opt2 = $_GET['opt'];
         if($opt2 == "change_password"){
            session_destroy();
            echo "<META HTTP-EQUIV=\"Refresh\"CONTENT=\"0; URL=eme/change_password.php\">";
         }
         else {
            menu();
         }
      }
      ?>
   </body>
</html>
