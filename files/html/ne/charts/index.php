<!doctype html>
<html>
   <head>
      <title>Radio access information</title>
      <script src="Chart.js"></script>
      <link rel="shortcut icon" href="../../eme/img/icon/nokia_favicon.png"/>
      <title>Element information</title>
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
         }
         td{
            background-color:#eee;
            color:#333;
            font-family: "Verdana", Times, serif;
            font-style: normal;
            font-size: 12px;
         }
         p{
            color:#aaa;
         }

         .link:hover{
            font-weight:bold;
         }

      </style>
   </head>
   <body>
      <?php
      include "../../auth/authentication.php";
      if (!auth("index.php")) {
         return 0;
      }

      $author = intval(get_user_aut($_SESSION["user_id"], $_SESSION["password"]) / 10);

      if ($author < 1) {          
          echo "<a href=\"" . $_SERVER['HTTP_REFERER'] . "\"><img src=\"../../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";
          echo "<frame1>";
          echo "<a href=\"../main.php\"><img src=\"../../eme/img/nokia_logo.png\" height=\"26\"></a>";
          echo "<h3><b>You have no access to this page!</b></h3>";
          exit;
      }


      $con = mysqli_connect(localhost, apacher, get_apacher_pw(), nsn);
      $opt = array("BSC",
         "BCF",
         "FlexiEdge",
         "FlexiMultiRadio",
         "Ultrasite",
         "MetroSite",
         "TRX",
         "RNC",
         "WBTS",
         "WCEL",
         "LTEBTS",
         "LNCEL",
         "FNS");

      $opt_label = array("2G - BSC",
         "2G - BCF",
         "2G - FlexiEdge",
         "2G - FlexiMultiRadio",
         "2G - Ultrasite",
         "2G - MetroSite",
         "2G - TRX",
         "3G - RNC",
         "3G - WBTS",
         "3G - WCEL",
         "4G - LTEBTS",
         "4G - LNCEL",
         "PACO - FNS");
      ?>
      
                 
      <?php
		$opta = $_GET['op'];
		echo "<a href=\"../index.php?op=" . $opta . "\"><img src=\"../../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";
	  ?>
      
      
      <frame1>
         <a href="../../main.php"><img src="../../eme/img/nokia_logo.png" height="26"></a>
      <frame2>
      <h2>Select the customer and the network element type:</h2>
		 <?php			
			echo "<form name=\"menu\" action=\"index.php?op=". $opta . "\" method=\"post\">";
		 ?>
            <select name="cust">
               <?php               
               $_cust = $_POST['cust'];
               $element = $_POST['el'];
               $result = mysqli_query($con, "SELECT * FROM cliente ");
               while ($row = mysqli_fetch_array($result)) {
                  $id = $row['id'];
                  $name = $row['name'];
                  echo $name;
                  if($id == $_cust)
                     echo "<option value=\"$id\" selected>$name</option>";
                  else
                     echo "<option value=\"$id\">$name</option>";
               }
               ?>
            </select>
            <select name="el"><br>
               <?php
               foreach ($opt as $i => $op) {
                  if($op == $element)
                     echo "<option value=\"$op\" selected>$opt_label[$i]</option>";
                  else
                     echo "<option value=\"$op\" >$opt_label[$i]</option>";
               }

               echo "</select>";
               echo "<input type=\"submit\" value=\"      OK      \">";
               echo "</form>";
               echo "</frame2>";


         if(!$_cust){
            return 0;
         }
         echo "<br><frame2>";
         $con = mysqli_connect(localhost, apacher, get_apacher_pw(), nsn);

      //CustName
      $query = "SELECT cliente.name AS cust FROM cliente WHERE cliente.id = $_cust";
      $result = mysqli_query($con, $query);
      while ($row = mysqli_fetch_array($result)) {
         $cust_name = $row['cust'];
      }
      ?>
      <?php echo "<h2>$cust_name - $element<h2>" ?>
      <div style="width:96%" Alignt="center">
         <div>
            <canvas id="graph" height="350" width="1400"></canvas>
         </div>
      </div>
      <?php
      $max_vals = 100;
      $query = "SELECT totalElements.CustomerId as Customer,
                   totalElements.DATE as DATE,
                   totalElements.Quantity AS TYPE_CNT
                   FROM totalElements WHERE totalElements.CustomerId = $_cust AND totalElements.Type LIKE '%$element%' ORDER BY totalElements.Date;";
      $result = mysqli_query($con, $query);
      $total = 0;
      $date1 = false;
      $date2 = false;
      //TotalTime:  
      while ($row = mysqli_fetch_array($result)) {
         if (!$date1) {
            $date1 = $row['DATE'];
         }
         $total++;
         $date2 = $row['DATE'];
      }
      $datetime1 = new DateTime($date1);
      $datetime2 = new DateTime($date2);
      $interval = $datetime1->diff($datetime2);
      $dif = $interval->format('%R%a');
      $step = $dif / $max_vals;

      //Date
      $result = mysqli_query($con, $query);
      $total = 0;

      $diff = $step + 1;
      $d1 = 0;
      $d2 = 0;
      while ($row = mysqli_fetch_array($result)) {

         if ($diff >= $step) {
            $dat[$total] = $row['DATE'];
            $total++;
            $d1 = $row['DATE'];
            $datetime1 = new DateTime($d1);
            $diff = 0;
         } else {
            $d2 = $row['DATE'];
            $datetime2 = new DateTime($d2);
            $interval = $datetime1->diff($datetime2);
            $diff = $interval->format('%R%a');
         }
      }

      $diff = 1000;
      $d1 = 0;
      $d2 = 0;
      $date = "labels : [";
      for ($i = 0; $i < $total; $i++) {
         $date = $date . "\"" . $dat[$i] . "\"" . ",";
      }
      $date = $date . "]";
      $date = str_replace(",]", "]", $date);

      //Value
      $result = mysqli_query($con, $query);
      $total = 0;
      while ($row = mysqli_fetch_array($result)) {
         $ams++;
         $sum += $row['TYPE_CNT'];
         if ($diff >= $step) {
            $val[$total] = $row['TYPE_CNT'];
            $total++;
            $d1 = $row['DATE'];
            $datetime1 = new DateTime($d1);
            $diff = 0;
         } else {
            $d2 = $row['DATE'];
            $datetime2 = new DateTime($d2);
            $interval = $datetime1->diff($datetime2);
            $diff = $interval->format('%R%a');
         }
      }
      mysqli_close($con);

     session_start("aut");
     $user = $_SESSION['user_id'];
     log_write($_SESSION["user_id"], "Selected the graph for $cust_name $element");


      $str = "data : [";
      for ($i = 0; $i < $total; $i++) {
         $str = $str . $val[$i] . ",";
      }
      $str = $str . "]";
      $str = str_replace(",]", "]", $str);

      echo '<script>
		         var lineChartData = {';
      echo "$date,\n";
      echo '
			         datasets : [
				         {
					         fillColor : "rgba(30,30,30,0.2)",
					         strokeColor : "rgba(20,20,255,1)",
					         pointColor : "rgba(20,20,255,1)",
					         pointStrokeColor : "#fff",
					         pointHighlightFill : "#fff",
					         pointHighlightStroke : "rgba(30,30,30,1)",';
      echo "	     $str\n";
      echo '
				         },
			         ]

		         }
	         window.onload = function(){
		         var ctx = document.getElementById("graph").getContext("2d");
		         window.myLine = new Chart(ctx).Line(lineChartData, {
			         responsive: true
		         });
	         }
	       </script>';
      ?>
      </frame2>
   </frame1>
   </body>
</html>
