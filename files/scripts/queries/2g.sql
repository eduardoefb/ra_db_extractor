/*QUERY_NAME: BSC_DATA*/
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.date AS DATE,
_log_.bsc.name AS NAME,
_log_.bsc.cnumber AS CNUMBER,
_log_.bsc.capacity AS CAPACITY,
_log_.bsc.ip AS IP,
CASE SUBSTRING(_log_.bsc.cd, 1, 3)   
   WHEN 'SF0' THEN 'S15'
   WHEN 'SG0' THEN 'S16'
   WHEN 'SG1' THEN 'S16.1'
   WHEN 'SG2' THEN 'S16.2'   
   WHEN 'SG3' THEN 'GSM16'
   WHEN 'SG4' THEN 'GSM17'
   WHEN 'SG5' THEN 'GSM18' 
   WHEN 'SG6' THEN 'GSM19'
   ELSE '-' 
   END AS SWVER,
_log_.bsc.cd AS CD,
IFNULL(_log_.bsc.spc, "-") AS SPC,
_log_.bsc.q3version AS Q3_VERSION,
_log_.bsc.type AS TYPE,
_log_.bsc.prfile_ver AS PRFILE,
_log_.bsc.fifile_ver AS FIFILE,
(select COUNT(_log_.bcf.bcf_id) FROM _log_.bcf WHERE _log_.bcf.parent_uuid = _log_.bsc.uuid AND _log_.bcf.bcf_type = 'ULTRASITE' ) AS 'ULTRASITE',
(select COUNT(_log_.bcf.bcf_id) FROM _log_.bcf WHERE _log_.bcf.parent_uuid = _log_.bsc.uuid AND _log_.bcf.bcf_type = 'METROSITE' ) AS 'METROSITE',
(select COUNT(_log_.bcf.bcf_id) FROM _log_.bcf WHERE _log_.bcf.parent_uuid = _log_.bsc.uuid AND _log_.bcf.bcf_type = 'FLEXI EDGE' ) AS 'FLEXI-EDGE',
(select COUNT(_log_.bcf.bcf_id) FROM _log_.bcf WHERE _log_.bcf.parent_uuid = _log_.bsc.uuid AND _log_.bcf.bcf_type = 'FLEXI MULTI' ) AS 'FLEXI-MULTIRADIO',
(select COUNT(_log_.bcf.bcf_id) FROM _log_.bcf WHERE _log_.bcf.parent_uuid = _log_.bsc.uuid AND _log_.bcf.bcf_type LIKE '%BTSPLUS%' ) AS 'BTS-PLUS',
(SELECT COUNT(_log_.trx.trx_id) FROM _log_.trx, _log_.bts, _log_.bcf WHERE _log_.trx.parent_uuid = _log_.bts.uuid AND _log_.bts.parent_uuid = _log_.bcf.uuid AND _log_.bcf.parent_uuid = _log_.bsc.uuid ) AS TRX,
(SELECT COUNT(_log_.units_bsc.cnumber) FROM _log_.units_bsc WHERE _log_.units_bsc.parent_uuid = _log_.bsc.uuid AND _log_.units_bsc.type = 'TCSM' AND _log_.units_bsc.main_piu LIKE 'TRC%' AND _log_.units_bsc.state <> 'SE-NH' ) AS TCSM2,
(SELECT COUNT(_log_.units_bsc.cnumber) FROM _log_.units_bsc WHERE _log_.units_bsc.parent_uuid = _log_.bsc.uuid AND _log_.units_bsc.type = 'TCSM' AND _log_.units_bsc.main_piu LIKE 'TR3%' AND _log_.units_bsc.state <> 'SE-NH' ) AS TCSM3i,
_log_.bsc.location AS LOCATION,
IFNULL((SELECT _log_.locations.state FROM _log_.locations WHERE
      _log_.bsc.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _log_.bsc.cliente_fk LIMIT 1), "-") AS STATE      
FROM _log_.bcf
RIGHT JOIN _log_.bsc
   ON _log_.bcf.parent_uuid = _log_.bsc.uuid
INNER JOIN _log_.cliente
   ON _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
GROUP BY(_log_.bsc.name)ORDER BY _log_.bsc.name ;


/*QUERY_NAME: BSC_PRFILE*/
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.name AS BSC,
_log_.bsc.cnumber AS TARGET_ID,
_log_.bsc_prfile.parameter_class AS CLASS,
_log_.bsc_prfile.parameter_name AS CLASS_NAME,
_log_.bsc_prfile.identifier AS IDENTIFIER,
_log_.bsc_prfile.name_of_parameter AS NAME_OF_PARAMETER,
_log_.bsc_prfile.value AS VALUE,
_log_.bsc_prfile.change_possibility AS CHANGE_POSSIBILITY 
FROM _log_.bsc_prfile INNER JOIN _log_.bsc ON
_log_.bsc_prfile.parent_uuid = _log_.bsc.uuid 
INNER JOIN _log_.cliente ON
_log_.bsc.cliente_fk = _log_.cliente.id
AND _log_.cliente.id = _cid_ ;

/*QUERY_NAME: BSC_FIFILE*/
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.name AS BSC,
_log_.bsc.cnumber AS TARGET_ID,
_log_.bsc_fifile.parameter_class AS CLASS,
_log_.bsc_fifile.parameter_name AS CLASS_NAME,
_log_.bsc_fifile.identifier AS IDENTIFIER,
_log_.bsc_fifile.name_of_parameter AS NAME_OF_PARAMETER,
_log_.bsc_fifile.activation_status AS ACTIVATION_STATUS
FROM _log_.bsc_fifile INNER JOIN _log_.bsc ON
_log_.bsc_fifile.parent_uuid = _log_.bsc.uuid
INNER JOIN _log_.cliente ON
_log_.bsc.cliente_fk = _log_.cliente.id
AND _log_.cliente.id = _cid_ ;


/*QUERY_NAME: BSC_Licence_Features*/
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.date AS DATE,
_log_.bsc.name AS BSC,
_log_.bsc.cnumber AS 'TARGET_ID',
_log_.licence_bsc.fea_code AS 'FEATURE_CODE',
REPLACE(_log_.licence_bsc.fea_name, ',', '/') AS 'FEATURE_NAME',
_log_.bsc_to_licence.capacity AS CAPACITY,
_log_.bsc_to_licence.lk_usage AS 'USAGE',
(SELECT COUNT(_log_.bsc_lk_file.filename) FROM _log_.bsc_lk_file WHERE _log_.bsc_lk_file.targetid = _log_.bsc.cnumber AND _log_.bsc.cnumber = TARGET_ID AND _log_.bsc_lk_file.fea_code = FEATURE_CODE) AS XML_FILES
FROM
_log_.cliente, _log_.bsc, _log_.bsc_to_licence, _log_.licence_bsc
WHERE
_log_.cliente.id = _log_.bsc.cliente_fk AND
_log_.bsc.uuid = _log_.bsc_to_licence.parent_uuid AND
_log_.licence_bsc.fea_code = _log_.bsc_to_licence.fea_code_fk AND
_log_.cliente.id = _cid_
ORDER BY _log_.bsc.name;

/*QUERY_NAME: BSC_License_Files*/
SELECT _log_.bsc.date AS DATE,
cliente.name AS CUSTOMER,
_log_.bsc.name AS BSC,
_log_.bsc.cnumber AS CNUMBER,
_log_.bsc_lk_file.filename AS FILENAME,
_log_.bsc_lk_file.start_date AS START_DATE,
_log_.bsc_lk_file.lfstate AS FEATURE_STATE,
_log_.bsc_lk_file.orderid AS ORDER_ID,
_log_.bsc_lk_file.customerid AS CUSTOMER_ID,
_log_.bsc_lk_file.customername AS CUSTOMER_NAME,
REPLACE(_log_.bsc_lk_file.licencename, ',', '/') AS LICENSE_NAME,
_log_.bsc_lk_file.serialnumber AS SERIAL_NUMBER,
((SELECT COUNT(_log_.bsc_lk_file.serialnumber) FROM _log_.bsc_lk_file WHERE _log_.bsc_lk_file.serialnumber = SERIAL_NUMBER AND _log_.bsc_lk_file.targetid = _log_.bsc.cnumber) /
(SELECT COUNT(_log_.bsc_lk_file.licencename) FROM _log_.bsc_lk_file WHERE _log_.bsc_lk_file.serialnumber = SERIAL_NUMBER AND _log_.bsc_lk_file.targetid = _log_.bsc.cnumber)) AS SERIAL_NUMBER_PER_NE,     
bsc_lk_file.fea_code AS FEATURE_CODE,
REPLACE(_log_.bsc_lk_file.featurename, ',', '/') AS FEATURE_NAME,
_log_.bsc_lk_file.max_value AS CAPACITY FROM _log_.bsc, _log_.cliente, _log_.bsc_lk_file WHERE
_log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
AND _log_.bsc.cnumber = _log_.bsc_lk_file.targetid ;

/*QUERY_NAME: BCF_Data*/
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.date AS DATE,
_log_.bsc.name AS BSC,
_log_.bcf.bcf_id AS BCF,
IFNULL((SELECT SUBSTRING(_log_.bts.bts_name, 1, CHAR_LENGTH(_log_.bts.bts_name) - 1) FROM _log_.bts WHERE  _log_.bts.bcf_ident_fk =  _log_.bcf.bcf_ident LIMIT 1), "-") AS NAME,
_log_.bcf.bcf_type AS TYPE,
IFNULL((SELECT _log_.bcf_sw_version.version_name FROM _log_.bcf_sw_version WHERE   _log_.bcf.sw_ver = _log_.bcf_sw_version.id), "-") AS 'SW-BUILD',
IFNULL((SELECT _log_.bcf_sw_version.version_id FROM _log_.bcf_sw_version WHERE   _log_.bcf.sw_ver = _log_.bcf_sw_version.id), "-") AS 'SW-VERSION',
(SELECT COUNT(_log_.trx.trx_id) FROM _log_.trx, _log_.bts WHERE
      _log_.trx.bts_ident_fk =  _log_.bts.bts_ident 
   AND
       _log_.bts.bcf_ident_fk =   _log_.bcf.bcf_ident
) TOTAL_TRX,
IFNULL((SELECT _log_.locations.state FROM _log_.locations WHERE
      _log_.bsc.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _log_.bsc.cliente_fk LIMIT 1), "-") AS STATE 
    FROM _log_.bcf
    INNER JOIN _log_.bsc
       ON  _log_.bcf.bsc_cnumber = _log_.bsc.cnumber
    INNER JOIN _log_.cliente
       ON _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_ ;

/*QUERY_NAME: BTS_Data*/
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.date AS DATE,
_log_.bsc.name AS BSC,
_log_.bcf.bcf_id AS BCF,
_log_.bts.bts_name AS BTS_NAME,
_log_.bts.bts_id AS BTS,
_log_.bts.lac AS LAC,
_log_.bts.ci AS CI,
_log_.bcf.bcf_type AS TYPE,
IFNULL((SELECT _log_.bcf_sw_version.version_name FROM _log_.bcf_sw_version WHERE  _log_.bcf.sw_ver = _log_.bcf_sw_version.id), "-") AS 'SW-BUILD',
IFNULL((SELECT _log_.bcf_sw_version.version_id FROM _log_.bcf_sw_version WHERE  _log_.bcf.sw_ver = _log_.bcf_sw_version.id), "-") AS 'SW-VERSION',
_log_.bts.band AS BAND,
CASE ((SELECT COUNT(_log_.trx.trx_mbcch) FROM _log_.trx WHERE _log_.trx.bts_ident_fk = _log_.bts.bts_ident AND _log_.trx.trx_mbcch LIKE 'YES'))
WHEN 0 THEN 'NO'
ELSE 'YES'
END
 AS MASTER_BTS,
COUNT(_log_.trx.trx_id) AS TOTAL_TRX,
IFNULL((SELECT _log_.locations.state FROM _log_.locations WHERE
      _log_.bsc.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _log_.bsc.cliente_fk LIMIT 1), "-") AS STATE 
 FROM _log_.trx
    INNER JOIN _log_.bts
       ON _log_.trx.bts_ident_fk = _log_.bts.bts_ident
    INNER JOIN _log_.bcf
       ON _log_.bts.bcf_ident_fk = _log_.bcf.bcf_ident
    INNER JOIN _log_.bsc
       ON _log_.bcf.bsc_cnumber = _log_.bsc.cnumber
    INNER JOIN _log_.cliente
       ON _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
    GROUP BY _log_.bts.bts_ident
    ORDER BY _log_.bts.bts_ident ;
    
/*QUERY_NAME: BCF_Units*/   
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bcfUnit.date AS DATE,
_log_.bsc.name AS BSC,
_log_.bcf.bcf_id AS BCF,
IFNULL((SELECT SUBSTRING(_log_.bts.bts_name, 1, CHAR_LENGTH(_log_.bts.bts_name) - 1) FROM _log_.bts WHERE _log_.bts.bcf_ident_fk = _log_.bcf.bcf_ident LIMIT 1), "-") AS NAME,
_log_.bcf.bcf_type AS TYPE,
REPLACE(_log_.bcfUnit.prodCode, 'null', '-') AS 'PRODUCT_CODE',
REPLACE(_log_.bcfUnit.version, 'null', '-') AS 'VERSION',
_log_.bcfUnit.sernum AS 'SERIAL_NUMBER',
IFNULL((SELECT _log_.BtsUnit.item FROM _log_.BtsUnit WHERE _log_.BtsUnit.code = _log_.bcfUnit.prodCode), _log_.bcfUnit.prodDesc) AS 'PLUGIN_UNIT',
IFNULL((SELECT _log_.BtsUnit.name FROM _log_.BtsUnit WHERE _log_.BtsUnit.code = _log_.bcfUnit.prodCode), "-") AS 'UNIT_DESCRIPTION',
IFNULL((SELECT _log_.locations.state FROM _log_.locations WHERE
      _log_.bsc.name LIKE CONCAT('%', _log_.locations.string, '%') AND
      _log_.locations.customer_id = _log_.bsc.cliente_fk LIMIT 1), "-") AS STATE 
FROM _log_.bcfUnit INNER JOIN _log_.bcf
    ON _log_.bcfUnit.bcfInd = _log_.bcf.bcf_ident
    INNER JOIN _log_.bsc
       ON _log_.bcf.bsc_cnumber = _log_.bsc.cnumber
    INNER JOIN _log_.cliente
       ON _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
 ORDER BY _log_.bsc.name ;
    
/*QUERY_NAME: BSC_RAM_Memory*/ 
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.date AS DATE,
_log_.bsc.name AS NAME,
_log_.bsc.cnumber AS CNUMBER,
_log_.bsc.type AS BSC_TYPE,
_log_.units_bsc.type AS UNIT,
_log_.units_bsc.id AS ID,
IFNULL(_log_.units_bsc.main_piu, "NULL") AS PIU,
IFNULL((CASE _log_.units_bsc.memory
    WHEN -1 THEN '-'
    ELSE _log_.units_bsc.memory
 END
), "NULL") AS 'MEMORY(MB)',
_log_.units_bsc.state AS STATE
FROM _log_.units_bsc
JOIN _log_.bsc
   ON _log_.units_bsc.cnumber = _log_.bsc.cnumber AND _log_.units_bsc.memory <> -1 AND _log_.units_bsc.main_piu <> "null"
JOIN _log_.cliente
   ON _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
ORDER BY _log_.bsc.name ;

/*QUERY_NAME: BSC_Plugin_Units*/ 
SELECT _log_.cliente.name AS CUSTOMER,
_log_.bsc.name AS BSC,
_log_.bsc.type as TYPE,
_log_.plugin_units_bsc.unit_type AS UNIT,
_log_.plugin_units_bsc.unit_id AS ID,
_log_.plugin_units_bsc.type AS 'PLUGIN-UNIT',
_log_.plugin_units_bsc.id AS 'PLUGIN-UNIT-ID',
_log_.plugin_units_bsc.rack AS 'RACK',
_log_.plugin_units_bsc.cartridge AS 'CARTRIDGE',
_log_.plugin_units_bsc.track AS 'TRACK'
FROM _log_.plugin_units_bsc JOIN
_log_.bsc ON
   _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber
JOIN _log_.cliente ON
   _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_ ;

/*QUERY_NAME: BSC_PCU_Types*/ 
SELECT _log_.bsc.date AS DATE,
_log_.cliente.name AS CUSTOMER,
_log_.bsc.name AS BSC,
_log_.bsc.type AS TYPE,
_log_.bsc.swver AS SW,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.unit_type = 'PCUM') AS PCUM,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.type = 'PCU2_E') AS PCU2_E,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.type = 'PCU2_D') AS PCU2_D,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.type = 'PCU_B') AS PCU_B,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.type = 'PCU_S') AS PCU_S,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.type = 'PCU_T') AS PCU_T,
(SELECT COUNT(_log_.plugin_units_bsc.type) FROM _log_.plugin_units_bsc WHERE _log_.plugin_units_bsc.cnumber = _log_.bsc.cnumber AND _log_.plugin_units_bsc.type = 'PCU') AS PCU
FROM _log_.bsc, _log_.cliente
WHERE _log_.bsc.cliente_fk = _log_.cliente.id AND _log_.cliente.id = _cid_
HAVING (PCU2_E + PCU2_D + PCU_B + PCU_S + PCU_T + PCU + PCUM) > 0 ;
