<?php

   include '/var/www/htdocs/bsc_functions/print_functions/print_css.php';

   function troca_cor($color){
      if($color == "gray_dark"){
         $color = "gray_light";
      }
      else{
         $color = "gray_dark";
      }
      return $color;
   }

   


   function print_news($news_file, $header_file, $title){
      $fp = fopen($header_file, "r"); 
         $lhdr = fgets($fp);
      fclose($fp);
      $fp = fopen($news_file, "r");
      $lhdr = explode("\t", $lhdr);
     
      header_table($lhdr, $title);
      $bg_color = "gray_dark";

      $cnt = 0;
      while(!feof($fp)){
         $lin = fgets($fp);
         $lin = str_replace("\0", "", $lin);
         if(strstr($lin, "|\t")){
            $lin =  explode("|\t", $lin);
            $lin[0] = str_replace("\t\t", "", $lin[0]); # Remove tabs extras
            $lin[0] = str_replace("\t ", "", $lin[0]); # Remove tabs extras
            $s_lin = explode("\t", $lin[0]);
            $bg_color = troca_cor($bg_color);
            print_table($s_lin, "CHANGED(OLD)", $bg_color, $font_color);
            $s_lin = explode("\t", $lin[1]);
            print_table($s_lin, "CHANGED(NEW)", $bg_color, $font_color);
         }
         else if (strstr($lin, ">\t")){
            $lin =  explode(">\t", $lin);
            $lin[0] = str_replace("\t\t", "", $lin[0]); # Remove tabs extras
            $lin[0] = str_replace("\t ", "", $lin[0]); # Remove tabs extras
            $bg_color = troca_cor($bg_color);
            $s_lin = explode("\t", $lin[1]);
            print_table($s_lin, "ADDED", $bg_color, $font_color);
         }
         else if (strstr($lin, "<\n")){
            $lin =  explode(">\t", $lin);
            $lin[0] = str_replace("\t\t", "", $lin[0]); # Remove tabs extras
            $lin[0] = str_replace("\t ", "", $lin[0]); # Remove tabs extras
            $lin[0] = str_replace("<", "", $lin[0]); # Remove tabs extras
            $bg_color = troca_cor($bg_color);
            $s_lin = explode("\t", $lin[0]);
            print_table($s_lin, "REMOVED", $bg_color, $font_color);
         }



         
      }
      echo '   </thead>';
      echo '</div>';
      echo '</table>';
   }


   $date=date("Y-m-d H:i:s");
echo "<a href=\"../../../bsc_functions/main_bsc.php\"><-Back</a><br><br><br>";
      echo '<div id="spacer"></div>';
      echo "<div id=\"title\">File created on $date</div>";
      echo '<div><table border="0">';

   ini_html();
   #echo '<img src="http://www.yourecards.net/ecard_cardmedia/id139864/tattoo-art-gay-jesus-sticker-giant.jpeg" />';
   $bsc_news = "/var/bscdata/news/bsc_news.diff";
   $rnc_news = "/var/bscdata/news/rnc_news.diff";
   $bsc_header =  "/var/bscdata/news/bsc_new";
   $rnc_header =  "/var/bscdata/news/rnc_new";
   $bsc_lk_news = "/var/bscdata/news/bsc_lk_news.diff";
   $bsc_lk_header =  "/var/bscdata/news/bsc_lk_new";
   $rnc_lk_news = "/var/bscdata/news/rnc_lk_news.diff";
   $rnc_lk_header =  "/var/bscdata/news/rnc_lk_new";
   $wbts_news = "/var/bscdata/news/wbts_news.diff";
   $wbts_header =  "/var/bscdata/news/wbts_new";



   $bts_news = "/var/bscdata/news/bts_news.diff";
   $bts_header =  "/var/bscdata/news/bts_new";
   $u_bsc_news = "/var/bscdata/news/u_bsc_news.diff";
   $u_bsc_header =  "/var/bscdata/news/u_bsc_new";
   $u_rnc_news = "/var/bscdata/news/u_rnc_news.diff";
   $u_rnc_header =  "/var/bscdata/news/u_rnc_new";



   print_news($bsc_news, $bsc_header, "Changes on BSCs");
   print_news($u_bsc_news, $u_bsc_header, "Changes on BSC Units");   
   print_news($bsc_lk_news, $bsc_lk_header, "NEWs BSC License");
   print_news($bts_news, $bts_header, "Changes on BTSs");
   print_news($rnc_news, $rnc_header, "Changes on RNCs");
   print_news($rnc_lk_news, $rnc_lk_header, "NEWs RNC License");
   print_news($u_rnc_news, $u_rnc_header, "Changes on RNC Units");   
   print_news($wbts_news, $wbts_header, "NEWs RNC License");


?>

