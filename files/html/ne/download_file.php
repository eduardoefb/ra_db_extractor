<?php
   
   header("Content-Type: application/force-download");
   $fname = $_POST['fname'];
   $dire = str_replace(".xlsx", "", $filename);
   $filee = "/opt/nokia/nedata/xlsfiles/" . $fname;
   $fileLocation = $filee;
   header('Content-Length:' . filesize($fileLocation));
   header("Content-Disposition: inline; filename=\"$fname\"");
   $filePointer = fopen($fileLocation,"rb");
   if(fpassthru($filePointer))
      echo "Ok";
   else
      echo "Nok!";
   
?>

