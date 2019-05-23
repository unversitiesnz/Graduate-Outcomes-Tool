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
proc sort data=project.study_population out=test1 nodupkey; by snz_uid refdate2 ter_com_qual;
proc sort data=project.study_population out=test1 nodupkey; by snz_uid refdate2;

proc sort data=project._POST_BEN_adult_mth_&date. out=test1 nodupkey; by snz_uid refdate2;

proc sort data=project._POST_Corr_&date. out=test1 nodupkey; by snz_uid refdate2;

proc sort data=project._post_ter_enr_&date. out=test1 nodupkey; by snz_uid refdate2;

proc sort data=project._POST_EMPLOYER_WNS_MTH_&date. out=test1 nodupkey; by snz_uid refdate2;
proc sort data=project._POST_INC_MTH_&date. out=test1 nodupkey; by snz_uid refdate2;

proc sort data=project._POST_OS_spells_mth_&date. out=test1 nodupkey; by snz_uid refdate2;

proc sort data=study_pop1 out=test1 nodupkey; by snz_uid refdate2 ter_com_qual;


proc sort data=project._FINAL_DATASET_RAW out=test1 nodupkey; by snz_uid refdate2 ter_com_qual;


proc sql;

create table test2 as
select * from &population_1.
where refdate2 = .;
quit;

proc freq data=&population_1.;
where ageat31Dec=>18 and ageat31Dec=<24;
tables cohort*young_grad cohort*domestic cohort*ter_com_subsector cohort*ageat31Dec;
run;

* find all the people who are in the study population but do not have an entry in post study ;
/*
project.study_population
except in
project._POST_TER_ENR_&date.
*/

proc sql;

create table no_post_study as
select p.snz_uid, p.refdate2, cohort 
from project.study_population p
left join project._POST_TER_ENR_&date. s 
on p.snz_uid = s.snz_uid and p.refdate2 = s.refdate2
where s.snz_uid = .;

quit;

* there should not be any enrolment data for the six years following the cohort years. ;

proc sql;

create table any_post_study1 as
select * from moe.enrolment;

quit;

proc sql;
select count(*) from study_pop1
where has_young_child_12 = 1;
quit;

proc sql;
select count(*) from project._post_has_young_child_&date.
where has_young_child_12 = 1;
quit;

data test3;
set project._FINAL_DATASET_RAW;
keep snz_uid ter_com_qual_type ageat31Dec young_grad;
run;

proc freq data=project._FINAL_DATASET_RAW;
table ter_com_qual_type * young_grad;
run;

