<?php
	function auth(){
		return true;
	}
	
	function log_write(){
		return true;
	}
	function get_user_aut(){
		return 55;
	}
	
   function get_apacher_pw() {
      $APACHER_LOC = "/opt/nokia/nedata/users/.apacher";
      $fp = fopen($APACHER_LOC, "r");
      $apacher_p = fgets($fp);
      fclose($fp);
      $apacher_p = trim($apacher_p);
      return $apacher_p;
   }
   
   
   
	function get_db_data($opt){
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
		
		$ret = "foo";
		switch ($opt){
			case "user":
				$ret = $apache_db_user;
				break;
			
			case "pass":
				$ret = $apache_db_pw;
				break;
			
			case "db1":
				$ret = $db1_name;
				break;
		}
		return $ret;

	}
	
?>
