
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
******************************************************************************************************************************************************************
******************************************************************************************************************************************************************
PART 1 Counting provider counts for all tabs
PART 2 Counting employer counts for those who have employment status
****************************************************************************************************************************************************************
****************************************************************************************************************************************************************
PART 1: Count of education providers

We will count education providers that student completed qualification from
for every tabulation we are doing for now

****************************************************************************************************************************************************************
****************************************************************************************************************************************************************;
* spliting datatsets; 
* (SCH): include only arrays which we are using ;
data final_dataset;
set project._FINAL_DATASET_RAW (keep= snz_uid refdate2 OS_da_post: 
ter_post_da_prog: ter_post_enr_uni: 
total_da_onben_post: JS_all_da_post: 
not_in_lab_force: has_young_child:
WNS_ind: WNS_SEI_ind: WNS_reg_ch:
WNS_ta_ch:
WNS_pbn_ch:
ter_com_provider 
WNS_pbn_:
domestic COHORT TER_COM_SUBSECTOR TER_COM_QUAL_TYPE domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED
young_grad);

run;

data domestic intern; set final_dataset; 
if domestic=1 then output domestic;
if domestic=0 then output intern;
run;

		%macro provider_count(dataset,indicator,condition);
		%put Start time - &indicator.: %sysfunc(time(), time.);
			%macro loop_provider(indicator,mth,condition);
			data prov_count_&mth.; 
			set &dataset.;
			if &indicator._&mth. &condition.;
			mth=&mth.;
			ter_provider_count=1;
			keep &Classvar. ter_com_provider mth  ter_provider_count;

			proc sort data=prov_count_&mth. nodupkey; by &classvar. mth ter_com_provider;
			proc summary data=prov_count_&mth. nway;
			class &classvar. mth;
			var ter_provider_count;
			output out=provider_temp_&mth(drop=_:) sum=;
			run;
			%mend;

		%do mth=&firstm. %to &lastm.;
		 %loop_provider(&indicator.,&mth.,&condition.);
		%end;

		data Prov_&indicator.;
		set provider_temp_:;
		length ind $ 19;
		ind="&indicator.";
		run;

		proc datasets lib=work;
		delete provider_temp_: prov_count:;
		run;
		%put End time - &indicator.: %sysfunc(time(), time.);
		%mend;




*%provider_c(domestic,OS_da_post,=1);
*run;
* Scott, test it;
* Cohorts each, batch 1;
	*	options mfile mprint;
		*filename mprint "&path.logs/08_provider_counts1.sas";

%macro prov_counts_all_DOM(dataset, outputname);
		%put Start time - &outputname.: %sysfunc(time(), time.);
%provider_count(&dataset.,OS_da_post,=1);
%provider_count(&dataset.,ter_post_da_prog,=1);
%provider_count(&dataset.,ter_post_enr_uni,=1);
%provider_count(&dataset.,ter_post_enr_uni_hi,=1);
%provider_count(&dataset.,ter_post_enr_uni_lo,=1);
%provider_count(&dataset.,total_da_onben_post,=1);
%provider_count(&dataset.,JS_all_da_post,=1);
%provider_count(&dataset.,WNS_ind,=1);
%provider_count(&dataset.,WNS_SEI_ind,=1);
%provider_count(&dataset.,WNS_reg_ch,=1);
%provider_count(&dataset.,WNS_ta_ch,=1);
%provider_count(&dataset.,WNS_pbn_ch,=1);
%provider_count(&dataset.,neet,=1);
%provider_count(&dataset.,not_in_lab_force,=1);
%provider_count(&dataset.,has_young_child,=1);

data &outputname.;
set Prov_:;
length ind $ 19;
run;

proc datasets lib=work;
delete prov_:;
run;
%put End time - &outputname.: %sysfunc(time(), time.);
%mend;

%macro prov_counts_all_INT(dataset, outputname);
		%put Start time - &outputname.: %sysfunc(time(), time.);
%provider_count(&dataset.,OS_da_post,=1);
%provider_count(&dataset.,ter_post_da_prog,=1);
%provider_count(&dataset.,ter_post_enr_uni,=1);
%provider_count(&dataset.,ter_post_enr_uni_hi,=1);
%provider_count(&dataset.,ter_post_enr_uni_lo,=1);
%provider_count(&dataset.,WNS_ind,=1);
%provider_count(&dataset.,WNS_SEI_ind,=1);
%provider_count(&dataset.,WNS_reg_ch,=1);
%provider_count(&dataset.,WNS_ta_ch,=1);
%provider_count(&dataset.,WNS_pbn_ch,=1);
%provider_count(&dataset.,neet,=1);
%provider_count(&dataset.,not_in_lab_force,=1);
%provider_count(&dataset.,has_young_child,=1);
data &outputname.;
set Prov_:;
length ind $ 19;
run;

proc datasets lib=work;
delete prov_:;
run;
%put End time - &outputname.: %sysfunc(time(), time.);
%mend;

%macro prov_counts_denom_DOM(dataset, outputname);
		%put Start time - &outputname.: %sysfunc(time(), time.);
%provider_count(&dataset.,OS_da_post,NE .);
%provider_count(&dataset.,ter_post_da_prog,NE .);
%provider_count(&dataset.,ter_post_enr_uni,NE .);
%provider_count(&dataset.,ter_post_enr_uni_hi,NE .);
%provider_count(&dataset.,total_da_onben_post,NE .);
%provider_count(&dataset.,JS_all_da_post,NE .);
%provider_count(&dataset.,WNS_ind,NE .);
%provider_count(&dataset.,WNS_SEI_ind, NE .);
%provider_count(&dataset.,WNS_reg_ch, NE .);
%provider_count(&dataset.,WNS_ta_ch, NE .);
%provider_count(&dataset.,WNS_pbn_ch, NE .);
%provider_count(&dataset.,neet,NE .);
%provider_count(&dataset.,not_in_lab_force,NE .);
%provider_count(&dataset.,has_young_child,NE .);
data &outputname.;
set Prov_:;
length ind $ 19;
run;

proc datasets lib=work;
delete prov_:;
run;
%put End time - &outputname.: %sysfunc(time(), time.);
%mend;

%macro prov_counts_denom_INT(dataset, outputname);
		%put Start time - &outputname.: %sysfunc(time(), time.);
%provider_count(&dataset.,OS_da_post,NE .);
%provider_count(&dataset.,ter_post_da_prog,NE .);
%provider_count(&dataset.,ter_post_enr_uni,NE .);
%provider_count(&dataset.,ter_post_enr_uni_hi,NE .);
%provider_count(&dataset.,WNS_ind,NE .);
%provider_count(&dataset.,WNS_SEI_ind, NE .);
%provider_count(&dataset.,WNS_reg_ch, NE .);
%provider_count(&dataset.,WNS_ta_ch, NE .);
%provider_count(&dataset.,WNS_pbn_ch, NE .);
%provider_count(&dataset.,neet,NE .);
%provider_count(&dataset.,not_in_lab_force,NE .);
%provider_count(&dataset.,has_young_child,NE .);
data &outputname.;
set Prov_:;
length ind $ 19;
run;

proc datasets lib=work;
delete prov_:;
run;
%put End time - &outputname.: %sysfunc(time(), time.);
%mend;

%let Classvar=cohort domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type young_grad;
%prov_counts_all_DOM(domestic, Provider_domestic1);
%prov_counts_denom_DOM(domestic, Provider_domestic1_de);

%let Classvar=cohort domestic ter_com_subsector ter_com_qual_type;
%prov_counts_all_INT(intern, Provider_intern1);
%prov_counts_denom_INT(intern, Provider_intern1_de);


data Provider_batch1;
set Provider_domestic1 Provider_intern1;
dataset='dataset1';
run;

* combined cohorts, batch 2;
data domestic2 intern2; set final_dataset; 
if domestic=1 then output domestic2;
if domestic=0 then output intern2;
if cohort in (2009, 2010, 2011);
run;
%let Classvar=domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED young_grad;
%prov_counts_all_DOM(domestic2, Provider_domestic2);
%prov_counts_denom_DOM(domestic2, Provider_domestic2_de);

%let Classvar=domestic ter_com_subsector ter_com_qual_type ter_com_NZSCED;
%prov_counts_all_INT(intern2, Provider_intern2);
%prov_counts_denom_INT(intern2, Provider_intern2_de);


	data Provider_batch2;
	set Provider_domestic2 Provider_intern2;
	dataset='dataset2';
	run;

* Consolidate batches 1 nd 2;
data Provider_count;
set  Provider_batch1  Provider_batch2;
run;

data project.provider_count;
set Provider_count;
run;
* to be merged with CUBE data;

data Provider_batch1_de;
set Provider_domestic1_de Provider_intern1_de;
dataset='dataset1';
*if domestic = 0 and ind in ("JS_all_da_post", "total_da_onben_post") then delete; * remove benefit counts for international students ;
run;
	data Provider_batch2_de;
	set Provider_domestic2_de Provider_intern2_de;
	dataset='dataset2';
*	if domestic = 0 and ind in ("JS_all_da_post", "total_da_onben_post") then delete; * remove benefit counts for international students ;
	run;
* Consolidate batches 1 nd 2;
data Provider_count_denom;
set  Provider_batch1_de  Provider_batch2_de;
run;

data project.provider_count_denom;
set Provider_count_denom;
run;
* to be merged with CUBE data;

* merge in provider counts into cube ;
proc sql;

create table cube_prov_count as 
select /*substr(cube.ind, 1, 14) as short_ind,*/ cube.*, pc.ter_provider_count, dc.ter_provider_count as ter_prov_count_denom from project.CUBE cube 
left join project.provider_count pc
on cube.ind = pc.ind and cube.domestic = pc.domestic 
and cube.ter_com_subsector = pc.ter_com_subsector 
and cube.snz_sex_code = pc.snz_sex_code
and cube.demo_eth = pc.demo_eth
and cube.ter_com_qual_type = pc.ter_com_qual_type
and cube.ter_com_NZSCED = pc.ter_com_NZSCED
and cube.month = pc.mth
and cube.dataset = pc.dataset
and cube.cohort = pc.cohort 
and cube.young_grad = pc.young_grad
left join project.provider_count_denom dc
on cube.ind = dc.ind and cube.domestic = dc.domestic 
and cube.ter_com_subsector = dc.ter_com_subsector 
and cube.snz_sex_code = dc.snz_sex_code
and cube.demo_eth = dc.demo_eth
and cube.ter_com_qual_type = dc.ter_com_qual_type
and cube.ter_com_NZSCED = dc.ter_com_NZSCED
and cube.month = dc.mth
and cube.dataset = dc.dataset 
and cube.cohort = dc.cohort
and cube.young_grad = dc.young_grad
;
quit;
data project.cube_prov_count;
set cube_prov_count;
run;
* You can now check anything that does not depend on employer data. ;
* split into datasets which need employer data and don't ;

data cube_prov_only cube_emp_needed;
set project.cube_prov_count;
if ind in ("WNS_SEI_ind", "WNS_ta_ch", "WNS_reg_ch", "WNS_pbn_ch") then output cube_emp_needed;
else output cube_prov_only;
run;

* save unrounded counts ;
data cube_prov_only;
set cube_prov_only;
if dataset = 'dataset1' and ( 
	(cohort = 2012 and month >= 60) or 
	(cohort = 2013 and month >= 48) or 
	(cohort = 2014 and month >= 36) or 
	(cohort = 2015 and month >= 24) or 
	(cohort = 2016 and month >= 12) ) 
then delete; 
unrounded_denom = denom;
unrounded_num = num;

run;

*apply rounding ;
%rr3(cube_prov_only, cube_rr3_a, num);
%rr3(cube_rr3_a, cube_rr3, denom);
proc format;
value suppressableV
	. = "..S"	
;
quit;

* suppress counts with less than two underlining educational entities ;
data cube_rr3nS;
set cube_rr3;
if unrounded_num < 6 then num = .;
else if unrounded_num = 6 then num = 6;
if unrounded_denom < 6 then denom = .;
else if unrounded_denom = 6 then denom = 6;
if ter_provider_count < 2 then do;
num = .;
end;
if ter_prov_count_denom < 2 then do;
denom = .;
end;

Format num denom suppressableV.;
run;

data project.cube_rr3nS;
set cube_rr3nS;
run;
/*
data project.cube_prov_suppression;
set cube_prov_suppression;
run;
*/

*******************************************************************************************************************************************************************
*******************************************************************************************************************************************************************
PART 2 
Counting employer for those who worked and were self employed
Not doing it for every split
*******************************************************************************************************************************************************************
*******************************************************************************************************************************************************************;
%macro employer_count(dataset,indicator,condition, employer);
	%put Start time - &indicator.: %sysfunc(time(), time.);
		%macro loop_provider(indicator,mth,condition, employer);
			data emp_count_&mth.; 
			set &dataset.;
			if &indicator._&mth. &condition.;
			mth=&mth.;
			emp_employer_count=1;
			keep &Classvar. &employer._&mth. mth  emp_employer_count;

			proc sort data=emp_count_&mth. nodupkey; by &classvar. mth &employer._&mth.;
			proc summary data=emp_count_&mth. nway;
			class &classvar. mth;
			var emp_employer_count;
			output out=employer_temp_&mth(drop=_:) sum=;
			run;
		%mend;
	%do mth=&firstm. %to &lastm.;
	 %loop_provider(&indicator.,&mth.,&condition., &employer.);
	%end;

	data Emp_&indicator.;
	set employer_temp_:;
	length ind $ 19;
	ind="&indicator.";
	run;

	proc datasets lib=work;
	delete employer_temp_: emp_count_:;
	run;
	%put End time - &indicator.: %sysfunc(time(), time.);
%mend;
* batch 1 ;
%let Classvar=cohort domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type young_grad;
%employer_count(domestic,WNS_ind,=1, WNS_pbn);
%employer_count(domestic,WNS_SEI_ind,=1, WNS_pbn);
%employer_count(domestic,WNS_ta_ch,=1, WNS_pbn);
%employer_count(domestic,WNS_reg_ch,=1, WNS_pbn);
%employer_count(domestic,WNS_pbn_ch,=1, WNS_pbn);
data employer_domestic1;
set Emp_:;
length ind $ 19;
run;
%let Classvar=cohort domestic ter_com_subsector ter_com_qual_type;
%employer_count(intern,WNS_ind,=1, WNS_pbn);
%employer_count(intern,WNS_SEI_ind,=1, WNS_pbn);
%employer_count(intern,WNS_ta_ch,=1, WNS_pbn);
%employer_count(intern,WNS_reg_ch,=1, WNS_pbn);
%employer_count(intern,WNS_pbn_ch,=1, WNS_pbn);
data employer_intern1;
set Emp_:;
length ind $ 19;
run;

data Employer_batch1;
	set employer_domestic1 employer_intern1;
	dataset='dataset1';
	run;
* batch 2 ;
%let Classvar=domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED young_grad;
%employer_count(domestic2,WNS_ind,=1, WNS_pbn);
%employer_count(domestic2,WNS_SEI_ind,=1, WNS_pbn);
%employer_count(domestic2,WNS_ta_ch,=1, WNS_pbn);
%employer_count(domestic2,WNS_reg_ch,=1, WNS_pbn);
%employer_count(domestic2,WNS_pbn_ch,=1, WNS_pbn);
data employer_domestic2;
set Emp_:;
length ind $ 19;
run;
%let Classvar=domestic ter_com_subsector ter_com_qual_type ter_com_NZSCED;
%employer_count(intern2,WNS_ind,=1, WNS_pbn);
%employer_count(intern2,WNS_SEI_ind,=1, WNS_pbn);
%employer_count(intern2,WNS_ta_ch,=1, WNS_pbn);
%employer_count(intern2,WNS_reg_ch,=1, WNS_pbn);
%employer_count(intern2,WNS_pbn_ch,=1, WNS_pbn);
data employer_intern2;
set Emp_:;
length ind $ 19;
run;

data Employer_batch2;
set employer_domestic2 employer_intern2;
dataset='dataset2';
run;

data project.employer_count;
set  Employer_batch2  Employer_batch1;
run;

data wns_emp_count employer_count;
set project.employer_count;
if ind = 'WNS_ind' then do;
	ind = 'WNS';
	output wns_emp_count;
end;
else output employer_count;
run;

proc sql;
create table project.cube_pbn_prov_count as
select cube.*, emp.emp_employer_count from cube_emp_needed cube left join employer_count emp
on cube.ind = emp.ind and cube.domestic = emp.domestic 
and cube.ter_com_subsector = emp.ter_com_subsector 
and cube.snz_sex_code = emp.snz_sex_code
and cube.demo_eth = emp.demo_eth
and cube.ter_com_qual_type = emp.ter_com_qual_type
and cube.ter_com_NZSCED = emp.ter_com_NZSCED
and cube.month = emp.mth
and cube.dataset = emp.dataset
and cube.cohort = emp.cohort 
and cube.young_grad = emp.young_grad
;
quit;

data work.cube_pbn_prov_count1;
set  project.cube_pbn_prov_count;
if dataset = 'dataset1' and ( 
	(cohort = 2012 and month >= 60) or 
	(cohort = 2013 and month >= 48) or 
	(cohort = 2014 and month >= 36) or 
	(cohort = 2015 and month >= 24) or 
	(cohort = 2016 and month >= 12) ) 
then delete; 
unrounded_denom = denom;
unrounded_num = num;
run;

*apply rounding ;
%rr3(cube_pbn_prov_count1, cube_pbn_prov_count1_a, num);
%rr3(cube_pbn_prov_count1_a, cube_pbn_prov_count_rr3, denom);
* apply suppression ;
data project.cube_pbn_prov_rr3nS;
set cube_pbn_prov_count_rr3;
if unrounded_num < 6 then num = .;
else if unrounded_num = 6 then num = 6;
if unrounded_denom < 6 then denom = .;
else if unrounded_denom = 6 then denom = 6;
if ter_provider_count < 2 then do;
num = .;
end;
if ter_prov_count_denom < 2 then do;
denom = .;
end;
if emp_employer_count < 3 then do;
num = .;
end;

Format num denom suppressableV.;
run;

************* WNS Means and Medians ****************;



data wns_provider_count_denom;
set project.provider_count_denom;
if ind = 'WNS_ind';
ind = 'WNS';
run;
data wns_provider_count;
set project.provider_count;
if ind = 'WNS_ind';
ind = 'WNS';
run;

* here as a reminder? ;
proc sql;
select count(*) from project.income_CUBE
where ind = 'WNS'
;
quit;

proc sql;

create table cube_emp_count as 
select /*substr(cube.ind, 1, 14) as short_ind,*/ cube.*, pc.ter_provider_count, dc.ter_provider_count as ter_prov_count_denom, emp.emp_employer_count from project.income_CUBE cube
left join wns_provider_count pc
on cube.ind = pc.ind and cube.domestic = pc.domestic 
and cube.ter_com_subsector = pc.ter_com_subsector 
and cube.snz_sex_code = pc.snz_sex_code
and cube.demo_eth = pc.demo_eth
and cube.ter_com_qual_type = pc.ter_com_qual_type
and cube.ter_com_NZSCED = pc.ter_com_NZSCED
and cube.month = pc.mth
and cube.dataset = pc.dataset
and cube.cohort = pc.cohort 
and cube.young_grad = pc.young_grad
left join wns_provider_count_denom dc
on cube.ind = dc.ind and cube.domestic = dc.domestic 
and cube.ter_com_subsector = dc.ter_com_subsector 
and cube.snz_sex_code = dc.snz_sex_code
and cube.demo_eth = dc.demo_eth
and cube.ter_com_qual_type = dc.ter_com_qual_type
and cube.ter_com_NZSCED = dc.ter_com_NZSCED
and cube.month = dc.mth
and cube.dataset = dc.dataset and cube.cohort = dc.cohort
and cube.young_grad = dc.young_grad
left join wns_emp_count emp
on cube.ind = emp.ind and cube.domestic = emp.domestic 
and cube.ter_com_subsector = emp.ter_com_subsector 
and cube.snz_sex_code = emp.snz_sex_code
and cube.demo_eth = emp.demo_eth
and cube.ter_com_qual_type = emp.ter_com_qual_type
and cube.ter_com_NZSCED = emp.ter_com_NZSCED
and cube.month = emp.mth
and cube.dataset = emp.dataset
and cube.cohort = emp.cohort 
and cube.young_grad = emp.young_grad
;
quit;
data project.cube_emp_count;
set cube_emp_count;
run;

* save unrounded counts ;
data project.cube_emp_count;
set project.cube_emp_count;
if dataset = 'dataset1' and ( 
	(cohort = 2012 and month >= 60) or 
	(cohort = 2013 and month >= 48) or 
	(cohort = 2014 and month >= 36) or 
	(cohort = 2015 and month >= 24) or 
	(cohort = 2016 and month >= 12) ) 
then delete; 
unrounded_denom = denom;
unrounded_num = num;
run;
proc format;
picture suppressableV
	. = "..S"	
;
quit;
*apply rounding ;
%rr3(project.cube_emp_count, cube_emp_rr3_a, num);
%rr3(cube_emp_rr3_a, cube_emp_rr3, denom);
* apply suppression ;
data project.cube_emp_rr3nS;
set cube_emp_rr3;
mean = Round(mean, 0.01);
med = Round(med, 0.01);
if unrounded_num < 6 then num = .;
else if unrounded_num = 6 then num = 6;
if unrounded_denom < 6 then denom = .;
else if unrounded_denom = 6 then denom = 6;
if unrounded_num < 10 then do;
	med = .;
end;
if unrounded_num < 20 then do;
	mean = .;
end;
if unrounded_num = 20 and num NE . then do;
	num = 21;
end;
if ter_provider_count < 2 then do;
num = .;
mean = .;
med = .;
end;
if ter_prov_count_denom < 2 then do;
denom = .;
end;
if emp_employer_count < 3 then do;
num = .;
mean = .;
med = .;
end;

Format num denom suppressableV.;
run;


***************************
Following code not used.
;
proc sql;
create table 
employer_WNS as
select 
a.*,
b.* 

from 
project._post_employer_wns_mth_&date. a right join 
study_pop2 b
on a.snz_uid=b.snz_uid and a.refdate2=b.refdate2;

data domestic_WNS intern_WNS; set employer_WNS; 
if domestic=1 then output domestic;
if domestic=0 then output intern;
run;



		proc sql;
		create table 
		employer_SEI as
		select 
		select 
		a.*,
		b.* 

		from 
		project._post_employer_SEI_mth_&date. a right join 
		study_pop2 b
		on a.snz_uid=b.snz_uid and a.refdate2=b.refdate2;

		data domestic_SEI intern_SEI; set employer_SEI; 
		if domestic=1 then output domestic;
		if domestic=0 then output intern;
		run;



%macro employer_count(dataset,type);
	%macro loop_provider(mth);
	data empl_count_&mth.; set &dataset.;
	if &type._empl_&mth.>0;
	mth=&mth.;
	empl_&type._count=1;
	keep &Classvar. &type._empl_&mth. mth  empl_&type._count;

	proc sort data=empl_count_&mth. nodupkey; by &classvar. mth &type._empl_&mth.;
	proc summary data=empl_count_&mth.;
	class &classvar. mth;
	var empl_&type._count;
	output out=empl_&type._&mth(drop=_:) sum=;
	run;
	%mend;	

%do mth=&firstm. %to &lastm.;
 %loop_provider(&mth.);
%end;

data Empl_&dataset.;
set empl_&type._:;
ind='&type.';
run;

proc datasets lib=work;
delete Empl_:;
run;

%mend;

* by each cohort;
%let Classvar=cohort domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ;
%employer_count(domestic_WNS,WnS);
%employer_count(domestic_SEI,SEI);

%let Classvar=cohort domestic ter_com_subsector ter_com_qual_type;
%employer_count(intern_WNS,WnS);
%employer_count(intern_SEI,SEI);


data Empl_count_batch1;
set 
Empl_domestic_WNS  Empl_intern_WNS 
Empl_domestic_SEI  Empl_intern_SEI;
dataset='dataset1';
run;

* combined cohorts; 
%let Classvar=domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED ;
%employer_count(domestic_WNS,WnS);
%employer_count(domestic_SEI,SEI);

%let Classvar=domestic ter_com_subsector ter_com_qual_type ter_com_NZSCED;
%employer_count(intern_WNS,WnS);
%employer_count(intern_SEI,SEI);


data Empl_count_batch2;
set 
Empl_domestic_WNS  Empl_intern_WNS 
Empl_domestic_SEI  Empl_intern_SEI;
dataset='dataset2';
run;

* Combine and merge with CUBE;

data Empl_count;
set Empl_count_batch1 Empl_count_batch2;
run;

