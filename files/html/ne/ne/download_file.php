<?php
   
   header("Content-Type: application/force-download");
   $fname = $_POST['fname'];
   $filee = "/opt/nokia/nedata/xlsfiles/CLARO_CHILE/" . $fname;
   $fileLocation = $filee;
   header('Content-Length:' . filesize($fileLocation));
   header("Content-Disposition: inline; filename=\"$fname\"");
   $filePointer = fopen($fileLocation,"rb");
   if(fpassthru($filePointer))
      echo "Ok";
   else
      echo "Nok!";
   
?>

