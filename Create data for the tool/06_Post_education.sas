
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
Create tertiary enrolment for given population
*******************************************************************************************************************************;

proc sql;
create table ter_enrol_1
as select 
a.*,
b.refdate2,
b.ter_com_qual
from project.TERTIARY_ENROL_RAW_&date. a 
inner join &population_1. b
on a.snz_uid=b.snz_uid
where a.year >= b.cohort;

/* data going back to 2003. Remove redundant data before processing? */

* There might me people with multiple programme enrolments in a given year;
* we will choose the longest enrolment ach charactertistcis of longest enrolment in a given year; 
* Creating annual indicators;

data ter_enrol_TEMP_1; 
set ter_enrol_1;
if refdate2>0;
array ter_enr_da_[*] ter_enr_da_&firstm.-ter_enr_da_&lastm.;
array ter_enr_prog_[*] ter_enr_prog_&firstm.-ter_enr_prog_&lastm. _CHARACTER_ ;
*array ter_enr_prog_sd_[*] ter_enr_prog_sd_&firstm.-ter_enr_prog_sd_&lastm.  ;
*array ter_enr_prog_ed_[*] ter_enr_prog_ed_&firstm.-ter_enr_prog_ed_&lastm.  ;

*array ter_enr_qacc_[*] ter_enr_qacc_&firstm.-ter_enr_qacc_&lastm. _CHARACTER_ ;
*array ter_enr_field_[*] ter_enr_field_&firstm.-ter_enr_field_&lastm. _CHARACTER_ ;
*array ter_enr_EFTS_cons_[*] ter_enr_EFTS_cons_&firstm.-ter_enr_EFTS_cons_&lastm.;
array ter_enr_provider_[*] ter_enr_provider_&firstm.-ter_enr_provider_&lastm. _CHARACTER_;
array ter_enr_subsector_[*] ter_enr_subsector_&firstm.-ter_enr_subsector_&lastm. _CHARACTER_;
array ter_enr_level_[*] ter_enr_level_&firstm.-ter_enr_level_&lastm. ;
*array ter_enr_qual_type_[*] ter_enr_qual_type_&firstm.-ter_enr_qual_type_&lastm. _CHARACTER_;

do ind=&firstm. to &lastm.;
	age=ind-(&firstm.-1);

	start_window=intnx('MONTH',refdate2,age-1,'S');
	end_window=intnx('MONTH',refdate2,age,'S')-1;
	format start_window end_window date9.;

	if not((startdate > end_window) or (enddate < start_window)) then do;

		if (startdate <= start_window) and  (enddate > end_window) then
			days=(end_window-start_window)+1;
		else if (startdate <= start_window) and  (enddate <= end_window) then
			days=(enddate-start_window)+1;
		else if (startdate > start_window) and  (enddate <= end_window) then
			days=(enddate-startdate)+1;
		else if (startdate > start_window) and  (enddate > end_window) then
			days=(end_window-startdate)+1;	

		ter_enr_da_(age)=days;
	end;
	if days>0 then do;
		ter_enr_prog_(age)=qual;
		*ter_enr_prog_sd_(age)=startdate;
		*ter_enr_prog_ed_(age)=enddate;
		*ter_enr_EFTS_cons_(age)=EFTS_consumed;
		ter_enr_provider_(age)=provider;
		ter_enr_subsector_(age)=subsector;
		*ter_enr_field_(age)=NZSCED;
		*ter_enr_qual_type_(age)=qual_type;
		ter_enr_level_(age)=enr_level; * num variable;
	end;

end;

run;
* choosing one record per year, depending on highest EFTS consumed ;
/*
Scott: We are interested in any post study but are prioritising higher level study.
*/
%macro loop_enr_by_year (mth);

data temp_enr_2;
set ter_enrol_TEMP_1 (keep=snz_uid year refdate2 ter_com_qual
	ter_enr_da_&mth.
	ter_enr_prog_&mth.
	ter_enr_provider_&mth.
	ter_enr_subsector_&mth.
	ter_enr_level_&mth.);
if ter_enr_da_&mth. > 0;
run;

proc sort data= temp_enr_2  out=enr_&mth.; 
by snz_uid refdate2 ter_com_qual descending ter_enr_da_&mth. descending ter_enr_level_&mth. ; 
run; 

data enr_&mth.; set enr_&mth.;
by snz_uid refdate2 ter_com_qual descending ter_enr_da_&mth.  descending ter_enr_level_&mth. ; 
if ter_enr_da_&mth.>0;
	rename ter_enr_da_&mth.=ter_post_da_prog_&mth.;
	rename ter_enr_prog_&mth.=ter_post_enr_prog_&mth.;
	rename ter_enr_provider_&mth.=ter_post_enr_provider_&mth.;
	rename ter_enr_subsector_&mth.=ter_post_enr_subsector_&mth.;
	rename ter_enr_level_&mth.=ter_post_enr_level_&mth.;
if last.snz_uid then output;
drop year;
run;
%mend;

	%macro run_all;
		%do mth=&firstm. %to &lastm.;
		%loop_enr_by_year(&mth);
		%end;

	data project._POST_TER_enr_&date.; 
	merge enr_&firstm.-enr_&lastm.;	
	by snz_uid refdate2 ter_com_qual;
	array ter_post_enr_subsector_(*) ter_post_enr_subsector_&firstm.-ter_post_enr_subsector_&lastm.;
	array ter_post_enr_uni_(*) ter_post_enr_uni_&firstm.-ter_post_enr_uni_&lastm.;

	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if ter_post_enr_subsector_(i)='1' then ter_post_enr_uni_(i)=1; else ter_post_enr_uni_(i)=0;

	end;
	drop ind i;
 
	run;

	%mend;

%run_all;


proc datasets lib=work;
delete enr_: ter_:;
run;

%means(project._POST_TER_enr_&date., ter_post_enr_uni_:);

proc means data=project._POST_TER_enr_&date.;
run;

