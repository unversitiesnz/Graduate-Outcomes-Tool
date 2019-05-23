
*************************************************************************************************************************************
*************************************************************************************************************************************

DICLAIMER:
This code has been created for research purposed by Evidence and Evaluation Team, Universities New Zealand. 
The business rules and decisions made in this code are those of author(s) not Statistics New Zealand and Universities New Zealand. 
This code can be modified and customised by users to meet the needs of specific research projects and in all cases, 
Evidence and Evaluation Team, Universities New Zealand must be acknowledged as a source. 
While all care and diligence has been used in developing this code, Statistics New Zealand and Universities New Zealand gives no warranty 
it is error free and will not be liable for any loss or damage suffered by the use directly or indirectly.

*************************************************************************************************************************************
*************************************************************************************************************************************
;
******************************************************************************************************************************************************
PULLING OUT ETHNICITY ACROSS COLLECTIONS

Analyst: Sarah Tumen
QA Analyst: Scott Henwood
Created date: 11 Sep 2014
Code modified : 23 June 2015 to capture youth population as at end of 2013 (aged 15 and above).

******************************************************************************************************************************************************
       Obtaining those records of unique citizen in IDI
	Notes: This includes unique citizen that have records with IRD, MOE, MSD, Justice)
	This includes records of seasonal workers, overseas residents, international students ( at later stage they will be exlcuded from population).
*******************************************************************************************************************************************************;


* adding MOE ethnicity, this is from schooling;
data student_per; set moe.student_per;
if substr(moe_spi_eth1_text,1,1)='1' or substr(moe_spi_eth2_text,1,1)='1' or substr(moe_spi_eth3_text,1,1)='1' then moe_spi_ethnic_grp1_snz_ind=1; else moe_spi_ethnic_grp1_snz_ind=0;
if substr(moe_spi_eth1_text,1,1)='2' or substr(moe_spi_eth2_text,1,1)='2' or substr(moe_spi_eth3_text,1,1)='2' then moe_spi_ethnic_grp2_snz_ind=1; else moe_spi_ethnic_grp2_snz_ind=0;
if substr(moe_spi_eth1_text,1,1)='3' or substr(moe_spi_eth2_text,1,1)='3' or substr(moe_spi_eth3_text,1,1)='3' then moe_spi_ethnic_grp3_snz_ind=1; else moe_spi_ethnic_grp3_snz_ind=0;
if substr(moe_spi_eth1_text,1,1)='4' or substr(moe_spi_eth2_text,1,1)='4' or substr(moe_spi_eth3_text,1,1)='4' then moe_spi_ethnic_grp4_snz_ind=1; else moe_spi_ethnic_grp4_snz_ind=0;
if substr(moe_spi_eth1_text,1,1)='5' or substr(moe_spi_eth2_text,1,1)='5' or substr(moe_spi_eth3_text,1,1)='5' then moe_spi_ethnic_grp5_snz_ind=1; else moe_spi_ethnic_grp5_snz_ind=0;
if substr(moe_spi_eth1_text,1,1)='6' or substr(moe_spi_eth2_text,1,1)='6' or substr(moe_spi_eth3_text,1,1)='6' then moe_spi_ethnic_grp6_snz_ind=1; else moe_spi_ethnic_grp6_snz_ind=0;
run;

proc sql;
create table MOE_eth_
as select distinct
snz_uid 
,max(moe_spi_ethnic_grp1_snz_ind) as moe_spi_ethnic_grp1_snz_ind
,max(moe_spi_ethnic_grp2_snz_ind) as moe_spi_ethnic_grp2_snz_ind
,max(moe_spi_ethnic_grp3_snz_ind) as moe_spi_ethnic_grp3_snz_ind
,max(moe_spi_ethnic_grp4_snz_ind) as moe_spi_ethnic_grp4_snz_ind
,max(moe_spi_ethnic_grp5_snz_ind) as moe_spi_ethnic_grp5_snz_ind
,max(moe_spi_ethnic_grp6_snz_ind) as moe_spi_ethnic_grp6_snz_ind
from student_per 
where snz_uid in (select snz_uid from &population)
group by snz_uid
order by snz_uid;

* adding ethniicty from tertiary data;
proc sql;
create table 
MOE_ter_eth_
as select distinct
	snz_uid
	,max(moe_enr_ethnic_grp1_snz_ind) as moe_enr_ethnic_grp1_snz_ind
	,max(moe_enr_ethnic_grp2_snz_ind) as moe_enr_ethnic_grp2_snz_ind
	,max(moe_enr_ethnic_grp3_snz_ind) as moe_enr_ethnic_grp3_snz_ind
	,max(moe_enr_ethnic_grp4_snz_ind) as moe_enr_ethnic_grp4_snz_ind
	,max(moe_enr_ethnic_grp5_snz_ind) as moe_enr_ethnic_grp5_snz_ind
	,max(moe_enr_ethnic_grp6_snz_ind) as moe_enr_ethnic_grp6_snz_ind
from moe.enrolment
where snz_uid in (select snz_uid from &population)
group by snz_uid
order by snz_uid;

 
* adding MSD ethnicity;
proc sql;
create table MSD_eth_
as select distinct
snz_uid 
,max(msd_swn_ethnic_grp1_snz_ind) as msd_swn_ethnic_grp1_snz_ind
,max(msd_swn_ethnic_grp2_snz_ind) as msd_swn_ethnic_grp2_snz_ind
,max(msd_swn_ethnic_grp3_snz_ind) as msd_swn_ethnic_grp3_snz_ind
,max(msd_swn_ethnic_grp4_snz_ind) as msd_swn_ethnic_grp4_snz_ind
,max(msd_swn_ethnic_grp5_snz_ind) as msd_swn_ethnic_grp5_snz_ind 
,max(msd_swn_ethnic_grp6_snz_ind) as msd_swn_ethnic_grp6_snz_ind
from msd.msd_swn
where snz_uid in (select snz_uid from &population)
group by snz_uid
order by snz_uid;

* adding DIA ethnicity at birth;
proc sql;
create table DIA_eth_
as select distinct
snz_uid 
,max(dia_bir_ethnic_grp1_snz_ind) as dia_bir_ethnic_grp1_snz_ind
,max(dia_bir_ethnic_grp2_snz_ind) as dia_bir_ethnic_grp2_snz_ind
,max(dia_bir_ethnic_grp3_snz_ind) as dia_bir_ethnic_grp3_snz_ind
,max(dia_bir_ethnic_grp4_snz_ind) as dia_bir_ethnic_grp4_snz_ind
,max(dia_bir_ethnic_grp5_snz_ind) as dia_bir_ethnic_grp5_snz_ind
,max(dia_bir_ethnic_grp6_snz_ind) as dia_bir_ethnic_grp6_snz_ind
from DIA.births
where snz_uid in (select snz_uid from &population)
group by snz_uid
order by snz_uid;

* statnz ethnicity;
proc sql;
create table SNZ_eth_
as select distinct
snz_uid 
,max(snz_ethnicity_grp1_nbr) as snz_ethnicity_grp1_nbr
,max(snz_ethnicity_grp2_nbr) as snz_ethnicity_grp2_nbr
,max(snz_ethnicity_grp3_nbr) as snz_ethnicity_grp3_nbr
,max(snz_ethnicity_grp4_nbr) as snz_ethnicity_grp4_nbr
,max(snz_ethnicity_grp5_nbr) as snz_ethnicity_grp5_nbr
,max(snz_ethnicity_grp6_nbr) as snz_ethnicity_grp6_nbr
from data.personal_detail
where snz_uid in (select snz_uid from &population.)
group by snz_uid
order by snz_uid;


data project._IND_ethnicity_&date.; merge  
snz_eth_ 
DIA_eth_ 
MSD_eth_ 
MOE_eth_
MOE_ter_eth_
/*MOH_eth_*/
;by snz_uid;
run;

proc datasets lib=work;
delete 
snz_eth_ 
DIA_eth_ 
MSD_eth_ 
MOE_eth_
MOE_ter_eth_ 
/*MOH_eth_*/
;
run;
