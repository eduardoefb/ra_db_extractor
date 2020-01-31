<!doctype html>
<html itemscope="" itemtype="http://schema.org/WebPage" lang="en-US">
    <head>        
        <link rel="shortcut icon" href="../eme/img/icon/nokia_favicon.png"/>
        <title>Element Information</title>
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
      //Internet explorer not supported:
    if(strstr($_SERVER['HTTP_USER_AGENT'], "MSIE 7.0") || strstr($_SERVER['HTTP_USER_AGENT'], "MSIE 8.0")){
      echo "<h2>Internet explorer 7.0 and 8.0 not supported!</h2><br>Supported browsers:<br> - Internet Explorer 9.0<br> - Google Chrome<br> - Firefox<br>";
      return 0;
    }

    include "../auth/authentication.php";

	$conf_file = "/opt/nokia/nedata/scripts/var.conf";
		
	if ($fp = fopen($conf_file, "r")){
		while (!feof($fp)){
			$l = fgets($fp);
			if(strstr($l, "export WORK_DIR")){				
				sscanf($l,"export WORK_DIR=%s",$work_dir);
				$work_dir = trim($work_dir);
			}
			elseif(strstr($l, "export CF_FILES_DIR")){				
				sscanf($l, "export CF_FILES_DIR=%s", $cf_files_dir);
				$cf_files_dir = str_replace("\"", "", str_replace("\$WORK_DIR", $work_dir, $cf_files_dir));
			}
			elseif(strstr($l, "export DB_CONFIG_FILE")){							
				sscanf($l, "export DB_CONFIG_FILE=%s", $db_file_config);								
				$db_file_config = str_replace("\"", "", str_replace("\$CF_FILES_DIR", $cf_files_dir, $db_file_config));				
			}
				
			elseif(strstr($l, "export DB1_NAME=")){
				sscanf($l, "export DB1_NAME=%s", $db1_name);
				$db1_name = str_replace("\"", "", $db1_name);				
			}			
			elseif(strstr($l, "export DB2_NAME=")){
				sscanf($l, "export DB2_NAME=%s", $db2_name);
				$db2_name = str_replace("\"", "", $db2_name);				
			}						
		}		
	}	
	fclose($fp);
	
	#Get apache user and password:
	if ($fp = fopen($db_file_config, "r")){
		while (!feof($fp)){	
			$l = fgets($fp);		
			if(strstr($l, "mysql_user =")){
				sscanf($l, "mysql_user = %s", $apache_db_user);
				$apache_db_user = trim($apache_db_user);
			}
			elseif(strstr($l, "mysql_user_pw =")){
				sscanf($l, "mysql_user_pw = %s", $apache_db_pw);
				$apache_db_pw = trim($apache_db_pw);
			}
		}
	}
	fclose($fp);

    if (auth("index.php")) {
        //session_start('aut');
        $author = intval(get_user_aut($_SESSION["user_id"], $_SESSION["password"]) / 10);              
        if ($author < 1) {		
            echo '<a href="../main.php"><img src="../eme/img/icon/home.png" title="Home" height="36"></a>
            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
            <a href="charts/index.php"><img src="../eme/img/icon/graph.png" title="Average network growth" height="36"></a>
            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
            <a href="download_menu.php"><img src="../eme/img/icon/xlsx.png" title="Download complete information" height="36"></a>
            &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp            
            <frame1>
            <a href="../main.php"><img src="../eme/img/nokia_logo.png" height="26"></a>
            <h3><b>You are not authorized to access this page!</b></h3>';
            exit;
        }
        $con = mysqli_connect(localhost, $apache_db_user, $apache_db_pw, $db1_name);
        if (mysqli_connect_errno($con)) {
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
            return 0;
        }
        $op = $_GET['op'];               
        echo '<a href="../main.php"><img src="../eme/img/icon/home.png" title="Home" height="36"></a>
		&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
        <a href="charts/index.php?op= ' .$op. '"><img src="../eme/img/icon/graph.png" title="Average network growth" height="36"></a>
        &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
        <a href="download_menu.php"><img src="../eme/img/icon/xlsx.png" title="Download complete information" height="36"></a>
        &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
        <frame1>
        <a href="../main.php"><img src="../eme/img/nokia_logo.png" height="26"></a>';
        if($op == "ra")
			echo "<h2>Radio access information:</h2>";			
		else
			echo "<h2>Packet core information:</h2>";
        echo "<br>";
        echo "<frame2>";
        session_start("aut");
        $user = $_SESSION['user_id'];
        log_write($_SESSION["user_id"], "Entered in Radio access information main page");
        echo "<b>Available options:</b><br><br>";
        echo 'Select the customer:';
        echo '<form name="sel_dir" action=list.php method="get"><select name="cust">';
        $result = mysqli_query($con, "SELECT * FROM cliente ");
        while ($row = mysqli_fetch_array($result)) {
            $id = $row['id'];
            $name = $row['name'];
            echo $name;
            echo "<option ; value=\"$id\">$name</option>";
        }

				
        echo "</select>";
        if($op == "ra"){        
			echo '<br><br><a class="link"><input type="radio" name="opt" value="data_bsc" checked>2G (BSC) -> Basic Information<br>
			<a class="link"><input type="radio" name="opt" value="data_rnc">3G (RNC) -> Basic Information</a><br>
			<a class="link"><input type="radio" name="opt" value="datamrbts" >4G (ENB) -> Basic Information</a><br>
			<a class="link"><input type="radio" name="opt" value="create_csv">HIT and TANG configuration files</a><br>
			<a class="link"><input type="radio" name="opt" value="find_bts">Find BTS/WBTS/ENODEB --> </a>
			<a class="link"><input type="text" name="bts"></a><br><br>';
		}
		else if($op == "paco"){
			echo '<br><br><a class="link"><input type="radio" name="opt" value="data_fns" checked>(FNS) -> Basic Information</a><br>			
			<a class="link"><input type="radio" name="opt" value="create_csv">HIT and TANG configuration files</a><br><br>';
		}
		else{
			echo '<META http-equiv="refresh" content="0;URL=../main.php">';
		}
        echo '</br>        
        <input type="submit" value="       OK       ">
        </form>
        <br>
        </frame2>';

        if ($author >= 4) {
            echo '<br><br>
            <frame2>
            <br>Manage log files::
            
            <br><a href=upload.php><img src=../eme/img/icon/upload.png title=Help file height=56></a>
            <br><br>Obs.: The log files are created by python script and macro:
            <br><br><a class=link href=https://www.dropbox.com/sh/e092srxwlibgks5/AACp2k0Ce5HWU3lE33h6SekBa?dl=0 target=_blank>Scripts and macros</a><br>
            <br><a href=scripts/get_howto.pdf target=_blank><img src=../eme/img/icon/help.png title=Help file height=26></a>
            </frame2>';
        }
        echo '</frame1>';
        mysqli_close($con);
    }
    ?>
</body>
</html>
