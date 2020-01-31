<?php
   include "../auth/authentication.php";
   $fname = $_POST['fname'];
   if(auth("download_menu.php")){
      header("Content-Type: application/force-download");
      $filee = "/opt/nokia/nedata/xlsfiles/$fname";
      $fileLocation = $filee;
      header('Content-Length:' . filesize($fileLocation));
      header("Content-Disposition: inline; filename=\"$fname\"");
      $filePointer = fopen($fileLocation,"rb");
      if(fpassthru($filePointer))
         log_write($_SESSION["user_id"], "Downloaded $fname");
      else
         log_write($_SESSION["user_id"], "Error $fname download attempt");
   }
?>

