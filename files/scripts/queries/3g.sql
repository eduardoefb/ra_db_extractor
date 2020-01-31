/*QUERY_NAME: RNC_DATA*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.rnc_id AS RNC_ID,
   (SELECT _xml_.RNC.dateTime FROM _xml_.RNC WHERE _xml_.RNC._RNC = _log_.rnc.rnc_id AND _log_.cliente.id = _xml_.RNC.customerId) AS DATE,
   _log_.rnc.name AS NAME,
   _log_.rnc.cnumber AS CNUMBER,
   _log_.rnc.ip AS IP, 
   (SELECT _xml_.RNC.OMSIpAddress FROM _xml_.RNC WHERE _xml_.RNC._RNC = _log_.rnc.rnc_id AND _log_.cliente.id = _xml_.RNC.customerId) AS OMS_IP_PRIM,
   (SELECT _xml_.RNC.OMSBackupIpAddress FROM _xml_.RNC WHERE _xml_.RNC._RNC = _log_.rnc.rnc_id AND _log_.cliente.id = _xml_.RNC.customerId) AS OMS_IP_SEC,
   (SELECT _xml_.RNC._version FROM _xml_.RNC WHERE _xml_.RNC._RNC = _log_.rnc.rnc_id AND _log_.cliente.id = _xml_.RNC.customerId) AS SWVER,
   _log_.rnc.cd AS CD,
   IFNULL(_log_.rnc.spc, "-") AS SPC,
   _log_.rnc.type AS TYPE,
   _log_.rnc.icsus AS ICSUS,
   (SELECT COUNT(_xml_.WBTS._WBTS) FROM _xml_.WBTS WHERE
      _xml_.WBTS._RNC = _log_.rnc.rnc_ID AND
      _xml_.WBTS.customerId = _log_.rnc.cliente_fk) AS WBTSs,
   (SELECT COUNT(_xml_.WCEL._WCEL) FROM _xml_.WCEL, _xml_.WBTS WHERE
      _xml_.WCEL._WBTS = _xml_.WBTS._WBTS AND
      _xml_.WCEL._RNC = _xml_.WBTS._RNC AND
      _xml_.WCEL.customerId = _xml_.WBTS.customerId AND
      _xml_.WBTS._RNC = _log_.rnc.rnc_id AND
      _xml_.WBTS.customerId = _log_.rnc.cliente_fk) AS WCELs,
   IFNULL((SELECT _log_.locations.location FROM _log_.locations WHERE
      _log_.rnc.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _log_.rnc.cliente_fk LIMIT 1), "-") AS LOCATION,
   IFNULL((SELECT _log_.locations.state FROM _log_.locations WHERE
      _log_.rnc.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _log_.rnc.cliente_fk LIMIT 1), "-") AS STATE 
      FROM _log_.rnc
      INNER JOIN _log_.cliente
         ON _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
         GROUP BY _log_.rnc.cnumber ORDER BY _log_.rnc.name;

/*QUERY_NAME: RNC_PRFILE*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.name AS RNC,
   _log_.rnc.cnumber AS TARGET_ID,
   _log_.rnc_prfile.parameter_class AS CLASS,
   _log_.rnc_prfile.parameter_name AS CLASS_NAME,
   _log_.rnc_prfile.identifier AS IDENTIFIER,
   _log_.rnc_prfile.name_of_parameter AS NAME_OF_PARAMETER,
   _log_.rnc_prfile.value AS VALUE,
   _log_.rnc_prfile.change_possibility AS CHANGE_POSSIBILITY 
   FROM _log_.rnc_prfile INNER JOIN _log_.rnc ON
   _log_.rnc_prfile.target_id = _log_.rnc.cnumber 
   INNER JOIN _log_.cliente ON
   _log_.rnc.cliente_fk = _log_.cliente.id
   AND _log_.cliente.id = _cid_ ;
   
/*QUERY_NAME: RNC_FIFILE*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.name AS RNC,
   _log_.rnc.cnumber AS TARGET_ID,
   _log_.rnc_fifile.parameter_class AS CLASS,
   _log_.rnc_fifile.parameter_name AS CLASS_NAME,
   _log_.rnc_fifile.identifier AS IDENTIFIER,
   _log_.rnc_fifile.name_of_parameter AS NAME_OF_PARAMETER,
   _log_.rnc_fifile.activation_status AS ACTIVATION_STATUS
   FROM _log_.rnc_fifile INNER JOIN _log_.rnc ON
   _log_.rnc_fifile.target_id = _log_.rnc.cnumber 
   INNER JOIN _log_.cliente ON
   _log_.rnc.cliente_fk = _log_.cliente.id
   AND _log_.cliente.id = _cid_ ;

/*QUERY_NAME: RNC_IUCS*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.name AS RNC,
   IFNULL(_log_.rnc.spc, "-") AS OPC,
   _xml_.IUCS.NetworkInd AS NETWORK,
   _xml_.IUCS.SignPointCode AS DPC,
   CASE _xml_.IUCS.CNDomainVersion
      WHEN 0 THEN '-'
      WHEN 1 THEN 'R99'
      WHEN 2 THEN 'Rel4'
      WHEN 3 THEN 'Rel5'
      WHEN 4 THEN 'Rel6'
      WHEN 5 THEN 'Rel7'
      WHEN 6 THEN 'Rel8'
      WHEN 7 THEN 'Rel9'
      WHEN 8 THEN 'Rel10'
      WHEN 9 THEN 'Rel11'
      WHEN 10 THEN 'Rel12'
      ELSE _xml_.IUCS.CNDomainVersion
   END as CNVer
   FROM _xml_.IUCS 
   INNER JOIN _log_.rnc ON     
     _log_.rnc.rnc_id = _xml_.IUCS._RNC AND _log_.rnc.cliente_fk = _xml_.IUCS.customerId
   INNER JOIN _log_.cliente ON
     _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_ ORDER BY _log_.rnc.name;
   
/*QUERY_NAME: RNC_IUPS*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.name AS RNC,
   IFNULL(_log_.rnc.spc, "-") AS OPC,
   _xml_.IUPS.NetworkInd AS NETWORK,
   _xml_.IUPS.SignPointCode AS DPC,
   CASE _xml_.IUPS.CNDomainVersion
      WHEN 0 THEN '-'
      WHEN 1 THEN 'R99'
      WHEN 2 THEN 'Rel4'
      WHEN 3 THEN 'Rel5'
      WHEN 4 THEN 'Rel6'
      WHEN 5 THEN 'Rel7'
      WHEN 6 THEN 'Rel8'
      WHEN 7 THEN 'Rel9'
      WHEN 8 THEN 'Rel10'
      WHEN 9 THEN 'Rel11'
      WHEN 10 THEN 'Rel12'
      ELSE _xml_.IUPS.CNDomainVersion
   END as CNVer
   FROM _xml_.IUPS 
   INNER JOIN _log_.rnc ON     
     _log_.rnc.rnc_id = _xml_.IUPS._RNC AND _log_.rnc.cliente_fk = _xml_.IUPS.customerId
   INNER JOIN _log_.cliente ON
     _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_ ORDER BY _log_.rnc.name;
 
/*QUERY_NAME: RNC_IUR*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.name AS RNC,
   IFNULL(_log_.rnc.spc, "-") AS OPC,
   _xml_.IUR.NRncNetworkInd AS NETWORK,
   _xml_.IUR.NRncSignPointCode AS DPC,
   _xml_.IUR.NRncId AS NRncId,
   CASE _xml_.IUR.NRncVersion
      WHEN 0 THEN '-'
      WHEN 1 THEN 'R99'
      WHEN 2 THEN 'Rel4'
      WHEN 3 THEN 'Rel5'
      WHEN 4 THEN 'Rel6'
      WHEN 5 THEN 'Rel7'
      WHEN 6 THEN 'Rel8'
      WHEN 7 THEN 'Rel9'
      WHEN 8 THEN 'Rel10'
      WHEN 9 THEN 'Rel11'
      WHEN 10 THEN 'Rel12'
      ELSE _xml_.IUR.NRncVersion
   END as NRNCVer
   FROM _xml_.IUR 
   INNER JOIN _log_.rnc ON
     _log_.rnc.rnc_id = _xml_.IUR._RNC and _xml_.IUR.customerId = _log_.rnc.cliente_fk
   INNER JOIN _log_.cliente ON
     _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_ ORDER BY _log_.rnc.name;
     
/*QUERY_NAME: RNC_License_Features*/
SELECT _log_.cliente.name AS CUSTOMER,
   (SELECT _xml_.RNC.dateTime FROM _xml_.RNC WHERE _xml_.RNC._RNC = _log_.rnc.rnc_id AND _log_.cliente.id = _xml_.RNC.customerId) AS DATE,
   _log_.rnc.name AS RNC,
   _log_.rnc.cnumber AS TARGET_ID,
   _log_.licence_rnc.fea_code AS 'FEATURE_CODE',
   REPLACE(_log_.licence_rnc.fea_name, ',', '/') AS 'FEATURE_NAME',
   _log_.rnc_to_licence.capacity AS CAPACITY ,
   _log_.rnc_to_licence.lk_usage AS 'USAGE' ,
   (SELECT COUNT(_log_.rnc_lk_file.filename) FROM _log_.rnc_lk_file WHERE _log_.rnc_lk_file.targetid = _log_.rnc.cnumber AND _log_.rnc.cnumber = TARGET_ID AND _log_.rnc_lk_file.fea_code = FEATURE_CODE) AS XML_FILES
   FROM
   _log_.cliente, _log_.rnc, _log_.rnc_to_licence, _log_.licence_rnc
   WHERE
   _log_.cliente.id = _log_.rnc.cliente_fk AND
   _log_.rnc.cnumber = _log_.rnc_to_licence.cnumber_fk AND
   _log_.licence_rnc.fea_code = _log_.rnc_to_licence.fea_code_fk AND
   _log_.cliente.id = _cid_
   ORDER BY _log_.rnc.name ;
   
/*QUERY_NAME: RNC_License_Files*/
SELECT (SELECT _xml_.RNC.dateTime FROM _xml_.RNC WHERE _xml_.RNC._RNC = _log_.rnc.rnc_id AND _log_.cliente.id = _xml_.RNC.customerId) AS DATE,
   _log_.cliente.name AS CUSTOMER,
   _log_.rnc.name AS RNC,
   _log_.rnc.cnumber AS CNUMBER,
   _log_.rnc_lk_file.filename AS FILENAME,
   _log_.rnc_lk_file.start_date AS START_DATE,
   _log_.rnc_lk_file.lfstate AS FEATURE_STATE,
   _log_.rnc_lk_file.orderid AS ORDER_ID,
   _log_.rnc_lk_file.customerid AS CUSTOMER_ID,
   _log_.rnc_lk_file.customername AS CUSTOMER_NAME,
   REPLACE(_log_.rnc_lk_file.licencename, ',', '/') AS LICENSE_NAME,
   _log_.rnc_lk_file.serialnumber AS SERIAL_NUMBER,
   ((SELECT COUNT(_log_.rnc_lk_file.serialnumber) FROM _log_.rnc_lk_file WHERE _log_.rnc_lk_file.serialnumber = SERIAL_NUMBER AND _log_.rnc_lk_file.targetid = _log_.rnc.cnumber) /
   (SELECT COUNT(_log_.rnc_lk_file.licencename) FROM _log_.rnc_lk_file WHERE _log_.rnc_lk_file.serialnumber = SERIAL_NUMBER AND _log_.rnc_lk_file.targetid = _log_.rnc.cnumber)) AS SERIAL_NUMBER_PER_NE, 
   _log_.rnc_lk_file.fea_code AS FEATURE_CODE,
   REPLACE(_log_.rnc_lk_file.featurename, ',', '/') AS FEATURE_NAME,
   _log_.rnc_lk_file.max_value AS CAPACITY FROM _log_.rnc, _log_.cliente, _log_.rnc_lk_file WHERE
   _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_ AND _log_.rnc.cnumber = _log_.rnc_lk_file.targetid ;
   

/*QUERY_NAME: WBTS_Data*/
SELECT _log_.cliente.name AS CUSTOMER, 
   _xml_.RNC.dateTime AS DATE, 
   _xml_.RNC.name AS RNC,   
   _xml_.WBTS._WBTS AS WBTS_ID,
   _xml_.WBTS.name AS WBTS_NAME,
   _xml_.WBTS.BTSIPAddress AS WBTS_IP,
   _xml_.WBTS.WBTSSWBuildId AS WBTS_SW,          
   (select COUNT(_xml_.RMOD.prodCode) FROM _xml_.RMOD WHERE
      _xml_.RMOD._WBTS = _xml_.WBTS._WBTS AND
      _xml_.RMOD._RNC = _xml_.RNC._RNC  LIMIT 1) AS RF_MODULES,
   (select COUNT(_xml_.SMOD.prodCode) FROM _xml_.SMOD WHERE
      _xml_.SMOD._WBTS = _xml_.WBTS._WBTS AND
      _xml_.SMOD._RNC = _xml_.RNC._RNC  LIMIT 1) AS SYSTEM_MODULES,      
   (SELECT COUNT(_xml_.SMOD.prodCode) FROM _xml_.SMOD WHERE
      _xml_.SMOD._WBTS = _xml_.WBTS._WBTS AND
      _xml_.SMOD._RNC = _xml_.RNC._RNC AND
      _xml_.SMOD.prodCode = '472181A' ) FSMF,
   (SELECT COUNT(_xml_.SMOD.prodCode) FROM _xml_.SMOD WHERE
      _xml_.SMOD._WBTS = _xml_.WBTS._WBTS AND
      _xml_.SMOD._RNC = _xml_.RNC._RNC AND
      _xml_.SMOD.prodCode = '471469A' ) FSME,
   (SELECT COUNT(_xml_.SMOD.prodCode) FROM _xml_.SMOD WHERE
      _xml_.SMOD._WBTS = _xml_.WBTS._WBTS AND
      _xml_.SMOD._RNC = _xml_.RNC._RNC AND
      _xml_.SMOD.prodCode = '470036A' ) FSMB,
   IFNULL((SELECT _xml_.SMOD.moduleLocation from _xml_.SMOD WHERE 
      _xml_.SMOD._WBTS = _xml_.WBTS._WBTS AND
      _xml_.SMOD._RNC = _xml_.RNC._RNC AND
      _xml_.SMOD.customerId = _xml_.RNC.customerId LIMIT 1), "-") AS LOCATION,   
   IFNULL((SELECT _log_.locations.state FROM _log_.locations WHERE
      _xml_.RNC.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _xml_.RNC.customerId LIMIT 1), "-") AS STATE
     FROM _xml_.WBTS
     INNER JOIN _xml_.RNC
        ON _xml_.RNC._RNC = _xml_.WBTS._RNC
     INNER JOIN _log_.cliente
        ON _xml_.RNC.customerId = _log_.cliente.id AND _log_.cliente.id = _cid_
     ORDER BY _xml_.RNC.name;
     
/*QUERY_NAME: WCEL_Data*/
SELECT (SELECT _xml_.RNC.name FROM _xml_.RNC, _xml_.WBTS WHERE
          _xml_.WCEL._WBTS = _xml_.WBTS._WBTS AND
          _xml_.WCEL._RNC = _xml_.WBTS._RNC AND
          _xml_.WCEL.customerId = _xml_.WBTS.customerId AND
          _xml_.WBTS._RNC = _xml_.RNC._RNC AND
          _xml_.WBTS.customerId = _xml_.RNC.customerId LIMIT 1 ) AS RNC,
       (SELECT _xml_.WBTS._WBTS FROM _xml_.WBTS WHERE
          _xml_.WCEL._WBTS = _xml_.WBTS._WBTS AND
          _xml_.WCEL._RNC = _xml_.WBTS._RNC AND
          _xml_.WCEL.customerId = _xml_.WBTS.customerId LIMIT 1 ) AS WBTS,
       (SELECT _xml_.WBTS.name FROM _xml_.WBTS WHERE
          _xml_.WCEL._WBTS = _xml_.WBTS._WBTS AND
          _xml_.WCEL._RNC = _xml_.WBTS._RNC AND
          _xml_.WCEL.customerId = _xml_.WBTS.customerId LIMIT 1 ) AS WBTS_NAME,
       _xml_.WCEL._WCEL AS WCEL_ID,
       _xml_.WCEL.name AS WCEL_NAME,
       _xml_.WCEL.WCELMCC AS MCC,
       _xml_.WCEL.WCELMNC AS MNC,
       _xml_.WCEL.LAC AS LAC,
       _xml_.WCEL.SAC AS SAC,
       _xml_.WCEL.PriScrCode AS SCC,
       _xml_.WCEL.UARFCN AS UARFCN,
       _xml_.WCEL.CellRange AS CELL_RANGE
FROM _xml_.WCEL WHERE
       _xml_.WCEL.customerId = _cid_ ;
     

/*QUERY_NAME: WBTS_Units*/
SELECT _xml_.SUBMODULE.dateTime AS DATE,
   (SELECT _xml_.RNC.name FROM _xml_.RNC WHERE
      _xml_.RNC.customerId = _xml_.SUBMODULE.customerID AND
      _xml_.RNC.file_uuid = _xml_.SUBMODULE.file_uuid AND
      _xml_.SUBMODULE.distName LIKE CONCAT(_xml_.RNC.distName, '%') LIMIT 1) AS RNC,
   (SELECT _xml_.RNC._RNC FROM _xml_.RNC WHERE
      _xml_.RNC.customerId = _xml_.SUBMODULE.customerID AND
      _xml_.RNC.file_uuid = _xml_.SUBMODULE.file_uuid AND
      _xml_.SUBMODULE.distName LIKE CONCAT(_xml_.RNC.distName, '%') LIMIT 1) AS RNC_ID,
   (SELECT _xml_.WBTS._WBTS FROM _xml_.WBTS WHERE
      _xml_.WBTS.customerId = _xml_.SUBMODULE.customerID AND
      _xml_.WBTS.file_uuid = _xml_.SUBMODULE.file_uuid AND
      _xml_.SUBMODULE.distName LIKE CONCAT(_xml_.WBTS.distName, '%') LIMIT 1) AS WBTS_ID,             
   (SELECT _xml_.WBTS.name FROM _xml_.WBTS WHERE
      _xml_.WBTS.customerId = _xml_.SUBMODULE.customerID AND
      _xml_.WBTS.file_uuid = _xml_.SUBMODULE.file_uuid AND
      _xml_.SUBMODULE.distName LIKE CONCAT(_xml_.WBTS.distName, '%') LIMIT 1) AS WBTS_NAME,   
   IF(_xml_.SUBMODULE.unitType LIKE 'CORE_%',      
      IFNULL(
         (SELECT _xml_.SMOD.prodCode FROM _xml_.SMOD WHERE 
            _xml_.SMOD.serNum = _xml_.SUBMODULE.serialNumber AND
            _xml_.SMOD.file_uuid = _xml_.SUBMODULE.file_uuid LIMIT 1),         
         (SELECT _xml_.RMOD.prodCode FROM _xml_.RMOD WHERE 
            _xml_.RMOD.serNum = _xml_.SUBMODULE.serialNumber AND
            _xml_.RMOD.file_uuid = _xml_.SUBMODULE.file_uuid LIMIT 1)), 
      IF(_xml_.SUBMODULE.identificationCode LIKE '%.%',
         LEFT(_xml_.SUBMODULE.identificationCode, LOCATE('.', _xml_.SUBMODULE.identificationCode) -1),
         _xml_.SUBMODULE.identificationCode)) AS PROD_CODE,   
   IFNULL((SELECT _log_.hardware.name FROM _log_.hardware WHERE
   PROD_CODE LIKE CONCAT(_log_.hardware.code, '%') LIMIT 1), _xml_.SUBMODULE.unitType) AS UNIT_TYPE,  
   IFNULL((SELECT _log_.hardware.description FROM _log_.hardware WHERE
   PROD_CODE LIKE CONCAT(_log_.hardware.code, '%') LIMIT 1), "-") AS UNIT_DESCRIPTION,         
   _xml_.SUBMODULE.serialNumber AS SERIAL   
FROM _xml_.SUBMODULE
   WHERE 
      _xml_.SUBMODULE._RNC <> "-" AND      
      _xml_.SUBMODULE.customerId = _cid_ ; 


/*QUERY_NAME: WBTS_NtpServers*/
SELECT _log_.cliente.name AS CUSTOMER,
   _xml_.RNC.dateTime AS DATE,
   _xml_.RNC.name AS RNC,
   _xml_.WBTS._WBTS AS WBTS_ID,
   _xml_.WBTS.name AS WBTS_NAME,
   _xml_.INTP_ntpServers._values AS NTP_SERVER 
FROM _log_.cliente, _xml_.RNC, _xml_.WBTS,  _xml_.INTP, _xml_.INTP_ntpServers 
WHERE
   _xml_.INTP_ntpServers.distName = _xml_.INTP.distName AND
   _xml_.INTP._WBTS = _xml_.WBTS._WBTS AND
   _xml_.INTP._RNC = _xml_.RNC._RNC AND
   _xml_.INTP.customerId = _log_.cliente.id AND
   _log_.cliente.id = _cid_ ;
   
/*QUERY_NAME: IPA_RNC_Units*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.date AS DATE,
   _log_.rnc.name AS NAME,
   _log_.rnc.cnumber AS CNUMBER,
   _log_.rnc.type AS RNC_TYPE,
   _log_.units_rnc.type AS UNIT,
   _log_.units_rnc.id AS ID,
   _log_.units_rnc.pluginunit AS PIU,
   (CASE units_rnc.memory
       WHEN -1 THEN '-'
       WHEN 0 THEN '-'
       ELSE _log_.units_rnc.memory
    END
   ) AS 'MEMORY(MB)',
   (CASE _log_.units_rnc.chms
       WHEN -1 THEN '-'
       ELSE _log_.units_rnc.chms
    END
   ) AS 'CHMS',
   (CASE _log_.units_rnc.shms
       WHEN -1 THEN '-'
       ELSE _log_.units_rnc.shms
    END
   ) AS 'SHMS',
   (CASE _log_.units_rnc.ppa
       WHEN -1 THEN '-'
       ELSE _log_.units_rnc.ppa
    END
   ) AS 'PPA',
   _log_.units_rnc.iti AS hwCode,
   _log_.units_rnc.sen AS serNum,
   _log_.units_rnc.state AS STATE
   FROM _log_.units_rnc
   JOIN _log_.rnc
      ON _log_.units_rnc.cnumber = rnc.cnumber
   JOIN _log_.cliente
      ON _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
   ORDER BY _log_.rnc.name;   

/*QUERY_NAME: mcRNC_Units*/
SELECT _log_.cliente.name AS CUSTOMER,
   _log_.rnc.date AS DATE,
   _log_.rnc.name AS NAME,
   _log_.rnc.cnumber AS CNUMBER,
   _log_.hw_mcrnc.unit_name AS UNIT,
   _log_.hw_mcrnc.unit_id AS ID,
   _log_.hw_mcrnc.chassis AS CHASSIS,
   _log_.hw_mcrnc.pos AS POSITION,
   _log_.hw_mcrnc.prod_manufacturer AS PROD_MANUFACTURER,
   _log_.hw_mcrnc.prod_name AS PROD_NAME,
   _log_.hw_mcrnc.prod_partnumber AS PROD_PART_NUMBER,
   _log_.hw_mcrnc.prod_version AS PROD_VERSION,
   _log_.hw_mcrnc.prod_serial AS PROD_SERIAL,
   _log_.hw_mcrnc.prod_fileid AS PROD_FILE_ID,
   _log_.hw_mcrnc.prod_custom AS PROD_CUSTOM_INFO,
   _log_.hw_mcrnc.board_mfg_date AS BOARD_MFG_DATE,
   _log_.hw_mcrnc.board_manufacturer AS BOARD_MANUFACTURER,
   _log_.hw_mcrnc.board_name AS BOARD_NAME,
   _log_.hw_mcrnc.board_serial AS BOARD_SERIAL,
   _log_.hw_mcrnc.board_part_number AS BOARD_PART_NUMBER
   FROM _log_.hw_mcrnc
   JOIN _log_.rnc
      ON _log_.hw_mcrnc.rnc_cnumber = _log_.rnc.cnumber
   JOIN _log_.cliente
      ON _log_.rnc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
   ORDER BY _log_.rnc.name;
