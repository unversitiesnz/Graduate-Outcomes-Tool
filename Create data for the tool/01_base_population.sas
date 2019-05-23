
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

***********************************************************************************************************************************
***********************************************************************************************************************************

PART 1 : Creating a base population to work with
We have to create base population so that we can run macros to create variables that will help to refine the population later.
Part 1 does it.

***********************************************************************************************************************************
***********************************************************************************************************************************;

* We can follow outcomes of graduate cohorts 2003-2012 for at least 5 years post completion;

proc sql;
create table 
TEMP_compl
as select distinct 
snz_uid 
from moe.completion 
where moe_com_year_nbr>=&first_anal_yr.-5 and moe_com_year_nbr<=&last_anal_yr.;

* extracting snz_uids;
proc sql;
	*Connect to ODBC (dsn=idi_clean_&version._srvprd user="statsnz\&sysuserid " password="&sqlpass");
	%connectsql(dsn=idi_clean_&version._srvprd);
	create table CONC as select * from connection to  ODBC
		(select 
			snz_uid, 
			snz_ird_uid, 
			snz_dol_uid, 
			snz_moe_uid, 
			snz_msd_uid,
			snz_dia_uid,
			snz_moh_uid, 
			snz_jus_uid from security.concordance)
where snz_uid>0 and snz_uid in (select snz_uid from TEMP_compl)
order by snz_uid;
quit;

* extracting personal details from concordance table;
proc SQL;
	%connectsql(dsn=idi_clean_&version._srvprd);
	create table PERS as select * from connection to  ODBC
		(select 
			snz_uid, 
			snz_sex_code,
			snz_birth_year_nbr,
			snz_birth_month_nbr,
			snz_ethnicity_grp1_nbr,
			snz_ethnicity_grp2_nbr,
			snz_ethnicity_grp3_nbr,
			snz_ethnicity_grp4_nbr,
			snz_ethnicity_grp5_nbr,
			snz_ethnicity_grp6_nbr,
			snz_deceased_year_nbr,
			snz_deceased_month_nbr,
			snz_person_ind,
			snz_spine_ind
		from data.personal_detail)
where snz_uid in (select snz_uid from CONC)
order by snz_uid;
quit;

* This definition of the cohorts includes international students, overseas residents, deceased as at today and other subgroups of population, these subgroups need to be identified
* We will create indicators that will help to define population of interest;

* We decided to run this refresh for cohort 1990;
data BASE;
	merge conc (in=a) pers (in=b);
	by snz_uid;
	if a and b;

	* Limiting to actual people;
/*	if snz_spine_ind=1;*/

	* This is to limit to people only who linked to the spine;
	format DOB DOD date9.;
	DOB=MDY(snz_birth_month_nbr,15,snz_birth_year_nbr);

	if snz_deceased_year_nbr ne . then do;
	DOD=MDY(snz_deceased_month_nbr,15,snz_deceased_year_nbr);
	end;	

if snz_person_ind=1;
if snz_birth_year_nbr ne .;
run;

* lets create indicators of international student using schooling information as well as Tertiary enrolment datasets;
* schooling international student;
proc sql;
create table School_intern_list
as select distinct
	snz_uid
   ,1 as sch_intern
   from moe.student_per
   where moe_spi_domestic_status_code not in ('60000', '60001', '60002', '60003', '60005', '60006', '60007', '60012' )
   and snz_uid in (select distinct snz_uid from BASE)
order by snz_uid;
quit;

* tertiary international student;
proc freq data=moe.enrolment;
tables moe_enr_year_nbr*moe_enr_is_domestic_ind ;
run;

proc sql;
create table Tert_intern_list
as select distinct
	snz_uid,
	moe_enr_country_code as country,
	put(moe_enr_country_code,$citreg.) as  citizen_region 
   ,1 as tert_intern
   from moe.enrolment
   where moe_enr_is_domestic_ind='0'
   and snz_uid in (select distinct snz_uid from BASE)
order by snz_uid;
quit;

* might be some records showing studnets having two countries of residency for international students, picking up randomly one;
proc sort data=Tert_intern_list nodupkey; by snz_uid; run;

data project.POPULATION_base; 
merge BASE School_intern_list Tert_intern_list;
by snz_uid;
domestic=1;
if tert_intern=1 or sch_intern=1 then domestic=0;
* was at some point international students , sourced from school enrol and tertiary enrol datasets;
run;

%freq( project.POPULATION_base,DOB snz_birth_year_nbr domestic*citizen_region);
%freq( project.POPULATION_base,country*domestic);

***************************************************************************************************************************************;
