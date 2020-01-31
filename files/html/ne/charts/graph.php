<!doctype html>
<html>
   <head>
      <title>Line Chart</title>
      <script src="Chart.js"></script>
      <link rel="shortcut icon" href="../../eme/img/icon/nokia_favicon.png"/>
      <title>Element information</title>
      <style>
         frame1 {
            display:block;
            padding:10px;
            border:3px solid #999;
            background-color: #ddd;
            margin:3px;
            font-family: "Verdana", Times, serif;
            font-style: normal;
            font-size: 12px;
         }

         frame2 {
            display:block;
            padding:10px;
            border:3px solid #aaa;
            background-color: #eee;
            margin:3px;
            font-family: "Verdana", Times, serif;
            font-style: normal;
         }


         frame3 {
            display:block;
            padding:10px;
            border:3px solid #aaa;
            background-color: #eee;
            margin:3px;
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
      include "../auth/authentication.php";
      if (!auth("index.php")) {
         return 0;
      }
      $cust = $_POST['cust'];
      $element = $_POST['el'];
      $con = mysqli_connect(localhost, apacher, get_apacher_pw(), nsn);

      //CustName
      $query = "SELECT cliente.name AS cust FROM cliente WHERE cliente.id = $cust";
      $result = mysqli_query($con, $query);
      while ($row = mysqli_fetch_array($result)) {
         $cust_name = $row['cust'];
      }
      echo "<a class=\"link\" href=\"index.php\"><img src=\"../../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";
      echo "<frame1>";
      echo "<img src=\"../../eme/img/nokia_logo.png\" height=\"26\"><br>";
      echo "<h2>$cust_name - $element<h2>";
      ?>

      <div style="width:96%" Alignt="center">
         <div>
            <canvas id="graph" height="350" width="1200"></canvas>
         </div>
      </div>
      <?php
      $max_vals = 100;
      $query = "SELECT totalElements.CustomerId as Customer,
                   totalElements.DATE as DATE,
                   totalElements.Quantity AS TYPE_CNT
                   FROM totalElements WHERE totalElements.CustomerId = $cust AND totalElements.Type LIKE '%$element%';";
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
      echo "$date,";
      echo '
			         datasets : [
				         {
					         fillColor : "rgba(30,30,30,0.2)",
					         strokeColor : "rgba(20,20,255,1)",
					         pointColor : "rgba(20,20,255,1)",
					         pointStrokeColor : "#fff",
					         pointHighlightFill : "#fff",
					         pointHighlightStroke : "rgba(30,30,30,1)",';
      echo "	     $str";
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
      </frame1>
   </body>
</html>
