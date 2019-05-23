
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

*******************************************************************************************************************************
Create tertiary enrolment history for given population
*******************************************************************************************************************************;

proc sql;
	create table ter_enrol as
	SELECT distinct 
		a.snz_uid
		,a.moe_enr_year_nbr as year
		,a.moe_enr_prog_start_date as startdate
		,a.moe_enr_prog_end_date as enddate
		,a.moe_enr_efts_consumed_nbr as EFTS_consumed
		,a.moe_enr_efts_prog_years_nbr as EFTS_prog_yrs
		,a.moe_enr_qacc_code as qacc format $lv8id.
		,a.moe_enr_qual_code as Qual
		,substr(a.moe_enr_prog_nzsced_code,1,2) as NZSCED format $field.
/*		,(case when a.moe_enr_funding_srce_code NOT in ('02','06','11','13','21') then 1 else 0 end) as Formal*/
		,a.moe_enr_provider_code as provider
		,a.moe_enr_subsector_code as subsector format $subsector.
		,a.moe_enr_qual_level_code as level
		,a.moe_enr_qual_type_code as qual_type
		,b.DOB
	FROM moe.enrolment a inner join &population. b
	on a.snz_uid=b.snz_uid
		WHERE year(a.moe_enr_prog_start_date)>=2003
		order by snz_uid;
quit;

* ;

data ter_enrol; set ter_enrol;
* doing obvious clean ups without restricting population;
	if EFTS_consumed>0;
	if enddate-startdate>0;
	enr_level=1*level;
* this is inherited form MOE code;
	* Checking 8327 and 9043 and 7637... ;
	* Sep 2016 IDI release: ;
	* 8327: Two quals in 2003 - 2014, always lv8id = "5" so this error is now fixed in the raw data :) ;
	* 9043: PC3092 at lv8id = "6" in 2003 to 2013, PC5000 at lv8id = "5" from 2013 on ;
	* 7637: College of Law - doublechecking that all quals are "5" and indeed they are :) ;
if provider = "8327" then qacc = "5"; * not sure we have to have them here, but anyway;
if provider = "9043" then qacc = "5";
run;

%freq(ter_enrol,enr_level*qual_type subsector qacc NZSCED);

data project.Tertiary_enrol_raw_&date.; 
set ter_enrol;
run;

proc datasets lib=work;
delete enr_: ter:;
run;
