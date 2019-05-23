
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
******************************************************************************************************************************************************************;
* or use dataset permanently saved after all variables are plugged; 
%let finaldataset=project._final_dataset_raw;

data Study_pop;
set &finaldataset.; 
run;

%contents(Study_pop);
proc format;
value agebands
low-24='1 Under24'
25-29='2 25-29'
30-34='3 30-34'
35-high='4 35-above';
run;
Data domestic intern; set Study_pop;
demo_eth=5; * MELAA and others are grouped together with missing;
	if moe_enr_ethnic_grp1_snz_ind=1 then demo_eth=1;
	if moe_enr_ethnic_grp4_snz_ind=1 then demo_eth=4;
	if moe_enr_ethnic_grp3_snz_ind=1 then demo_eth=3;
	if moe_enr_ethnic_grp2_snz_ind=1 then demo_eth=2;

	if domestic=0 then demo_eth=6; *if international student, we dont care about ethnicity, na category, not applying ethnicity to international students;
	agebands=put(ageat31Dec,agebands.);
Count=1;
* grouping small counts;
if ter_com_qual_type in ('Level 1-3 certificates','Level 4 Certificates') then ter_com_qual_type='Level 1-4 Certificates';
* giving restrictions by age;
ter_com_subsector_org=ter_com_subsector;
if ter_com_subsector ne 'University' then ter_com_subsector='non-University'; else  ter_com_subsector='University';
if domestic=1 then output  domestic ;
if domestic=0 then output  intern ;
run;

%macro sumup(dataset,var,ind);
	proc summary data=&dataset. nway;

	class &classvar. &var.; 
	var count;
	output out=&Var. sum=count_raw;
	run;

	proc sort data=&dataset. out=tempdata nodupkey; by &Classvar. &var.  ter_com_provider; run;

	proc summary data=tempdata nway;
	class &classvar. &var.;
	var count;
	output out=&var._prov sum=prov_count;
	run;

data &ind._&var.; 
merge &Var. &var._prov;
by &Classvar. &var. ;
drop _:;
length ind $3.;
ind="&ind.";
run;
%mend;

* for domestic students, if cohorts selected present age breakdown;
%let Classvar=cohort domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type;
%sumup(domestic,agebands,d1);

* for international students, present age breakdwon and region;
%let Classvar=cohort domestic ter_com_subsector ter_com_qual_type;
%sumup(intern,agebands,d31);
%sumup(intern,citizen_region,d32);

* IF pooled cohorts and broken down by field of study, no supplementary tables; 
data ALL_desc;
retain ind cohort domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED agebands citizen_region ; 
set D1: D3: ;
run;

* create rounded counts;

%rr3(ALL_desc,ALL_desc_rr3,count_raw);

data ALL_desc_rr3; set ALL_desc_rr3; rename count_raw=count_rr3;
data ALL; merge ALL_desc ALL_desc_rr3;
if prov_count=1 then suppress=1; else suppress=0;
run;


%freq(all,ind*count_raw );
