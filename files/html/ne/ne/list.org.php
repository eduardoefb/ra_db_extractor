<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
   <head>
      <link rel="shortcut icon" href="../eme/img/icon/nokia_favicon.png"/>
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
   include "../auth/authentication.php";
   include "print_functions/print.php";

   function find_bts($cust, $bts_name) {
      $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));

      if (mysqli_connect_errno($con)) {
         echo "Failed to connect to MySQL: " . mysqli_connect_error();
         return 0;
      }

      $query = "SELECT cliente.name AS CUSTOMER, bsc.name AS BSC, bcf.bcf_id AS BCF, bcf.bcf_type AS BCF_TYPE, bcf.sw_ver AS SW, bcf.bcf_name AS BCF_NAME, bts.bts_id AS BTS, bts.bts_name AS BTS_NAME,
   bts.lac AS LAC, bts.ci AS CI, trx.trx_id AS TRX, trx.trx_mbcch AS MBCCH, trx.freq AS FREQ, trx.trx_edge_supported AS EDGE, bsc.state AS STATE
   FROM trx
    INNER JOIN bts 
     ON trx.bts_ident_fk = bts.bts_ident
    INNER JOIN bcf
     ON bts.bcf_ident_fk = bcf.bcf_ident
    INNER JOIN bsc
     ON bcf.bsc_cnumber = bsc.cnumber
    INNER JOIN cliente
     ON bsc.cliente_fk = cliente.id AND cliente.id = $cust AND bts.bts_name LIKE '%$bts_name%';";

      $fname = print_gen($con, $cust, 1, $query, "Label: 2G Network:", 1);

      $query = "SELECT cliente.name AS CUSTOMER, rnc.date AS DATE, rnc.name AS RNC, wbts.wbts_id AS WBTS_ID, wbts.wbts_name AS WBTS_NAME, wbts.wbts_ip AS WBTS_IP, wbts.wbts_trm AS TRM, 
   wbts.wbts_type AS WBTS_TYPE, wbts.wbts_sw AS SW, wcel.wcel_id AS WCEL_ID, wcel.cell_id AS CELL_ID, wcel.lac AS LAC, wcel.sac AS SAC, wcel.rac AS RAC, wcel.freq AS FREQ,
   wcel.dl_scc AS SCC, wcel.cell_range AS CELL_RANGE, rnc.state AS STATE
   
    FROM wcel 
    INNER JOIN wbts 
     ON wcel.wbts_ident_fk =  wbts.wbts_ident
    INNER JOIN rnc 
     ON wbts.rnc_cnumber = rnc.cnumber
    INNER JOIN cliente
     ON rnc.cliente_fk = cliente.id AND cliente.id = $cust AND wbts.wbts_name LIKE '%$bts_name%';";

      $fname = print_gen($con, $cust, 1, $query, "Label: 3G Network:", 0);


      $query = "SELECT cliente.name AS CUSTOMER, 
      mrbts.Date AS DATE, 
      mrbts.Id AS MRBTS_ID,
      lnbts.Id AS LNBTS_ID,
      lnbts.Name AS LNBTS_NAME,
      lnbts.SwVersion AS SW_VERSION,
      (SELECT ipno.mPlaneIpAddress FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS OEM_IP,
      (SELECT ipno.cPlaneIpAddress FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS CPLANE_IP,
      (SELECT ipno.uPlaneIpAddress FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS UPLANE_IP,
      (SELECT ipno.oamIpAddr FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS OMS_IP_MAIN,
      (SELECT ipno.secOmsIpAddr FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS OMS_IP_SEC,
      lncel.Id AS LNCEL_ID,
      lncel.Name AS LNCEL_NAME,
      lncel.Mcc AS MCC,
      lncel.Mnc AS MNC,
      lncel.Tac AS TAC,
      lncel.pMax AS PMAX,
      lncel.eutraCelId AS EUTRACELL_ID
     FROM lncel
      INNER JOIN lnbts ON
       lncel.LnBtsInd = lnbts.Ind
      INNER JOIN mrbts ON
       lnbts.MrBtsInd = mrbts.Ind
      INNER JOIN cliente ON
       mrbts.CustomerId = cliente.id 
       AND cliente.id = '$cust'  AND lncel.Name LIKE '%$bts_name%'";


      $fname = print_gen($con, $cust, 1, $query, "Label: 4G Network:", 0);

      mysqli_close($con);
   }

   function show_bsc_data($cust, $html) {
      $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));
      if (mysqli_connect_errno($con)) {
         echo "Failed to connect to MySQL: " . mysqli_connect_error();
         return 0;
      }

      $query = "SELECT cliente.name AS CUSTOMER, 
         bsc.date AS DATE, 
         bsc.name AS NAME, 
         bsc.cnumber AS CNUMBER, 
         bsc.capacity AS CAPACITY, 
         bsc.ip AS IP, 
         bsc.swver AS SWVER, 
         bsc.cd AS CD, 
         bsc.type AS TYPE,
         bsc.prfile_ver AS PRFILE, 
         bsc.fifile_ver AS FIFILE, 
         (
          SELECT COUNT(trx.trx_id) FROM trx, bts, bcf WHERE
          trx.bts_ident_fk = bts.bts_ident AND
          bts.bcf_ident_fk = bcf.bcf_ident AND
          bcf.bsc_cnumber = bsc.cnumber
         ) AS TRX,
         bsc.location AS LOCATION, 
         bsc.state AS STATE
       FROM bcf
       RIGHT JOIN bsc
         ON bcf.bsc_cnumber = bsc.cnumber
       INNER JOIN cliente 
         ON bsc.cliente_fk = cliente.id AND cliente.id = '$cust'
       GROUP BY(bsc.name)ORDER BY bsc.name;";

      $fname = print_gen($con, $cust, $html, $query, "2G_bsc_data", 1);
      mysqli_close($con);
      return $fname;
   }


   function show_fns_data($cust, $html) {
      $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));
      if (mysqli_connect_errno($con)) {
         echo "Failed to connect to MySQL: " . mysqli_connect_error();
         return 0;
      }

      $query = "SELECT cliente.name AS CUSTOMER, 
         fns.date AS DATE, 
         fns.name AS NAME, 
         fns.cnumber AS CNUMBER,          
         fns.ip AS IP, 
         fns.swver AS SWVER,          
         fns.type AS TYPE,
         fns.location AS LOCATION, 
         fns.state AS STATE
       FROM fns
       INNER JOIN cliente 
         ON fns.customer_fk = cliente.id AND cliente.id = '$cust'
       GROUP BY(fns.name)ORDER BY fns.name;";

      $fname = print_gen($con, $cust, $html, $query, "FNS_data", 1);
      mysqli_close($con);
      return $fname;
   }


   function show_mrbts_data($cust, $html) {
      $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));
      if (mysqli_connect_errno($con)) {
         echo "Failed to connect to MySQL: " . mysqli_connect_error();
         return 0;
      }

      $query = "SELECT cliente.name AS CUSTOMER, 
      mrbts.Date AS DATE, 
      mrbts.Id AS MRBTS_ID,
      lnbts.Id AS LNBTS_ID,
      lnbts.Name AS LNBTS_NAME,
      lnbts.SwVersion AS SW_VERSION,
      (SELECT ipno.mPlaneIpAddress FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS OEM_IP,
      (SELECT ipno.cPlaneIpAddress FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS CPLANE_IP,
      (SELECT ipno.uPlaneIpAddress FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS UPLANE_IP,
      (SELECT ipno.oamIpAddr FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS OMS_IP_MAIN,
      (SELECT ipno.secOmsIpAddr FROM ftm, ipno WHERE ftm.LnBtsInd = lnbts.Ind AND ipno.FtmInd = ftm.ind ) AS OMS_IP_SEC,
      lncel.Id AS LNCEL_ID,
      lncel.Name AS LNCEL_NAME,
      lncel.Mcc AS MCC,
      lncel.Mnc AS MNC,
      lncel.Tac AS TAC,
      lncel.pMax AS PMAX,
      lncel.eutraCelId AS EUTRACELL_ID
     FROM lncel
      INNER JOIN lnbts ON
       lncel.LnBtsInd = lnbts.Ind
      INNER JOIN mrbts ON
       lnbts.MrBtsInd = mrbts.Ind
      INNER JOIN cliente ON
       mrbts.CustomerId = cliente.id 
       AND cliente.id = '$cust'";

      $fname = print_gen($con, $cust, $html, $query, "4G_mrbts_data", 1);
      mysqli_close($con);
      return $fname;
   }

   function show_rnc_data($cust, $html) {
      $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));

      if (mysqli_connect_errno($con)) {
         echo "Failed to connect to MySQL: " . mysqli_connect_error();
         return 0;
      }

      $query = "SELECT cliente.name AS CUSTOMER, 
       rnc.rnc_id AS RNC_ID, 
       rnc.date AS DATE, 
       rnc.name AS NAME, 
       rnc.cnumber AS CNUMBER, 
       rnc.ip AS IP, rnc.oms_ip AS OMS_IP, 
       rnc.swver AS SWVER, 
       rnc.cd AS CD, 
       rnc.type AS TYPE, 
       rnc.icsus AS ICSUS, 
       (SELECT COUNT(wbts.wbts_id) FROM wbts WHERE wbts.rnc_cnumber = rnc.cnumber) AS WBTSs,
       (SELECT COUNT(wcel.wcel_id) FROM wcel, wbts WHERE wcel.wbts_ident_fk = wbts.wbts_ident AND wbts.rnc_cnumber = rnc.cnumber) AS WCELs,
       rnc.location AS LOCATION, 
       rnc.state AS STATE
         FROM rnc 
         INNER JOIN cliente
         ON rnc.cliente_fk = cliente.id AND cliente.id = $cust
         GROUP BY rnc.cnumber ORDER BY rnc.name;";

      $fname = print_gen($con, $cust, $html, $query, "3G_rnc_data", 1);
      mysqli_close($con);
      return $fname;
   }

   function create_csv($cust) {      
      echo "<a href=\"" . $_SERVER['HTTP_REFERER'] . "\"><img src=\"../../eme/img/icon/back.png\" title=\"Back\" height=\"26\"></a>";			            
      echo "<frame1>";      
      echo "<a href=\"../main.php\"><img src=\"../eme/img/nokia_logo.png\" height=\"26\"></a>";
      echo "<h2>HIT and TANG configuration files:</h2>";
      $con = mysqli_connect(localhost, get_db_data("user"), get_db_data("pass"), get_db_data("db1"));
      if (mysqli_connect_errno($con)) {
         echo "Failed to connect to MySQL: " . mysqli_connect_error();
         return 0;
      }

      $files[1] = hit2_file($con, $cust, 0);
      $files[2] = hit3_file($con, $cust, 0);
      $files[3] = tang_file($con, $cust, 0);


      #Create INI Files:
      $custname = get_customer($con, $cust);
      mysqli_close($con);

      #Zip the files:
      $zip = new ZipArchive();
      //$zip_name = sprintf("%d_data.zip", mt_rand(0, 100000));

      $zip_name = sprintf("csv_files/%s_data.zip", $custname);
      if (!file_exists($zip_name)) {
         if ($zip->open($zip_name, ZIPARCHIVE::CREATE) !== TRUE) {
            $error .= "* Sorry ZIP creation failed at this time";
         }

         foreach ($files as $file) {
            $zip->addFile($file);
         }
         $zip->close();
      }
      echo "<a class=\"link\" href=\"$zip_name\">Download file: $zip_name (All above file included)<br></a>";
      echo "</h3>";
   }

################################################################################:
   if (auth("index.php")) {
      $customer_id = $_GET['cust'];
      $option = $_GET['opt'];
      $bts_name = $_GET['bts'];
      if (!$customer_id)
         return 0;

      switch ($option) {
         case "data_fns":
            log_write($_SESSION["user_id"], "Checked FNS Data on the CustomerId: $customer_id");
            show_fns_data($customer_id, 1);
            break;		  
         case "data_bsc":
            log_write($_SESSION["user_id"], "Checked BSC Data on the CustomerId: $customer_id");
            show_bsc_data($customer_id, 1);
            break;
         case "data_rnc":
            log_write($_SESSION["user_id"], "Checked RNC Data on the CustomerId: $customer_id");
            show_rnc_data($customer_id, 1);
            break;
         case "datamrbts" :
            log_write($_SESSION["user_id"], "Checked LTE MRBTS Data on the CustomerId: $customer_id");
            show_mrbts_data($customer_id, 1);
            break;
         case "create_csv" :
            log_write($_SESSION["user_id"], "Created HIT/TANG configuration files on the CustomerId: $customer_id");
            create_csv($customer_id, 1);
            break;
         case "find_bts":
            log_write($_SESSION["user_id"], "Searched for \"$bts_name\" on the CustomerId: $customer_id");
            if (strlen($bts_name) > 0) {
               find_bts($customer_id, $bts_name);
            } else {
               echo "You must enter the bts name!!";
               return 0;
            }
            break;

         default:
            echo "Option $option not yet implemented!";
            break;
      }
   }
   ?>
</body>
</html>
