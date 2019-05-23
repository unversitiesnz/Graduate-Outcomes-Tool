
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


**********************************************************************************************************************************
Creating tertiary enrolment and completion summary 
This code creates dataset that contains enrolment and completion history
Note that  project.Tertiary_enrol_raw_&date. is not resticted so it covers all years, ever history of enrolment since 2003 first year
enrolment data is available
**********************************************************************************************************************************;
Data enrol_2_ext; 
set project.Tertiary_enrol_raw_&date.; 
if qual_type='D';
* This is clean and unrestricted dataset on all tertiary enrolments for this population;
run;

%contents(enrol_2_ext);

* Creating records of first enrolment and creating records of highest enrolment;
* first enrolment;
proc sort data=enrol_2_ext; by snz_uid startdate; run;

data enrol_first; set enrol_2_ext; by snz_uid startdate; 
if first.snz_uid=1;
	first_enr_qacc=qacc;
	first_enr_level=enr_level;
	first_enr_qual=qual;
	first_enr_NZSCED=NZSCED;
	first_enr_subsector=subsector;
	first_enr_provider=provider;
	first_enr_SUM_EFTS=EFTS_consumed;
	first_enr_startdate=startdate;
	first_enr_enddate=enddate;
keep snz_uid first_:;
format first_enr_startdate first_enr_enddate date9.;
run;

* last enrolment;

data enrol_last; 
set enrol_2_ext; 
by snz_uid startdate; 
if last.snz_uid=1;
	last_enr_qacc=qacc;
	last_enr_level=enr_level;
	last_enr_qual=qual;
	last_enr_NZSCED=NZSCED;
	last_enr_subsector=subsector;
	last_enr_provider=provider;
	last_enr_SUM_EFTS=EFTS_consumed;
	last_enr_startdate=startdate;
	last_enr_enddate=enddate;
keep snz_uid last_:;
format last_enr_startdate last_enr_enddate date9.;
run;

* highest enrolment;
/*SCH 29-08-2018: descending qacc gets the lowest qualification, ascend instead*/

%freq(enrol_2_ext,level qacc);

proc sort data=enrol_2_ext; by snz_uid enr_level; run;

data enrol_high; 
set enrol_2_ext; 
by snz_uid enr_level; 
if last.snz_uid=1;
	high_enr_qacc=qacc;
	high_enr_level=enr_level;
	high_enr_qual=qual;
	high_enr_NZSCED=NZSCED;
	high_enr_subsector=subsector;
	high_enr_provider=provider;
	high_enr_SUM_EFTS=EFTS_consumed;
	high_enr_startdate=startdate;
	high_enr_enddate=enddate;
keep snz_uid high_:;
format high_enr_startdate high_enr_enddate date9.;
run;

* creating summary enrolment record per student regradless of multiple programmes;
proc sql; 
create table Enrol_summary as
select distinct 
	snz_uid,
	sum(EFTS_consumed) as total_efts_consumed,
	min(startdate) as first_enrol_date format date9.,
	max(enddate) as last_enrol_date format date9.
from enrol_2_ext
group by snz_uid
order by snz_uid; 
Quit;

data Enrol_summary; set enrol_summary;
first_enrol_month=month(first_enrol_date);
first_enrol_year=year(first_enrol_date);
last_enrol_month=month(last_enrol_date);
last_enrol_year=year(last_enrol_date);
run;

*******************************************************************************************************************************************************************
****** completions;

proc sql;
	create table TER_compl as
		select  snz_uid,
			moe_com_year_nbr as year,
			moe_com_qual_code as qual,
			moe_com_provider_code as provider,
			put(moe_com_qacc_code,$lv8id.) as qual_type,
			moe_com_qual_level_code as level,
			substr(moe_com_qual_nzsced_code,1,2) as NZSCED 
		from moe.completion
			where snz_uid in
				(select distinct snz_uid from &population.)
					and MDY(12,31,moe_com_year_nbr)<="&sensor"d
			and moe_com_year_nbr>=&first_anal_yr. or moe_com_year_nbr<=&last_anal_yr.;
quit;

data TER_compl; set TER_compl;
com_provider_code=1*provider;
com_level=1*level;
run;

proc sort data=sandmoe.moe_provider_lookup_table Out=moe_provider_lookup_table nodupkey; 
by provider_code; 
run;

* plugin subsector;
proc sql;
create table TER_compl_1
as select 
	a.*,
	b.provider_type as com_provider_type
from TER_compl a 
left join 
moe_provider_lookup_table b
on a.com_provider_code=b.provider_code;

%freq(TER_compl_1,com_level com_provider_type );

* first completion record;
proc sort data=TER_compl_1; by snz_uid year com_level; run;

data compl_first; set TER_compl_1; 
by snz_uid  year com_level; 
if first.snz_uid=1;
	first_com_year=year;
	first_com_qual=qual;
	first_com_level=com_level;
	first_com_qual_type=qual_type;
	first_com_NZSCED=NZSCED; 
	first_com_provider=com_provider_code;
	first_com_subsector=com_provider_type;
keep snz_uid first_: ;
run;

* last completion record;
proc sort data=TER_compl_1; by snz_uid year com_level; run;
data compl_last; set TER_compl_1; by snz_uid  year; 
if last.snz_uid=1;
	last_com_year=year;
	last_com_qual=qual;
	last_com_level=com_level;
	last_com_qual_type=qual_type;
	last_com_NZSCED=NZSCED; 
	last_com_provider=com_provider_code;
	last_com_subsector=com_provider_type;
keep snz_uid last_: ;
run;

*choosing highest completion;
proc sort data=TER_compl_1; by snz_uid descending com_level; run;
data compl_high; set TER_compl_1; by snz_uid descending com_level; if first.snz_uid=1;
	high_com_year=year;
	high_com_qual=qual;
	high_com_level=com_level;
	high_com_qual_type=qual_type;
	high_com_NZSCED=NZSCED; 
	high_com_provider=com_provider_code;
	high_com_subsector=com_provider_type;

keep snz_uid high_:;
run;

proc sort data=&population.; by snz_uid; run;
proc sort data=enrol_first; by snz_uid; run;
proc sort data=enrol_last; by snz_uid; run;
proc sort data=enrol_high; by snz_uid; run;
proc sort data=enrol_summary; by snz_uid; run;

proc sort data=compl_first; by snz_uid; run;
proc sort data=compl_last; by snz_uid; run;
proc sort data=compl_high; by snz_uid; run;

data project._IND_ENROL_COMPL_&date.; 
merge &population.(keep=snz_uid DOB in=a) enrol_summary enrol_first enrol_last enrol_high 
/*compl_first compl_last compl_high*/
; 
by snz_uid; if a; 
format first_enrol_date
last_enrol_date
first_enr_startdate
first_enr_enddate
last_enr_startdate
last_enr_enddate
high_enr_startdate
high_enr_enddate date9.;
run;

proc datasets lib=work;
delete enr: comp: ter: delete;
run;










*********************************************************************************************************************************************************************
*********************************************************************************************************************************************************************

Completion summary 
MOE advised to use last date of enrolment in a programme and extract year in order to define completion year

*********************************************************************************************************************************************************************
*********************************************************************************************************************************************************************;

%contents(compl_2_ext);
%contents(compl_2_ext);


Data compl_2_ext; 
set project.Tertiary_compl_raw_&date.; 
if provider in (336,392,303) then delete; * 2 secondary schools in there;
qacc=qual_type;
if qual_type ne 'Error';
* This is clean and unrestricted dataset on all tertiary completions for this popualtion;
run;

proc sort data =  compl_2_ext out =  compl_2_clean nodupkey;
by snz_uid qual qacc com_level provider subsector ;
run;

* choosing last enrolment year for qual;
proc sql;
create table Enr_qual 
as select 
snz_uid,
qual,
max(year) as year,
min(startdate) as startdate format  date.,
max(enddate) as enddate format date.,
provider,
subsector,
qacc ,
enr_level,
EFTS_prog_yrs
from project.TERTIARY_ENROL_RAW_&date.
where qacc ne 'Error' and qual_type='D'
group by snz_uid, qual, qacc, enr_level , provider, subsector, EFTS_prog_yrs
order by snz_uid, qual, qacc, enr_level , provider, subsector, EFTS_prog_yrs;

/*
SCH 14-3-19: obtain main fields for detailed field of study analysis.
*/
proc sql;
	create table project.MATCHED_ENROL_COMPL_&date. as	
	select 
			a.snz_uid,
			a.year as ter_com_year,
			a.qual as ter_com_qual,
			a.provider as ter_com_provider,
			a.qual_type as ter_com_qual_type,
			a.com_level as ter_com_level,
			a.NZSCED as ter_com_NZSCED,
			a.NZSCED_detailed as ter_com_NZSCED_detailed,
			a.NZSCED_main_1 as ter_com_NZSCED_main_1,
			a.NZSCED_main_2 as ter_com_NZSCED_main_2,
			a.NZSCED_main_3 as ter_com_NZSCED_main_3,
			a.subsector as ter_com_subsector,
		   a.qacc as ter_com_qacc,
		   a.actual_qacc as ter_com_qacc2,

			b.Qual as enr_qual,
			b.year as enr_year,
			b.startdate,
			b.enddate,
			b.provider as enr_provider,
			b.subsector as enr_subsector,
			b.qacc as enr_qacc,
			b.enr_level as enr_level,
			b.EFTS_prog_yrs
	from compl_2_clean a left join  Enr_qual b 
	on a.snz_uid = b.snz_uid and a.provider = b.provider  and a.qual= b.qual  ;
quit;

