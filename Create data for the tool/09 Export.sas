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
* project.cube_rr3nS
project.cube_pbn_prov_rr3nS
project.cube_emp_rr3nS

;
%let outputCombinedChort = 1;
*************** income ;
data income_wns_a;
retain ind domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED month a_num a_denom a_mean a_med dataset cohort;
set project.cube_emp_rr3nS;
*if dataset = 'dataset1';
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
a_num = num;
a_denom = denom;
a_mean = mean;
a_med = med;
drop num denom mean med;
*drop ter_com_NZSCED;
run;
%macro convert_na_to_s(input_var, output_var);
if &input_var = . then &output_var = '..S';
else &output_var = &input_var;
%mend;
data income_wns;
retain ind domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED month dataset cohort num denom mean median ;
set income_wns_a;
length num $ 7 denom $ 7 mean $ 8 median $ 8;
%convert_na_to_s(a_num, num);
%convert_na_to_s(a_denom, denom);
%convert_na_to_s(a_mean, mean);
%convert_na_to_s(a_med, median);
drop a_num a_denom a_mean a_med;
*drop ter_com_NZSCED;
run;
******************* provider only ;
data cube_provider_only_a;
retain ind domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED month a_num a_denom dataset cohort;
set project.cube_rr3nS;
*if dataset = 'dataset1';
if ter_provider_count < 2 then do;
num = .;
end;
if ter_prov_count_denom < 2 then do;
denom = .;
end;

a_num = num;
a_denom = denom;
drop num denom;
*drop ter_com_NZSCED;
run;

data cube_provider_only;
retain ind domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED month dataset cohort num denom;
set cube_provider_only_a;
length num $ 7 denom $ 7;
*length dataset_code $ 1;
%convert_na_to_s(a_num, num);
%convert_na_to_s(a_denom, denom);
/*if ter_com_subsector = 'University' then subsector = 1;
else subsector = 2;
sex_code = int(snz_sex_code);
if dataset = "dataset1" then dataset_code = 1;
else dataset_code = 2;*/
drop a_num a_denom;
*drop ter_com_NZSCED;
run;

******************* provider and employer ;
data cube_provider_emp_a;
retain ind domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED month a_num a_denom dataset cohort;
set project.cube_pbn_prov_rr3nS;
*if dataset = 'dataset1';
if ter_provider_count < 2 then do;
num = .;
end;
if ter_prov_count_denom < 2 then do;
denom = .;
end;
if emp_employer_count < 3 then do;
num = .;
end;
a_num = num;
a_denom = denom;
drop num denom;
*drop ter_com_NZSCED;
run;

data cube_provider_emp;
retain ind domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED month dataset cohort num denom;

set cube_provider_emp_a;
length num $ 7 denom $ 7;
%convert_na_to_s(a_num, num);
%convert_na_to_s(a_denom, denom);
drop a_num a_denom;
*drop ter_com_NZSCED;
run;

* list the indicators in each set: ;
proc sql;
select distinct ind from cube_provider_only;
select distinct ind from cube_provider_emp;
select distinct ind from income_wns;
quit;

* split into datasets to emailing size! ;
%macro export_data(name);
proc export
	data=cube_&name
	dbms=xlsx
	outfile="&path.outputs/cube_&name..xlsx"
	replace;
run;

%mend;

data cube_benefit cube_overseas cube_ter cube_uni cube_not_in_lab cube_job_seekers cube_uni_hi;
set cube_provider_only;
if ind in ('JS_all_da_post') then output cube_job_seekers;
if ind = 'total_da_onben_post' then output cube_benefit;
if ind in ('OS_da_post') then output cube_overseas;
if ind in ('ter_post_da_prog') then output cube_ter;
if ind in ('ter_post_enr_uni') then output cube_uni;
if ind = 'ter_post_enr_uni_hi' then output cube_uni_hi;
if ind in ('not_in_lab_force') then output cube_not_in_lab;
run;
%export_data(overseas);
%export_data(benefit);
%export_data(job_seekers);
%export_data(ter);
%export_data(uni);
%export_data(uni_hi);
%export_data(not_in_lab);

data cube_reg_mobility cube_ta_mobility cube_employer_change cube_wns_sei;
set cube_provider_emp;
if ind in ('WNS_reg_ch') then output cube_reg_mobility;
if ind = 'WNS_ta_ch' then output cube_ta_mobility;
if ind in ('WNS_pbn_ch') then output cube_employer_change;
if ind in ('WNS_SEI_ind') then output cube_wns_sei;
run;
%export_data(reg_mobility);
%export_data(ta_mobility);
%export_data(employer_change);
%export_data(wns_sei);

data cube_wns_income;
set income_wns;
run;
%export_data(wns_income);
