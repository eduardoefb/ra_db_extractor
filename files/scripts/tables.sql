CREATE TABLE cliente( id VARCHAR(30), name VARCHAR(30) NOT NULL);

CREATE TABLE totalElements(CustomerId INT NOT NULL,
   Type VARCHAR(30),
   DATE DATE NOT NULL,
   Quantity INT NOT NULL);

CREATE TABLE bsc( cliente_fk INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   name VARCHAR(20),
   spc INT DEFAULT NULL,
   type VARCHAR(10),
   cnumber INT,
   location VARCHAR(20),
   date DATE,
   ip VARCHAR(20),
   q3version VARCHAR(10) DEFAULT "NULL",
   swver VARCHAR(10),
   cd VARCHAR(50),
   state VARCHAR(10),
   prfile_ver VARCHAR(40),
   fifile_ver VARCHAR(40),
   capacity INT DEFAULT 0);

CREATE TABLE bcf( bsc_cnumber INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",   
   file_uuid VARCHAR(40) DEFAULT "-",
   bcf_ident DOUBLE,
   bcf_id INT NOT NULL,
   bcf_name VARCHAR(20),
   bcf_type VARCHAR(20) NOT NULL,
   sw_ver INT  DEFAULT 0);
   
CREATE TABLE bcfUnit(date DATE,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   bcfInd DOUBLE NOT NULL,
   prodCode VARCHAR(30),
   piuId INT NOT NULL,
   prodDesc VARCHAR(30),
   serNum VARCHAR(40),
   version VARCHAR(20));

CREATE TABLE bts (bcf_ident_fk DOUBLE,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   bts_ident DOUBLE,
   bts_id INT NOT NULL,
   bts_name VARCHAR(40),
   seg_id INT,
   seg_name VARCHAR(40),
   lac INT,
   ci INT,
   band VARCHAR(20) DEFAULT "-");
      
CREATE TABLE trx (bts_ident_fk DOUBLE,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   trx_ident DOUBLE,
   bts_id INT NOT NULL,
   trx_id INT NOT NULL,
   trx_mbcch VARCHAR(20),
   trx_edge_supported VARCHAR(10),
   freq INT);

CREATE TABLE units_bsc(id INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   type VARCHAR(15),
   state VARCHAR(10),
   main_piu VARCHAR(15),
   memory INT DEFAULT -1,
   cnumber INT NOT NULL);   

CREATE TABLE plugin_units_bsc(id VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-", 
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   type VARCHAR(15),
   unit_type VARCHAR(15),
   rack VARCHAR(20) DEFAULT "-",
   cartridge VARCHAR(20) DEFAULT "-",
   track VARCHAR(20) DEFAULT "-",
   unit_id INT DEFAULT -1,
   cnumber INT NOT NULL);
      
CREATE TABLE bcf_sw_version ( id VARCHAR(30), 
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   bcf_type VARCHAR(20) NOT NULL,
   version_id VARCHAR(30) NOT NULL, 
   version_name VARCHAR(30) );

CREATE TABLE licence_bsc (fea_code VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   fea_name VARCHAR(50));

CREATE TABLE bsc_to_licence(id VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   cnumber_fk INT NOT NULL,
   fea_code_fk INT NOT NULL,
   capacity VARCHAR(10) NOT NULL,
   lk_usage VARCHAR(10) DEFAULT 'ON');

CREATE TABLE bsc_lk_file(filename VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   lfstate VARCHAR(30),
   start_date DATE,
   licencename VARCHAR(200),
   orderid VARCHAR(30),
   serialnumber VARCHAR(50),
   customerid VARCHAR(200),
   customername VARCHAR(200),
   max_value INT NOT NULL,
   targetid INT NOT NULL,
   featurename VARCHAR(200),
   fea_code INT NOT NULL);
      
CREATE TABLE rnc( cliente_fk INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   rnc_id INT NOT NULL,
   oms_ip VARCHAR(20) DEFAULT '-',
   oms_ip_sec VARCHAR(20) DEFAULT '-',
   name VARCHAR(20),
   spc INT DEFAULT NULL,
   type VARCHAR(10),
   cnumber INT,
   location VARCHAR(20) DEFAULT 'UNKNOW',
   date DATE,
   ip VARCHAR(20),
   swver VARCHAR(10),
   cd VARCHAR(50),
   state VARCHAR(10),
   icsus INT DEFAULT NULL);
   


CREATE TABLE iups_rnc( rnc_cnumber INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   NetworkInd INT DEFAULT 0,
   SignPointCode INT NOT NULL,
   CNDomainVersion INT DEFAULT 0);    

CREATE TABLE iucs_rnc( rnc_cnumber INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    NetworkInd INT DEFAULT 0,
    SignPointCode INT NOT NULL,
	CNDomainVersion INT DEFAULT 0);
    
CREATE TABLE iur_rnc( rnc_cnumber INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   NetworkInd INT DEFAULT 0,
   SignPointCode INT NOT NULL,
   NRncId INT DEFAULT 0,
   NRncVersion INT DEFAULT 0);
    


CREATE TABLE wbts( rnc_cnumber INT,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   wbts_ident DOUBLE,
   wbts_id INT NOT NULL,
   wbts_name VARCHAR(40),
   wbts_ip VARCHAR(20) DEFAULT '-',
   wbts_trm VARCHAR(20) DEFAULT '-',
   wbts_type VARCHAR(20) DEFAULT 'UNKNOW',
   wbts_sw VARCHAR(20) DEFAULT 'UNKNOW');
   

CREATE TABLE wbtsFtm(wbtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(60),
   id DOUBLE NOT NULL,
   locationName VARCHAR(50),
   softwareReleaseVersion VARCHAR(30),
   systemTitle VARCHAR(30),
   userLabel VARCHAR(30));
   

CREATE TABLE wbtsIpno(ftmInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(60),
   id DOUBLE NOT NULL);
   

CREATE TABLE wbtsIntp(ipnoInd VARCHAR(30),
   file_uuid VARCHAR(40) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   uuid VARCHAR(60) DEFAULT "-",
    ind VARCHAR(40),
    id DOUBLE NOT NULL);
    

CREATE TABLE wbtsNtp(intpInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ip VARCHAR(30) DEFAULT "-");
   

CREATE TABLE wbtsUnit(ftmInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    id INT NOT NULL,
    unitTypeActual VARCHAR(30) DEFAULT "-",
    unitTypeExpected VARCHAR(20) DEFAULT "-");
    
CREATE TABLE wbtsHwList(wbtsInd VARCHAR(30),
    uuid VARCHAR(60) DEFAULT "-",
    parent_uuid VARCHAR(60) DEFAULT "-",
    file_uuid VARCHAR(40) DEFAULT "-",
    prodCode VARCHAR(50) NOT NULL,
    serNum VARCHAR(50) NOT NULL);
    

CREATE TABLE wbtsMRBTS( wbtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    ind VARCHAR(60),
    id INT NOT NULL,
    TimeZone VARCHAR(20),
    Date DATE);


CREATE TABLE wbtsRmod(mrbtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    id INT NOT NULL,
    prodCode VARCHAR(50),
    serNum VARCHAR(50));
    
CREATE TABLE wbtsSmod(mrbtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    id INT NOT NULL,
    prodCode VARCHAR(50),
    serNum VARCHAR(50));
    
   
CREATE TABLE unitListItem(MrBtsInd VARCHAR(30),
   file_uuid VARCHAR(40) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   primaryConnection VARCHAR(20),
   serNum VARCHAR(50) DEFAULT "-",
   prodCode VARCHAR(20),
   unitName VARCHAR(20),
   unitNumber INT,
   variant VARCHAR(20));
   
   
CREATE TABLE wcel (wbts_ident_fk DOUBLE,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   name VARCHAR(50) DEFAULT "-",
   wcel_ident DOUBLE,
   wcel_id INT,
   cell_id INT,
   lac INT,
   sac INT,
   rac INT,
   freq INT,
   dl_scc INT,
   cell_range INT);
   
CREATE TABLE wbtsHW(
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   wbtsInd DOUBLE NOT NULL,
   id DOUBLE NOT NULL,
   ind VARCHAR(60),
   NEType VARCHAR(50) DEFAULT "-",
   locationName VARCHAR(70) DEFAULT "-",
   operationalState VARCHAR(30) DEFAULT "-",
   vendorName VARCHAR(70) DEFAULT "-",
   systemTitle VARCHAR(70) DEFAULT "-");
   

CREATE TABLE wbtsMODULE(wbtsHWInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    id DOUBLE NOT NULL,   
    ind VARCHAR(60),
    identificationCode VARCHAR(20) DEFAULT "-",
    serialNumber VARCHAR(20) DEFAULT "-",
    state VARCHAR(20) DEFAULT "-",
    subrackSpecificType VARCHAR(30) DEFAULT "-",
    userLabel VARCHAR(20) DEFAULT "-",
    vendorName VARCHAR(70) DEFAULT "-",
    version VARCHAR(20) DEFAULT "-");    
    
    
CREATE TABLE wbtsSUBMODULE(wbtsMODULEInd VARCHAR(30),
    uuid VARCHAR(60) DEFAULT "-",
    parent_uuid VARCHAR(60) DEFAULT "-",
    file_uuid VARCHAR(40) DEFAULT "-",
    id DOUBLE NOT NULL,
    ind VARCHAR(60),
    identificationCode VARCHAR(20) DEFAULT "-",
    serialNumber VARCHAR(40) DEFAULT "-",
    unitType VARCHAR(40) DEFAULT "-",
    vendorName VARCHAR(20) DEFAULT "-",
    version VARCHAR(20) DEFAULT "-");

CREATE TABLE licence_rnc (fea_code VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   fea_name VARCHAR(50));

CREATE TABLE rnc_to_licence(id VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   cnumber_fk INT NOT NULL,
   fea_code_fk INT NOT NULL,
   lk_usage VARCHAR(10) DEFAULT '-',
   capacity VARCHAR(10) NOT NULL);

CREATE TABLE rnc_lk_file(filename VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   lfstate VARCHAR(30),
   start_date DATE,
   licencename VARCHAR(200),
   orderid VARCHAR(30),
   serialnumber VARCHAR(50),
   customerid VARCHAR(200),
   customername VARCHAR(200),
   max_value INT NOT NULL,
   targetid INT NOT NULL,
   featurename VARCHAR(200),
   fea_code INT NOT NULL);

CREATE TABLE units_rnc(id VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   type VARCHAR(15),
   state VARCHAR(10),
   pluginunit VARCHAR(15),
   memory INT DEFAULT -1,
   cnumber INT NOT NULL,
   iti VARCHAR(20) DEFAULT "-",
   sen VARCHAR(20) DEFAULT "-",
   chms INT DEFAULT -1,
   shms INT DEFAULT -1,
   ppa INT DEFAULT -1);  

CREATE TABLE hw_mcrnc (unit_name VARCHAR(20) DEFAULT "-",
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   unit_id VARCHAR(10) DEFAULT "-",
   cabinet INTEGER DEFAULT -1,
   chassis INTEGER DEFAULT -1,
   pos VARCHAR(40) DEFAULT "-",
   rnc_cnumber INTEGER NOT NULL,
   prod_manufacturer VARCHAR(100) DEFAULT "-",
   prod_name VARCHAR(100) DEFAULT "-",
   prod_partnumber VARCHAR(100) DEFAULT "-",
   prod_version VARCHAR(100) DEFAULT "-",
   prod_serial VARCHAR(100) DEFAULT "-",
   prod_fileid VARCHAR(100) DEFAULT "-",
   prod_custom VARCHAR(100) DEFAULT "-",
   board_mfg_date VARCHAR(100) DEFAULT "-",
   board_manufacturer VARCHAR(100) DEFAULT "-",
   board_name VARCHAR(20) DEFAULT "-",
   board_serial VARCHAR(100) DEFAULT "-",
   board_part_number VARCHAR(100) DEFAULT "-");


CREATE TABLE cnl(id VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   uf VARCHAR(4) NOT NULL,
   cnl VARCHAR(6) NOT NULL,
   loc VARCHAR(40) NOT NULL);

CREATE TABLE mrbts(CustomerId VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   Name VARCHAR(30),
   Ind VARCHAR(60),
   Id VARCHAR(60),
   Date DATE,
   SwVersion VARCHAR(10),
   TimeZone VARCHAR(50));

CREATE TABLE Rmod(mrbtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    id INT NOT NULL,
    prodCode VARCHAR(50),
    serNum VARCHAR(50));    

CREATE TABLE Smod(mrbtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    id INT NOT NULL,
    prodCode VARCHAR(50),
    serNum VARCHAR(50));    

CREATE TABLE LteUnitListItem(MrBtsInd VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   primaryConnection varchar(20),
   serNum VARCHAR(50) DEFAULT "-",
   prodCode VARCHAR(20),
   unitName VARCHAR(20),
   unitNumber INT,
   variant VARCHAR(20));

CREATE TABLE mrbtsHwList(mrbtsInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    prodCode VARCHAR(50) NOT NULL,
    serNum VARCHAR(50) NOT NULL);    

CREATE TABLE lnbts(MrBtsInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    Id VARCHAR(30),
    Ind VARCHAR(30),
    SwVersion VARCHAR(10),
    Mcc INT,
    Mnc VARCHAR(10),
    Name VARCHAR(30));    


CREATE TABLE lncel(LnBtsInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(30),
   id DOUBLE NOT NULL,
   SwVersion VARCHAR(10),
   Angle FLOAT,
   Name VARCHAR(30),
   eutraCelId DOUBLE NOT NULL,
   Mcc INT,
   Mnc VARCHAR(10),
   Tac INT,
   pMax FLOAT);

CREATE TABLE ftm(LnBtsInd DOUBLE NOT NULL,
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(60),
   id DOUBLE NOT NULL,
   name VARCHAR(30),
   locationName VARCHAR(50),
   softwareReleaseVersion VARCHAR(30),
   systemTitle VARCHAR(30),
   userLabel VARCHAR(30));

CREATE TABLE Unit(ftmInd VARCHAR(30),
    uuid VARCHAR(60) DEFAULT "-",
    parent_uuid VARCHAR(60) DEFAULT "-",
    file_uuid VARCHAR(40) DEFAULT "-",
    id INT NOT NULL,
    unitTypeActual VARCHAR(30) DEFAULT "-",
    unitTypeExpected VARCHAR(20) DEFAULT "-");    

CREATE TABLE ipno(FtmInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(30),
   id DOUBLE NOT NULL,
   actSeparationRanSharing VARCHAR(30),
   addCPlaneIpv4Address VARCHAR(30),
   addUPlaneIpv4Address VARCHAR(30),
   transportNwId INT,
   btsId INT,
   cPlaneIpAddress VARCHAR(30),
   mPlaneIpAddress VARCHAR(30),
   oamIpAddr VARCHAR(30),
   sPlaneIpAddress VARCHAR(30),
   secOmsIpAddr VARCHAR(30),
   servingOms VARCHAR(30),
   uPlaneIpAddress VARCHAR(30),
   ftmBtsSubnetAddress VARCHAR(30),
   ftmBtsSubnetMask VARCHAR(30));   

CREATE TABLE ieif(IpnoInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   localIpAddr VARCHAR(20),
   mtu INT,
   id DOUBLE NOT NULL,
   netmask VARCHAR(20),
   qosEnabled VARCHAR(10),
   ind VARCHAR(60));

CREATE TABLE ivif(IeifInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(60),
   id DOUBLE NOT NULL,
   localIpAddr VARCHAR(20),
   netmask VARCHAR(20),
   qosEnable VARCHAR(10),
   vlanId INT);


CREATE TABLE iprt (IpnoInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    ind VARCHAR(60),
    id DOUBLE NOT NULL);

CREATE TABLE StaticRoute(IprtInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(30),
   bfdId INT,
   destIpAddr VARCHAR(20),
   gateway VARCHAR(20),
   netmask VARCHAR(20),
   preference INT);


CREATE TABLE lnmme(LnBtsInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ind VARCHAR(60),
   id DOUBLE NOT NULL,
   ipAddrPrim VARCHAR(20) DEFAULT "-",
   ipAddrSec VARCHAR(20) DEFAULT "-",
   s1LinkStatus VARCHAR(20),
   transportNwId INT);

CREATE TABLE accMmePlmnsList(MmeInd VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   mcc INT,
   mnc VARCHAR(10));


CREATE TABLE BtsUnit(
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   item VARCHAR(20) DEFAULT "-",
   code VARCHAR(20) DEFAULT "-",
   name VARCHAR(50) DEFAULT "-");
    

CREATE TABLE zwoi_bsc(ind VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    parClass INT NOT NULL,
    identifier INT NOT NULL,
    nameOfParameter VARCHAR(80));


CREATE TABLE zwos_bsc(ind VARCHAR(30),
    uuid VARCHAR(60),
    parent_uuid VARCHAR(60) DEFAULT "-",
    parClass INT NOT NULL,
    identifier INT NOT NULL,
    nameOfParameter VARCHAR(80));

CREATE TABLE zwoi_rnc(ind VARCHAR(30),
    uuid VARCHAR(60),
    parent_uuid VARCHAR(60) DEFAULT "-",
    file_uuid VARCHAR(40) DEFAULT "-",
    parClass INT NOT NULL,
    identifier INT NOT NULL,
    nameOfParameter VARCHAR(80));

CREATE TABLE zwos_rnc(ind VARCHAR(30),
    uuid VARCHAR(60),
    parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    parClass INT NOT NULL,
    identifier INT NOT NULL,
    nameOfParameter VARCHAR(80));

CREATE TABLE bsc2zwoi(bscCnumber INT,
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    zwoiInd INT NOT NULL,
    value VARCHAR(20),
    changePossibility VARCHAR(20));

CREATE TABLE rnc2zwoi(rncCnumber INT NOT NULL,
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    zwoiInd INT NOT NULL,
    value VARCHAR(20),
    changePossibility VARCHAR(20));


CREATE TABLE bsc2zwos(bscCnumber INT,
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    zwoiInd INT NOT NULL,
    activationStatus VARCHAR(20));

CREATE TABLE rnc2zwos(rncCnumber VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    zwoiInd INT NOT NULL,
    activationStatus VARCHAR(20));

CREATE TABLE spc2name(cust VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
    name VARCHAR(40) DEFAULT "-",
    spc INT NOT NULL);
        
CREATE TABLE fns(customer_fk INT,
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",		   
   name VARCHAR(20),
   spc INT DEFAULT NULL,
   type VARCHAR(10),
   cnumber VARCHAR(30),
   location VARCHAR(20),
   date DATE,
   ip VARCHAR(20),   
   swver VARCHAR(10),   
   state VARCHAR(10));   
   
CREATE TABLE licence_fns (fea_code VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   fea_name VARCHAR(50));

CREATE TABLE fns_to_licence(id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   cnumber_fk INT NOT NULL,
   fea_code_fk INT NOT NULL,
   capacity VARCHAR(10) NOT NULL,
   lk_usage VARCHAR(10) DEFAULT 'ON');  

CREATE TABLE fns_lk_file(filename VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   lfstate VARCHAR(30),
   start_date DATE,
   licencename VARCHAR(200),
   orderid VARCHAR(30),
   serialnumber VARCHAR(50),
   customerid VARCHAR(200),
   customername VARCHAR(200),
   max_value INT NOT NULL,
   targetid INT NOT NULL,
   featurename VARCHAR(200),
   fea_code INT NOT NULL); 
   
CREATE TABLE units_fns(id VARCHAR(30), 
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   type VARCHAR(15),
   state VARCHAR(10),
   main_piu VARCHAR(15),
   memory INT DEFAULT -1,
   cnumber INT NOT NULL);

CREATE TABLE plugin_units_fns(id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   type VARCHAR(15),
   unit_type VARCHAR(15),
   rack VARCHAR(20) DEFAULT "-",
   cartridge VARCHAR(20) DEFAULT "-",
   track VARCHAR(20) DEFAULT "-",
   unit_id INT DEFAULT -1,
   cnumber INT NOT NULL,
   iti VARCHAR(20) DEFAULT "-",
   sen VARCHAR(20) DEFAULT "-");
   
CREATE TABLE fns_application(target_id VARCHAR(30), 
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   unit_type VARCHAR(20),
   unit_id VARCHAR(20),
   application_type VARCHAR(20),
   application_ipv4 VARCHAR(20),
   application_ipv6 VARCHAR(40));
      
CREATE TABLE fns_enb(target_id VARCHAR(30), 
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   ip VARCHAR(20),
   id VARCHAR(20),
   mcc VARCHAR(20),
   mnc VARCHAR(20),
   plmn VARCHAR(500) DEFAULT "-",
   tac VARCHAR(500) DEFAULT "-");   
      
CREATE TABLE fns_rnc(target_id VARCHAR(30), 
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   name VARCHAR(50),
   id VARCHAR(20),
   mcc VARCHAR(20),
   mnc VARCHAR(20),
   ni VARCHAR(20),
   spc VARCHAR(20),
   lac VARCHAR(20) DEFAULT "-",
   rac VARCHAR(10) DEFAULT "-");

CREATE TABLE bsc_prfile(target_id VARCHAR(30),
   uuid VARCHAR(60) DEFAULT "-",
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   parameter_class VARCHAR(10),
   parameter_name VARCHAR(100),
   identifier VARCHAR(15),
   name_of_parameter VARCHAR(100),
   value VARCHAR(15),
   change_possibility VARCHAR(10));

CREATE TABLE rnc_prfile(target_id VARCHAR(30),
   uuid VARCHAR(60), 
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   parameter_class VARCHAR(10),
   parameter_name VARCHAR(100),
   identifier VARCHAR(15),
   name_of_parameter VARCHAR(100),
   value VARCHAR(15),
   change_possibility VARCHAR(10));
   

CREATE TABLE fns_prfile(target_id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   parameter_class VARCHAR(10),
   parameter_name VARCHAR(100),
   identifier VARCHAR(15),
   name_of_parameter VARCHAR(100),
   value VARCHAR(15),
   change_possibility VARCHAR(10));
      

CREATE TABLE bsc_fifile(target_id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   parameter_class VARCHAR(10),
   parameter_name VARCHAR(100),
   identifier VARCHAR(15),
   name_of_parameter VARCHAR(100),
   activation_status VARCHAR(15));
   
   
CREATE TABLE rnc_fifile(target_id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   parameter_class VARCHAR(10),
   parameter_name VARCHAR(100),
   identifier VARCHAR(15),
   name_of_parameter VARCHAR(100),
   activation_status VARCHAR(15));
   
   
CREATE TABLE fns_fifile(target_id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   parameter_class VARCHAR(10),
   parameter_name VARCHAR(100),
   identifier VARCHAR(15),
   name_of_parameter VARCHAR(100),
   activation_status VARCHAR(15));
   
   
CREATE TABLE fns_plmn(target_id VARCHAR(30),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   id VARCHAR(80),
   name VARCHAR(50),
   type VARCHAR(50));


CREATE TABLE fns_plmn_parameter(plmn_id VARCHAR(80),
   uuid VARCHAR(60),
   parent_uuid VARCHAR(60) DEFAULT "-",
   file_uuid VARCHAR(40) DEFAULT "-",
   name VARCHAR(400),
   short_name VARCHAR(20),
   value VARCHAR(200));
   
   
CREATE TABLE files (id VARCHAR(100) NOT NULL,
    uuid VARCHAR(60),
    parent_uuid VARCHAR(60) DEFAULT "-",
	name VARCHAR(100) DEFAULT "-",
	customer_id VARCHAR(10) DEFAULT "-",
	status VARCHAR(40) DEFAULT "-",
	date VARCHAR(30) DEFAULT "-");
	
	
CREATE TABLE xlsxfiles (     
	name VARCHAR(100) DEFAULT "-",	
	status VARCHAR(40) DEFAULT "-",
	created_date VARCHAR(30) DEFAULT "-",
	finished_date VARCHAR(30) DEFAULT "-",
	url VARCHAR(200) DEFAULT "-");
   
   
CREATE TABLE hardware (   
	code VARCHAR(20) NOT NULL,
	name VARCHAR(10) DEFAULT "-",
	description VARCHAR(80) DEFAULT "-");

INSERT INTO hardware (code, name, description) VALUES ('470036A', 'FSMB', 'Flexi System Module Rel.1');
INSERT INTO hardware (code, name, description) VALUES ('471401A', 'FSMC', 'Flexi System Module Rel.2');
INSERT INTO hardware (code, name, description) VALUES ('471402A', 'FSMD', 'Flexi System Module Rel.2');
INSERT INTO hardware (code, name, description) VALUES ('471469A', 'FSME', 'Flexi System Module Rel.2');
INSERT INTO hardware (code, name, description) VALUES ('472269A', 'FSIA', 'Flexi System Module Indoor Rel.2');
INSERT INTO hardware (code, name, description) VALUES ('472272A', 'FSIB', 'Flexi System Module Indoor Rel.2');
INSERT INTO hardware (code, name, description) VALUES ('472181A', 'FSMF', 'Flexi System Module Rel.3');
INSERT INTO hardware (code, name, description) VALUES ('472182A', 'FBBA', 'FBBA Capacity Extension Sub-Module');
INSERT INTO hardware (code, name, description) VALUES ('472797A', 'FBBC2', 'FBBC Capacity Extension Sub-Module');
INSERT INTO hardware (code, name, description) VALUES ('472261A', 'FRGQ', 'RRH 2x40W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('473042A', 'FHFB', 'RRH 4x40W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471232A', 'FRGD', 'RFM 1x50W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471268A', 'FRCB', 'RFM 1x50W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471267A', 'FRDB', 'RFM 1x50W 900MHz');
INSERT INTO hardware (code, name, description) VALUES ('471820A', 'FRGJ', 'RFM 1x50W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471273A', 'FRFB', 'RFM 1x50W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471835A', 'FRGM', 'RFM 1x50W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471215A', 'FRIB', 'RFM 1x50W 1700/2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471266A', 'FRCA', 'RFM 2x50W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471265A', 'FRDA', 'RFM 2x50W 900MHz');
INSERT INTO hardware (code, name, description) VALUES ('471017A', 'FRFA', 'RFM 2x50W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471231A', 'FRGC', 'RFM 2x50W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471821A', 'FRGK', 'RFM 2x50W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471834A', 'FRGL', 'RFM 2x50W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471000A', 'FRIA', 'RFM 2x50W 1700/2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471882A', 'FRGG', 'RRH 1x60W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472649A', 'FHDB', 'RRH 2x60W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472854A', 'FRGY', 'RRH 2x60W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('473224A', 'FRCG', 'RRH 2x60W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472142A', 'FXCA', 'RFM 3x60W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472083A', 'FXDA', 'RFM 3x60W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472166A', 'FXFA', 'RFM 3x60W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472569A', 'FXFB', 'RFM 3x60W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472084A', 'FXEA', 'RFM 3x60W 1800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472100A', 'FRGP', 'RFM 3x60W 2010 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472100B', 'FRGP', 'RFM 3x60W 2010 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471483A', 'FRGF', 'RFM 3x60W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471895A', 'FRIE', 'RFM 3x60W 1700/2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472111A', 'FRKA', 'RMF 3x60W 1500 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472143A', 'FXDJ', 'RMF 3x60W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472461A', 'FQDJ', 'RFM 3x60W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472956A', 'FRGU', 'RFM 6x60W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472132A', 'FHDA', 'RRH 2TX 80W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472678A', 'FXCB', 'RFM 3x80W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472573A', 'FXDB', 'RFM 3x80W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472574A', 'FXJB', 'RFM 3x80W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472679A', 'FXFC', 'RFM 3x80W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472810A', 'FRGT', 'RFM 3x80W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472847A', 'FRGS', 'RFM 3x80W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('473440A', 'FRGX', 'RFM 3T6R 2100');
INSERT INTO hardware (code, name, description) VALUES ('473368A', 'FRIJ', 'RRH 4-pipe 1700/2100 160W');
INSERT INTO hardware (code, name, description) VALUES ('473033A', 'FHGA', 'Flexi RRH 2TX 2100');
INSERT INTO hardware (code, name, description) VALUES ('FQFA_FXFC', 'FQFA_FXFC', 'Flexi Lite BTS 1900 band/RFM 3x80W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('FWFF_FRFF', 'FWFF_FRFF', '-');
INSERT INTO hardware (code, name, description) VALUES ('FWFJ_FRFJ', 'FWFJ_FRFJ', '-');

/*4g*/
INSERT INTO hardware (code, name, description) VALUES ('472142A', 'FXCA', 'RFM 3x60W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472661A', 'FXCC', 'RFM 2x60W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472703A', 'FRPA', 'RFM 6x40W 700 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472752A', 'FRPB', 'RFM 6x40W 700 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472221A', 'FRMA', 'RFM 3x60W 800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472625A', 'FRMD', 'RFM 3x60W 800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472655A', 'FRMC', 'RFM 6x40W 800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472083A', 'FXDA', 'RFM 3x60W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472573A', 'FXDB', 'RFM 3x80W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471895A', 'FRIE', 'RFM 3x60W 2100/1700 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472417A', 'FRBB', 'RFM 3x40W 760 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472084A', 'FXEA', 'RFM 3x60W 1800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472501A', 'FXEB', 'RFM 3x80W 1800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472100A', 'GP_A', 'RFM 3x60W 2100 MHz FR');
INSERT INTO hardware (code, name, description) VALUES ('472100B', 'GP_B', 'RFM 3x60W 2100 MHz FR');
INSERT INTO hardware (code, name, description) VALUES ('472810A', 'FRGT', 'RFM 3x80W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472847A', 'FRGS', 'RFM 3x80W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472166A', 'FXFA', 'RFM 3x60W 1900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('471894A', 'FRHA', 'RFM 3x60W 2600 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472656A', 'FRHC', 'RFM 6x40W 2600 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472849A', 'FRHF', 'RFM 6x40W 2600 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472180A', 'FRLB', 'RRH 2x40W 730 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472291A', 'FRMB', 'RRH 2x40W 800 MHz EU');
INSERT INTO hardware (code, name, description) VALUES ('472169A', 'FHCA', 'RRH 2x40W 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('x00065698', 'FHCB', 'Low power RRH 2x10mW 850 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472649A', 'FHDB', 'RRH 2x60W 900 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472168A', 'FHEA', 'RRH 2x40W 1800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472650A', 'FHEB', 'RRH 2x60W 1800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('x00068817', 'FHEC', 'Low power RRH 2x1mW 1800 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472704A', 'FRIG', 'RRH 2x60W/4x30W 1700 MHz/2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472261A', 'FRGQ', 'RRH 2x40W 2100 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472830A', 'FRHE', 'RRH 4x30W 2600 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472746A', 'FRHD', 'RRH 4x30W 2600 MHz');
INSERT INTO hardware (code, name, description) VALUES ('472292A', 'FRHB', 'RRH 2x40W 2600 MHz');

INSERT INTO hardware (code, name, description) VALUES ('471469A', 'FSME', 'System Module');
INSERT INTO hardware (code, name, description) VALUES ('471402A', 'FSMD', 'System Module');
INSERT INTO hardware (code, name, description) VALUES ('472181A', 'FSMF', 'System Module');

INSERT INTO hardware (code, name, description) VALUES ('470142A', 'FCOA', 'Flexi Cabinet for Outdoor');
INSERT INTO hardware (code, name, description) VALUES ('470152A', 'FCIA', 'Flexi Cabinet for Indoor');
INSERT INTO hardware (code, name, description) VALUES ('471614A', 'FMSA', 'Flexi Mounting Shield 6U');
INSERT INTO hardware (code, name, description) VALUES ('471650A', 'FMSB', 'Flexi Mounting Shield 18U');

INSERT INTO hardware (code, name, description) VALUES ('474241A', 'AHBCA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474341A', 'AHBCC', '-');
INSERT INTO hardware (code, name, description) VALUES ('473966A', 'AHCA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474739A', 'AHDA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474257A', 'AHDB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473484A', 'AHEB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473806A', 'AHEC', '-');
INSERT INTO hardware (code, name, description) VALUES ('473807A', 'AHED', '-');
INSERT INTO hardware (code, name, description) VALUES ('473995A', 'AHEGA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474090A', 'AHEGB', '-');
INSERT INTO hardware (code, name, description) VALUES ('474253A', 'AHEH', '-');
INSERT INTO hardware (code, name, description) VALUES ('474513A', 'AHEJ', '-');
INSERT INTO hardware (code, name, description) VALUES ('473967A', 'AHFIA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474216A', 'AHFIB', '-');
INSERT INTO hardware (code, name, description) VALUES ('474239A', 'AHFIC', '-');
INSERT INTO hardware (code, name, description) VALUES ('474586A', 'AHGC', '-');
INSERT INTO hardware (code, name, description) VALUES ('474147A', 'AHHA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474252A', 'AHHB', '-');
INSERT INTO hardware (code, name, description) VALUES ('474240A', 'AHLBA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474331A', 'AHLOA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474255A', 'AHMA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474119A', 'AHPB', '-');
INSERT INTO hardware (code, name, description) VALUES ('474649A', 'AHPC', '-');
INSERT INTO hardware (code, name, description) VALUES ('473997A', 'AHPMDA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474146A', 'AZRA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474510A', 'AZRB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472169A', 'FHCA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472132A', 'FHDA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472649A', 'FHDB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473177A', 'FHDG', '-');
INSERT INTO hardware (code, name, description) VALUES ('473825A', 'FHDI', '-');
INSERT INTO hardware (code, name, description) VALUES ('472168A', 'FHEA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472650A', 'FHEB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472829A', 'FHED', '-');
INSERT INTO hardware (code, name, description) VALUES ('473032A', 'FHEE', '-');
INSERT INTO hardware (code, name, description) VALUES ('473043A', 'FHEF', '-');
INSERT INTO hardware (code, name, description) VALUES ('473044A', 'FHEG', '-');
INSERT INTO hardware (code, name, description) VALUES ('473045A', 'FHEH', '-');
INSERT INTO hardware (code, name, description) VALUES ('473178A', 'FHEI', '-');
INSERT INTO hardware (code, name, description) VALUES ('473180A', 'FHEJ', '-');
INSERT INTO hardware (code, name, description) VALUES ('473475A', 'FHEL', '-');
INSERT INTO hardware (code, name, description) VALUES ('473042A', 'FHFB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473033A', 'FHGA', '-');
INSERT INTO hardware (code, name, description) VALUES ('473102A', 'FHGB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473838A', 'FHKA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474088A', 'FHOA', '-');
INSERT INTO hardware (code, name, description) VALUES ('473821A', 'FHPD', '-');
INSERT INTO hardware (code, name, description) VALUES ('473220A', 'FRAA', '-');
INSERT INTO hardware (code, name, description) VALUES ('474383A', 'FRAB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472417A', 'FRBB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473111A', 'FRBE', '-');
INSERT INTO hardware (code, name, description) VALUES ('473112A', 'FRBF', '-');
INSERT INTO hardware (code, name, description) VALUES ('473188A', 'FRBG', '-');
INSERT INTO hardware (code, name, description) VALUES ('474045A', 'FRBI', '-');
INSERT INTO hardware (code, name, description) VALUES ('473200A', 'FRCC', '-');
INSERT INTO hardware (code, name, description) VALUES ('473224A', 'FRCG', '-');
INSERT INTO hardware (code, name, description) VALUES ('473788A', 'FRCI', '-');
INSERT INTO hardware (code, name, description) VALUES ('473818A', 'FRCJ', '-');
INSERT INTO hardware (code, name, description) VALUES ('473364A', 'FRGA', '-');
INSERT INTO hardware (code, name, description) VALUES ('473365A', 'FRGB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472100A', 'FRGP.A', '-');
INSERT INTO hardware (code, name, description) VALUES ('472100B', 'FRGP.B', '-');
INSERT INTO hardware (code, name, description) VALUES ('472261A', 'FRGQ', '-');
INSERT INTO hardware (code, name, description) VALUES ('472847A', 'FRGS', '-');
INSERT INTO hardware (code, name, description) VALUES ('472810A', 'FRGT', '-');
INSERT INTO hardware (code, name, description) VALUES ('472956A', 'FRGU', '-');
INSERT INTO hardware (code, name, description) VALUES ('473440A', 'FRGX', '-');
INSERT INTO hardware (code, name, description) VALUES ('472854A', 'FRGY', '-');
INSERT INTO hardware (code, name, description) VALUES ('471894A', 'FRHA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472292A', 'FRHB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472656A', 'FRHC', '-');
INSERT INTO hardware (code, name, description) VALUES ('472746A', 'FRHD1)', '-');
INSERT INTO hardware (code, name, description) VALUES ('472830A', 'FRHE', '-');
INSERT INTO hardware (code, name, description) VALUES ('472849A', 'FRHF', '-');
INSERT INTO hardware (code, name, description) VALUES ('473225A', 'FRHG', '-');
INSERT INTO hardware (code, name, description) VALUES ('471895A', 'FRIE', '-');
INSERT INTO hardware (code, name, description) VALUES ('472704A', 'FRIG', '-');
INSERT INTO hardware (code, name, description) VALUES ('473042A', 'FRIJ', '-');
INSERT INTO hardware (code, name, description) VALUES ('472111A', 'FRKA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472180A', 'FRLB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472221A', 'FRMA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472291A', 'FRMB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472655A', 'FRMC', '-');
INSERT INTO hardware (code, name, description) VALUES ('472625A', 'FRMD', '-');
INSERT INTO hardware (code, name, description) VALUES ('472927A', 'FRME', '-');
INSERT INTO hardware (code, name, description) VALUES ('472930A', 'FRMF', '-');
INSERT INTO hardware (code, name, description) VALUES ('473965A', 'FRNB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473189A', 'FRNC', '-');
INSERT INTO hardware (code, name, description) VALUES ('473965A', 'FRND', '-');
INSERT INTO hardware (code, name, description) VALUES ('472703A', 'FRPA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472752A', 'FRPB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472142A', 'FXCA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472678A', 'FXCB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472661A', 'FXCC', '-');
INSERT INTO hardware (code, name, description) VALUES ('472083A', 'FXDA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472573A', 'FXDB', '-');
INSERT INTO hardware (code, name, description) VALUES ('473564A', 'FXDD', '-');
INSERT INTO hardware (code, name, description) VALUES ('472143A', 'FXDJ', '-');
INSERT INTO hardware (code, name, description) VALUES ('472084A', 'FXEA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472501A', 'FXEB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472924A', 'FXED', '-');
INSERT INTO hardware (code, name, description) VALUES ('473223A', 'FXEE', '-');
INSERT INTO hardware (code, name, description) VALUES ('473439A', 'FXEF', '-');
INSERT INTO hardware (code, name, description) VALUES ('472166A', 'FXFA', '-');
INSERT INTO hardware (code, name, description) VALUES ('472569A', 'FXFB', '-');
INSERT INTO hardware (code, name, description) VALUES ('472679A', 'FXFC', '-');
INSERT INTO hardware (code, name, description) VALUES ('472574A', 'FXJB', '-');
INSERT INTO hardware (code, name, description) VALUES ('474512A', 'FXJC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AP', 'UDBA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AP', 'UDCA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR63121AA', 'UDEA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AQ', 'UDFA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR63120AA', 'UDGA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AQ', 'UDIA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AP', 'UDLA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR63116AA', 'UDMA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AZ', 'UHAA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AH', 'UHBA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AF', 'UHBB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36401AG', 'UHBC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK61812AA', 'UHBE', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR101178AA', 'UHBF', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AV', 'UHCA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK33303AL', 'UHCB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR53501AA', 'UHEA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK62412AD', 'UHEB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR58501AB', 'UHEC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK28776AA', 'UHED', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR39701AB', 'UHEE', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK62412AE', 'UHEF', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AC', 'UHFA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AW', 'UHFB', '-');
INSERT INTO hardware (code, name, description) VALUES ('849144431', 'UHFC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AS', 'UHFD', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AS', 'UHFE', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK33301AL', 'UHFF', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR39054AA', 'UHFG', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AV', 'UHGA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK33300AW', 'UHGB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36403AD', 'UHGC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR37867AF', 'UHHA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AY', 'UHHB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AJ', 'UHIA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36401AJ', 'UHIB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AQ', 'UHIC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AB', 'UHID', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36402AN', 'UHIE', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR101178AA', 'UHIF', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK61689AA', 'UHIG', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AE', 'UHLA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AL', 'UHLB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AR', 'UHLC', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AI', 'UHMA', '-');
INSERT INTO hardware (code, name, description) VALUES ('3JR52720AA', 'UHMB', '-');
INSERT INTO hardware (code, name, description) VALUES ('3BK36400AU', 'UHNA', '-');

INSERT INTO hardware (code, name, description) VALUES ('472313A', 'FZHA', 'RFM 8x10W 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473004A', 'FZHG', 'RRH 2TX 2600 ');
INSERT INTO hardware (code, name, description) VALUES ('472618A', 'FZND-ac', 'RRH 2TX 2300 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472371A', 'FZND-dc', 'RRH 2TX 2300 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472652A', 'FZNI', 'RRH 4TX 2300 ');
INSERT INTO hardware (code, name, description) VALUES ('472744A', 'FZNK', '2300 1TX 50W RRH (dual mode) ');
INSERT INTO hardware (code, name, description) VALUES ('472745A', 'FZNL', '2300 1TX 20W RRH (dual mode) ');
INSERT INTO hardware (code, name, description) VALUES ('472833A', 'FZHJ', 'RRH 8TR 8x20W 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472952A', 'FZHJ-b', 'RRH 8TX 8x20 W 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473011A', 'FZHM', 'RRH 8TX 8x20W 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472985A', 'FZHO', 'Flexi RRH 2TX 2600 ');
INSERT INTO hardware (code, name, description) VALUES ('473106A', 'FZHQ', 'RRH 8TX 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473175A', 'FZHS', 'RRH 2TX 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473256A-AC', 'FZFH-ac', 'RRH 4-pipe 1900+2600 140W H AC ');
INSERT INTO hardware (code, name, description) VALUES ('473256A-DC', 'FZFH-dc', 'RRH 4-pipe 1900+2600 140W H DC ');
INSERT INTO hardware (code, name, description) VALUES ('473048A', 'FZHP-dc', 'RRH 2TX 2600 ');
INSERT INTO hardware (code, name, description) VALUES ('472986A', 'FZHP-ac', 'RRH 2TX 2600 ');
INSERT INTO hardware (code, name, description) VALUES ('472954A', 'FZHI', 'RRH 8TX 2600 8x20W ');
INSERT INTO hardware (code, name, description) VALUES ('473196A', 'FZQE', 'RRH 8T8R 3500 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473560A', 'FZNE', 'RRH 2TX 2300 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473262A', 'FZHN', 'RRH 8-pipe 2600 MHz 160W N ');
INSERT INTO hardware (code, name, description) VALUES ('473382A', 'FZFI', 'RRH 8-pipe 1900+2600 MHz Dual-Band 240W I ');
INSERT INTO hardware (code, name, description) VALUES ('473791A', 'FZHR', 'RRH 8-pipe 2600 MHz 160W ');
INSERT INTO hardware (code, name, description) VALUES ('473937A', 'FZNJ1', 'RRH 4T4R 2300 MHz 120W ');
INSERT INTO hardware (code, name, description) VALUES ('3JR40830AB', 'UZFB', 'RRH 1900 MHz 8x10W ');
INSERT INTO hardware (code, name, description) VALUES ('3BK60007AA', 'UZNA', 'RRH B40 2300 2x50W ');
INSERT INTO hardware (code, name, description) VALUES ('3JR40801AA', 'UZHC', 'RRH 8x10-2640 2600 MHz RRH 8x10W ');
INSERT INTO hardware (code, name, description) VALUES ('3JR40830AA', 'UZFA', 'RRH B39-1935 1900M Hz 8x10W ');
INSERT INTO hardware (code, name, description) VALUES ('3JR41701AA', 'UZHD', 'RRH 2600 MHz 8x20W ');
INSERT INTO hardware (code, name, description) VALUES ('3BK60007AA', 'UZHA', 'RRH B41 RRH8x20-25 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('3JR41101AB', 'UZHB', 'RRH B41 RRH8x20-A 2600 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472834A', 'FZFF', 'RRH 8TX 1900 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472835A', 'FZNN-ac', 'RRH 1TX 2300 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('472975A', 'FZNN-dc', 'RRH 1TX 2300 MHz ');
INSERT INTO hardware (code, name, description) VALUES ('473095A', 'ASIA', 'AirScale Common (ASIA) plug-in unit');
INSERT INTO hardware (code, name, description) VALUES ('087946A', 'ASIA Accessory Bag', 'AirScale Common (ASIA) plug-in unit');
INSERT INTO hardware (code, name, description) VALUES ('473098A', 'AMIA', 'AirScale Subrack (AMIA)');
INSERT INTO hardware (code, name, description) VALUES ('087771A', 'AMIA Accessory Bag', 'AirScale Subrack (AMIA)');
INSERT INTO hardware (code, name, description) VALUES ('473096A', 'ABIA', 'AirScale Common (ASIA) plug-in unit');
INSERT INTO hardware (code, name, description) VALUES ('473722A', 'FW2EHWA', 'Flexi Zone Multiband Indoor Pico BTS FDD-LTE');


INSERT INTO hardware (code, name, description) VALUES ('473722A', 'FW2EHWA', 'Flexi Zone Multiband Indoor Pico BTS FDD-LTE');
INSERT INTO hardware (code, name, description) VALUES ('471248A', 'FTJA', 'FTJA with 7 rubber plugs, 4 screws, FCM -FTM connector card');

INSERT INTO hardware (code, name, description) VALUES ('86010153', 'FlexRET', 'Kathrein - Electronic Tilt Adjuster (FlexRET)');
INSERT INTO hardware (code, name, description) VALUES ('86010153v01', 'FlexRET', 'Kathrein - Electronic Tilt Adjuster (FlexRET)');

INSERT INTO hardware (code, name, description) VALUES ('472748A', 'FYGB', 'GPS GLONASS Receiver Antenna');
INSERT INTO hardware (code, name, description) VALUES ('472311A', 'FTIF ', 'Flexi Multiradio 10 BTS Transmission Sub-Module');

INSERT INTO hardware (code, name, description) VALUES ('ACU-A20-S', 'TILT ', 'Electronic Tilt Adjuster');








