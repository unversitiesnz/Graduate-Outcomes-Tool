
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
********************************************************************************************************************************************
********************************************************************************************************************************************

STEP 5:
Creating variables to be used for profiling and refining population

********************************************************************************************************************************************
********************************************************************************************************************************************;
* picking up everybody who completed qual in selected year;
%contents(project.MATCHED_ENROL_COMPL_&date.);

data Study_pop0 missing_enr; 
set project.MATCHED_ENROL_COMPL_&date.;
* if person has an enrolment record, then pick up lats enrolment in a programme as refdate2;

if enddate>0 then do;
	if year(enddate) = enr_year then 
		real_year=year(enddate);
	else real_year=enr_year;
end;
else real_year = ter_com_year;

* restrict it to 3 consequitive cohorts - NOTE: section of code below to change as well.;
if real_year in (2009,2010,2011,2012,2013,2014,2015,2016);
* if real_year in (2012,2013,2014,2015,2016);

cohort=real_year;
keep snz_uid cohort startdate enddate real_year ter_com_: enr_year EFTS_prog_yrs ;
if enr_year = . then output missing_enr;
else output Study_pop0;
run;

proc sort data=Study_pop0 out=Study_pop1 nodupkey; by snz_uid ter_com_qual; run;

* There are about 330 people who than one prog a given year;
* let's define population as people programme;

proc sort data=project.Population_base out=population_base nodupkey; by snz_uid;
proc sort data=project._ind_demog out=_ind_demog nodupkey; by snz_uid;
proc sort data=project._IND_ETHNICITY_&date. out=_IND_ETHNICITY nodupkey; by snz_uid;
proc sort data=project._ind_os_days_yr_&date. out=_ind_os_days_yr nodupkey; by snz_uid;
run;

data project.study_population project.study_pop_removed project.study_pop_removed_os; 
merge
	study_pop1 (in=a )
	population_base (keep=snz_uid DOB DOD snz_: )
	_ind_demog (keep=snz_uid  sch_intern tert_intern domestic citizen_region country res_status demo_migrant) 
	_IND_ETHNICITY (keep=snz_uid moe_enr_ethnic:)
	_ind_os_days_yr
; 
by snz_uid;
if a;
* making obvious exclusions;
/*
if snz_person_ind=1; 
if snz_spine_ind=1; * already done in base population?;
if missing(DOD);
if not missing(DOB);
*/
array OS_da_(*) OS_da_&first_anal_yr.-OS_da_&last_anal_yr.;

	do ind=&first_anal_yr. to &last_anal_yr.;
	i=ind-(&first_anal_yr.-1);
	if OS_da_(i)>=180 then OS_da_(i)=1; else OS_da_(i)=0;
	end;
drop i ind;
* this needs to be changed for moving years as well ;

/*if (cohort=2009 and OS_da_2008=0) or (cohort=2010 and OS_da_2009=0) or (cohort=2011 and OS_da_2010=0) or (cohort=2012 and OS_da_2011=0) or (cohort=2013 and OS_da_2012=0) or (cohort=2014 and OS_da_2013=0) or (cohort=2015 and OS_da_2014=0) or (cohort=2016 and OS_da_2015=0);*/

* if (cohort=2012 and OS_da_2011=0) or (cohort=2013 and OS_da_2012=0) or (cohort=2014 and OS_da_2013=0) or (cohort=2015 and OS_da_2014=0) or (cohort=2016 and OS_da_2015=0);

* allowing mostly studying the year prior to graduation, most of the year;
*if ter_com_subsector_&cohort.='University';

if cohort=2009 then ageat31Dec=floor((intck('month',DOB,'31Dec2009'd)- (day('31Dec2009'd) < day(DOB))) / 12);
if cohort=2010 then ageat31Dec=floor((intck('month',DOB,'31Dec2010'd)- (day('31Dec2010'd) < day(DOB))) / 12);
if cohort=2011 then ageat31Dec=floor((intck('month',DOB,'31Dec2011'd)- (day('31Dec2011'd) < day(DOB))) / 12);
if cohort=2012 then ageat31Dec=floor((intck('month',DOB,'31Dec2012'd)- (day('31Dec2012'd) < day(DOB))) / 12);
if cohort=2013 then ageat31Dec=floor((intck('month',DOB,'31Dec2013'd)- (day('31Dec2013'd) < day(DOB))) / 12);
if cohort=2014 then ageat31Dec=floor((intck('month',DOB,'31Dec2014'd)- (day('31Dec2014'd) < day(DOB))) / 12);
if cohort=2015 then ageat31Dec=floor((intck('month',DOB,'31Dec2015'd)- (day('31Dec2015'd) < day(DOB))) / 12);
if cohort=2016 then ageat31Dec=floor((intck('month',DOB,'31Dec2016'd)- (day('31Dec2016'd) < day(DOB))) / 12);


format refdate2 date9.;
if real_year NE year(enddate) then refdate2=MDY(12,1,real_year);
else if enddate>0 and  month(enddate)<12 then refdate2=MDY(month(enddate)+1,1,year(enddate)); * programme last enr date is known then refdate2 is set to following month;
else if month(enddate)=12 then refdate2=MDY(12,1,year(enddate)); * or if december keep it within a year;
else refdate2=MDY(12,1,real_year); * if no enrolmnet matched, pick up graduation year dec 1 date; 

agebands=put(ageat31Dec,agebands.);

format ter_com_qual_type $outLvl.;
ter_com_qual_type = put(ter_com_qual_type, $outLvlI.);

young_grad = 0;
if ter_com_qual_type = '1' then do;
	if ageat31Dec <= 21 then young_grad = 1;
end;
else if ter_com_qual_type = '2' then do;
	if ageat31Dec <= 23 then young_grad = 1;
end;
else if ter_com_qual_type = '3' then do;

	if EFTS_prog_yrs <= 3 then do; 
		if ageat31Dec <= 24 then young_grad = 1;
	end;
	else do;
		if ageat31Dec <= 24 + (EFTS_prog_yrs - 3) then young_grad = 1;
	end;
end;
else if ter_com_qual_type in ('4') then do;
	if ageat31Dec <= 26 then young_grad = 1;
end;
else if ter_com_qual_type = '5' then do;
	if ageat31Dec <= 27 then young_grad = 1;
end;
else if ter_com_qual_type = '6' then do;
	if ageat31Dec <= 29 then young_grad = 1;
end;
if snz_person_ind=0 or snz_spine_ind=0 or not missing(DOD) or missing(DOB) then output project.study_pop_removed;
else if (cohort=2009 and OS_da_2008=0) or (cohort=2010 and OS_da_2009=0) or (cohort=2011 and OS_da_2010=0) or (cohort=2012 and OS_da_2011=0) or (cohort=2013 and OS_da_2012=0) or (cohort=2014 and OS_da_2013=0) or (cohort=2015 and OS_da_2014=0) or (cohort=2016 and OS_da_2015=0) then output project.study_population;
else output project.study_pop_removed_os;
run;

proc freq data=project.study_population;
tables moe_enr_ethnic_grp2_snz_ind*cohort cohort*domestic  snz_sex_code*cohort cohort*ter_com_subsector 
refdate2*cohort;
run;

