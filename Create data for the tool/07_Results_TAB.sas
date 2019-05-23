
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
Part 1: GEt ready data for Tabulation
Part 2: Tabulate data for cube
Part 3: Tabulate descriptive tables to run alone side
******************************************************************************************************************************************************************
******************************************************************************************************************************************************************

Part 1: prep data for Tabulation
******************************************************************************************************************************************************************
******************************************************************************************************************************************************************;
data Study_pop; 
set &population_1.; 
run;

proc sql;
create table study_pop1
as select
	a.*,
	i.*,
	b.*,
	c.*,
	d.*,
	/*e.*,*/
	f.*,
	g.*,
	h.*

from Study_pop a 
left join project._post_has_young_child_&date. i
	on a.snz_uid = i.snz_uid and a.refdate2=i.refdate2 and a.ter_com_qual = i.ter_com_qual
left join project._POST_INC_mth_&date. b 
	on a.snz_uid=b.snz_uid and a.refdate2=b.refdate2 and a.ter_com_qual = b.ter_com_qual
left join project._POST_TER_ENR_&date. c 
	on a.snz_uid=c.snz_uid and a.refdate2=c.refdate2 and a.ter_com_qual = c.ter_com_qual
left join project._POST_BEN_adult_mth_&date. d
	on a.snz_uid=d.snz_uid and a.refdate2=d.refdate2 and a.ter_com_qual = d.ter_com_qual
/*left join project._POST_location_&date. e
	on a.snz_uid=e.snz_uid and a.refdate2=e.refdate2*/
left join project._POST_Corr_&date. f 
	on a.snz_uid=f.snz_uid and a.refdate2=f.refdate2 and a.ter_com_qual = f.ter_com_qual
left join project._POST_OS_spells_mth_&date. g 
	on a.snz_uid=g.snz_uid and a.refdate2=g.refdate2 and a.ter_com_qual = g.ter_com_qual
left join project._POST_EMPLOYER_WNS_MTH_&date. h
	on a.snz_uid = h.snz_uid and a.refdate2=h.refdate2 and a.ter_com_qual = h.ter_com_qual
;

* assistant macro to record vars into indicators;
%macro ind_array(var,start,end,days);
array &var._(*) &var._&start.-&var._&end.;

do ind=&start. to &end.;
i=ind-(&start.-1);
			if &var._(i)>=&days. then &var._(i)=1; 
			else &var._(i)=0; 
drop i ind;
end;
%mend;



data study_pop2; set study_pop1;

* transforming into indicators and taking to account being overseas;
* all missing and zero reset to 0 here;

	%ind_array(OS_da_post,&firstm.,&lastm.,15); * if overseas for more than 15 days then Overseas;
	%ind_array(total_da_onben_post,&firstm.,&lastm.,20); * if on benefit for more than 20 days in a month then supported by benefit;
	%ind_array(JS_all_da_post,&firstm.,&lastm.,1); * supported by Job seeker benefit, already an indicator;

	%ind_array(COR_cust_da,&firstm.,&lastm.,20); * If was in custody for 15 days then was in custody status;
	%ind_array(ter_post_da_prog,&firstm.,&lastm.,1); * if enrolled for more than 1 days in formal tertiary institution, then studied;	
	%ind_array(ter_post_enr_uni,&firstm.,&lastm.,1); * if enrolled for more than 1 days in formal tertiary institution, then studied;	
	
	array WNS_(*) WNS_&firstm.-WNS_&lastm.;
	array SEI_inc_(*) SEI_inc_&firstm.-SEI_inc_&lastm.;
	array WNS_ind_(*) WNS_ind_&firstm.-WNS_ind_&lastm.;
	array WNS_inc_(*) WNS_inc_&firstm.-WNS_inc_&lastm.;
	array WNS_SEI_inc_(*) WNS_SEI_inc_&firstm.-WNS_SEI_inc_&lastm.;
	array WNS_SEI_ind_(*) WNS_SEI_ind_&firstm.-WNS_SEI_ind_&lastm.;
	array WNS_reg_ch_(*) WNS_reg_ch_&firstm.-WNS_reg_ch_&lastm.;
	array WNS_ta_ch_(*) WNS_ta_ch_&firstm.-WNS_ta_ch_&lastm.;
	array WNS_uid_ch_(*) WNS_uid_ch_&firstm.-WNS_uid_ch_&lastm.;
	array WNS_pbn_ch_(*) WNS_pbn_ch_&firstm.-WNS_pbn_ch_&lastm.;

	array has_young_child_[*] has_young_child_&firstm.-has_young_child_&lastm.;
	/*
		construct: indicator for WNS; on WNS and/or SEI; Mean and Mediean for WnS; no avg for SEI or ind for SEI alone!
			SEI has some small counts, contracting thus to minimise required suppression.
	*/
	do ind=&firstm. to &lastm.;
	i = ind - &firstm. + 1;
		if (WNS_(i) > 10) then do; 
			* wage & salery yes ;
			WNS_ind_(i) = 1;
			WNS_inc_(i) = WNS_(i);
		end;
		else do; 
			* wage & salery not ;
			WNS_ind_(i) = 0;
			WNS_inc_(i) = .;
		end;
		if (WNS_(i) > 10 or SEI_inc_(i) NE .) then do;
			* has WnS or SEI ;
			* sum(WNS, SEI_inc) ;
			WNS_SEI_ind_(i) = 1;
			WNS_SEI_inc_(i) = WNS_(i) + SEI_inc_(i);
		end;
		else do;
			* has no WnS or SEI ;
			WNS_SEI_ind_(i) = 0;
			WNS_SEI_inc_(i) = .;
		end;
		* soly SEI is not reported at this time (12/10/2018) ;
	end;
	drop ind i WNS_&firstm.-WNS_&lastm.;
	

	array ter_post_enr_level_(*) ter_post_enr_level_&firstm.-ter_post_enr_level_&lastm.;
	array ter_post_enr_uni_hi_(*) ter_post_enr_uni_hi_&firstm.-ter_post_enr_uni_hi_&lastm.;
	array ter_post_enr_uni_lo_(*) ter_post_enr_uni_lo_&firstm.-ter_post_enr_uni_lo_&lastm.;


* taking into account was in country;
	array WNS_ent_type_[*] WNS_ent_type_&firstm.-WNS_ent_type_&lastm. ;
array WNS_ent_sector_[*] WNS_ent_sector_&firstm.-WNS_ent_sector_&lastm. ;
array WNS_anzsic_[*] $ WNS_anzsic_&firstm.-WNS_anzsic_&lastm. ;
array WNS_anzsic2_[*] $ WNS_anzsic2_&firstm.-WNS_anzsic2_&lastm. ;
array WNS_pbn_[*] $ WNS_pbn_&firstm.-WNS_pbn_&lastm. ;
array neet_(*) neet_&firstm.-neet_&lastm.;
array not_in_lab_force_(*) not_in_lab_force_&firstm.-not_in_lab_force_&lastm.;
do ind=&firstm. to &lastm.;
i=ind-(&firstm.-1);

	if has_young_child_(i) = . then has_young_child_(i) = 0;
	
	ter_post_enr_uni_hi_(i)=0;
	ter_post_enr_uni_lo_(i)=0;
	if ter_post_enr_uni_(i)=1 and ter_post_enr_level_(i)>ter_com_level then ter_post_enr_uni_hi_(i)=1; * enrolled at uni at higher level than completed;
	if ter_post_enr_uni_(i)=1 and ter_post_enr_level_(i)<=ter_com_level then ter_post_enr_uni_lo_(i)=1;* enrolled at uni at lower level than completed;

	WNS_ent_type_(i) = substr(WNS_ent_type_(i), 1,1);
	WNS_ent_sector_(i) = substr(WNS_ent_sector_(i), 1,1);
	WNS_anzsic2_(i) = WNS_anzsic_(i);
	WNS_anzsic_(i) = substr(WNS_anzsic_(i), 1,1);
	

* if overseas for more than 15 days and was in custody 20 or more days then take out from calculations all indicators ;
	if OS_da_post_(i)=1 or COR_cust_da_(i)=1 then do;
			total_da_onben_post_(i)=.;
			* COR_cust_da_(i)=.; * don't do that!;
			JS_all_da_post_(i)=.;
			ter_post_da_prog_(i)=.;
			ter_post_enr_uni_(i)=.;
			ter_post_enr_uni_hi_(i)=.;
			ter_post_enr_uni_lo_(i)=.;
			WNS_ind_(i)=.;
			WNS_inc_(i)=.;
			WNS_SEI_ind_(i)=.;
			WNS_SEI_inc_(i)=.;

			WNS_anzsic_(i)='9';
			WNS_anzsic2_(i)='9';

	end;

	if WNS_ind_(i) = 0 and WNS_anzsic_(i) NE '9' then do;
		WNS_anzsic_(i) = '0';
	end;
	else if WNS_pbn_(i) = '' and WNS_anzsic_(i) NE '9' then do;
		WNS_anzsic_(i) = '99';
	end;

	* region changes use the month before. ;
	if i > 1 and ((OS_da_post_(i)=1 or COR_cust_da_(i)=1) or (WNS_ind_(i) NE 1 or WNS_pbn_(i) = '')) then do;
		* add condition for if pbn missing ;
		WNS_reg_ch_(i)=.;
		WNS_ta_ch_(i)=.;
		WNS_uid_ch_(i)=.;
		WNS_pbn_ch_(i)=.;

	end;
	
	*neets;
	if COR_cust_da_(i) NE 1 and OS_da_post_(i) NE 1 and WNS_SEI_ind_(i) NE 1 and ter_post_da_prog_(i) NE 1 then neet_(i) = 1;
	else if COR_cust_da_(i) = 1 or OS_da_post_(i) = 1 then neet_(i) = .;
	else neet_(i) = 0;
	* not in labour force ;
	if COR_cust_da_(i) NE 1 and OS_da_post_(i) NE 1 and WNS_SEI_ind_(i) NE 1 and ter_post_da_prog_(i) NE 1 and JS_all_da_post_(i) NE 1 then not_in_lab_force_(i) = 1;
	else if COR_cust_da_(i) = 1 or OS_da_post_(i) = 1 then not_in_lab_force_(i) = .;
	else not_in_lab_force_(i) = 0;

	if (real_year = 2012 and i > 61) or (real_year = 2013 and i > 49) or (real_year = 2014 and i > 37) or (real_year = 2015 and i > 25) or (real_year = 2016 and i > 13) then do;
		* right sensor;
		* end cleanly at the point where any of the individuals within the group may have incomplete data ;
		total_da_onben_post_(i)=.;
		JS_all_da_post_(i)=.;
		COR_cust_da_(i)=.;
		OS_da_post_(i)=.;
		ter_post_da_prog_(i)=.;
		ter_post_enr_uni_(i)=.;
		ter_post_enr_uni_hi_(i)=.;
		ter_post_enr_uni_lo_(i)=.;
		WNS_ind_(i)=.;
		WNS_inc_(i)=.;
		WNS_SEI_ind_(i)=.;
		WNS_SEI_inc_(i)=.;
		WNS_reg_ch_(i)=.;
		WNS_ta_ch_(i)=.;
		WNS_uid_ch_(i)=.;
		WNS_pbn_ch_(i)=.;
		neet_(i) = .;
		has_young_child_(i) = .;
		not_in_lab_force_(i) = .;
	end;

end;

demo_eth=5; * MELAA and others are grouped together with missing;
if moe_enr_ethnic_grp1_snz_ind=1 then demo_eth=1; 
if moe_enr_ethnic_grp4_snz_ind=1 then demo_eth=4;
if moe_enr_ethnic_grp3_snz_ind=1 then demo_eth=3;
if moe_enr_ethnic_grp2_snz_ind=1 then demo_eth=2;* highest priority Maori;

if domestic=0 then demo_eth=6; *if international student, we dont care about ethnicity, na category, not applying ethnicity to international students;
agebands=put(ageat31Dec,agebands.);
format ter_com_qual_type $outLvl.;

* grouping small counts;
*if ter_com_qual_type in ('1','2') then ter_com_qual_type="2"; * instead of changing formats, I will group levels 1 - 4 in cat 2 ;
*ter_com_qual_type = put(ter_com_qual_type, $outLvl.);



* giving restrictions by age;
if ter_com_subsector ne 'University' then ter_com_subsector='non-University'; else  ter_com_subsector='University';

/*
study level 1-4 and age <= 21
study level 5-7 Cert/Dip and age <= 23
study level 7 and age <= 24 for three year bachelors + required years
study level grad/postgrad cert/dip and age <= 26 
study level Masters and age <= 27
study level Dcotoral and age <= 29
*/

run;

data project._FINAL_DATASET_RAW;
set study_pop2;
run;
******************************************************************************************************************************************************************
******************************************************************************************************************************************************************

Part 2: Tabulate data for cube;
******************************************************************************************************************************************************************
******************************************************************************************************************************************************************;


%macro TABZ(array_d,array_n,outdata);
	PROC summary DATA=&study_pop_data nway;
	CLASS &Classvar.;
	VAR &array_d.: ;
	output out=test_denom(drop=_:) N= ;

	PROC summary DATA=&study_pop_data nway;
	CLASS &Classvar. ;
	VAR &array_n.: ;
	output out=test_num (drop=_:) sum= ;
	RUN;

	data TEST_denom;
	set test_denom ;
	array &array_d._(*) &array_d._&firstm.-&array_d._&lastm.;
	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if &array_d._(i)>=0 then  do;
			denom=&array_d._(i);
			month=ind; 
			output;
		end;
	end;
	keep &Classvar. month denom;

	data TEST_num;
	set test_num ;
	array &array_n._(*) &array_n._&firstm.-&array_n._&lastm.;
	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if &array_n._(i)>=0 then  do;
			num=&array_n._(i);
			month=ind; 
			output;
		end;
	end;
	keep &Classvar. month num;

		data &outdata;
		length ind $ 20;
		ind="&array_n.";

		retain ind &Classvar. month;
		merge
		test_denom 
		test_num; 
		by &Classvar. month;
		run;

%mend;
* income tabulation ;
%macro TABZ_INC(array_d,array_n,outdata);
	PROC summary DATA=&study_pop_data nway;
	CLASS &Classvar.;
	VAR &array_n._ind: ;
	output out=test_denom(drop=_:) N= ;
	output out=test_num(drop=_:) sum= ;

	PROC summary DATA=&study_pop_data nway;
	CLASS &Classvar. ;
	VAR &array_n._inc: ;
	output out=test_mean (drop=_:) mean= ;
	output out=test_med (drop=_:) median= ;
	RUN;

	data TEST_denom;
	set test_denom ;
	array &array_n._ind_(*) &array_n._ind_&firstm.-&array_n._ind_&lastm.;
	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if &array_n._ind_(i)>=0 then  do;
			denom=&array_n._ind_(i);
			month=ind; 
			output;
		end;
	end;
	keep &Classvar. month denom;

	data TEST_num;
	set test_num ;
	array &array_n._ind_(*) &array_n._ind_&firstm.-&array_n._ind_&lastm.;
	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if &array_n._ind_(i)>=0 then  do;
			num=&array_n._ind_(i);
			month=ind; 
			output;
		end;
	end;
	keep &Classvar. month num;

	data test_mean;
	set test_mean ;
	array &array_n._inc_(*) &array_n._inc_&firstm.-&array_n._inc_&lastm.;
	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if &array_n._inc_(i)>=0 then  do;
			mean=&array_n._inc_(i);
			month=ind; 
			output;
		end;
	end;
	keep &Classvar. month mean;

	data test_med;
	set test_med ;
	array &array_n._inc_(*) &array_n._inc_&firstm.-&array_n._inc_&lastm.;
	do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		if &array_n._inc_(i)>=0 then  do;
			med=&array_n._inc_(i);
			month=ind; 
			output;
		end;
	end;
	keep &Classvar. month med;

		data &outdata;
		length ind $ 20;
		ind="&array_n.";
		retain ind &Classvar. month;
		merge
		test_denom
		test_num 
		test_mean
		test_med; 
		by &Classvar. month;
		run;

%mend;

data domestic intern; set project._FINAL_DATASET_RAW; 
if domestic=1 then output domestic;
if domestic=0 then output intern;
run;

%macro RUN_all_TABZ_DOM(dataset,inc_dataset);
	
	%let study_pop_data=domestic;
	%if (&updateImcomeOnly. = 0) %then %do;
	%TABZ(OS_da_post,OS_da_post,data_OS_da); * overseas status;
	%TABZ(ter_post_da_prog,ter_post_da_prog,data_STUDY_da); * enrolled back into tertiary indicator;
	%TABZ(ter_post_enr_uni,ter_post_enr_uni,data_STUDY_uni); * enrolled back into Uni sector;
	%TABZ(ter_post_enr_uni_hi,ter_post_enr_uni_hi,data_UNI_hi); * enrolled back into uni higher levels than before;
	%TABZ(total_da_onben_post,total_da_onben_post,data_BEN_da); * was supported by main benefit;
	%TABZ(JS_all_da_post,JS_all_da_post,data_JS_BEN_da);* was supported by Job seeker benefit;
	%TABZ(WNS_reg_ch,WNS_reg_ch,data_WNS_REG_ch);
	%TABZ(WNS_ta_ch,WNS_ta_ch,data_WNS_TA_ch);
	%TABZ(WNS_pbn_ch,WNS_pbn_ch,data_WNS_PBN_ch);
	%TABZ(WNS_SEI_ind,WNS_SEI_ind,data_WNS_SEI_ind);
	%TABZ(neet,neet,data_neet);
	%TABZ(not_in_lab_force, not_in_lab_force, data_not_in_lab_force);
	%TABZ(has_young_child,has_young_child,data_has_young_child);
	*%TABZ(WNS,WNS,data_WNS_da);
DATA &dataset; set data_:;
	if domestic=1; 
	run; 
%end;

	%TABZ_INC(WNS, WNS, inc_data_WNS_inc); * an indicator of earning wages and salaries + mean and median;
	*%TABZ_INC(WNS_SEI,WNS_SEI,inc_data_SEI_da);* an indicator of positive SEI income + mean and median;
	
	DATA &inc_dataset; set inc_data_:;
	if domestic=1; 
	run;
%mend;
%macro RUN_all_TABZ_INT(dataset,inc_dataset);
%let study_pop_data=intern;
%if (&updateImcomeOnly. = 0) %then %do;
	%TABZ(OS_da_post,OS_da_post,data_OS_da); * overseas status;
	%TABZ(ter_post_da_prog,ter_post_da_prog,data_STUDY_da); * enrolled back into tertiary indicator;
	%TABZ(ter_post_enr_uni,ter_post_enr_uni,data_STUDY_uni); * enrolled back into Uni sector;
	%TABZ(ter_post_enr_uni_hi,ter_post_enr_uni_hi,data_UNI_hi); * enrolled back into uni higher levels than before;
	%TABZ(neet,neet,data_neet);
	%TABZ(not_in_lab_force, not_in_lab_force, data_not_in_lab_force);
	%TABZ(has_young_child,has_young_child,data_has_young_child);
	* not tabulating benefit for international ;

	%TABZ(WNS_reg_ch,WNS_reg_ch,data_WNS_REG_ch);
	%TABZ(WNS_ta_ch,WNS_ta_ch,data_WNS_TA_ch);
	%TABZ(WNS_pbn_ch,WNS_pbn_ch,data_WNS_PBN_ch);
	%TABZ(WNS_SEI_ind,WNS_SEI_ind,data_WNS_SEI_ind);
	*%TABZ(WNS,WNS,data_WNS_da); 

	DATA &dataset; set data_:;
	if domestic=0; 
	run;
%end;
%TABZ_INC(WNS, WNS, inc_data_WNS_inc); * an indicator of earning wages and salaries + mean and median;
*%TABZ_INC(WNS_SEI,WNS_SEI,inc_data_SEI_da);* an indicator of positive SEI income + mean and median;
DATA &inc_dataset; set inc_data_:;
if domestic=0; 
run;
%mend;


* Tabulation by cohorts;
*%let updateEmployment=1;
%let updateImcomeOnly=0;
*%let updatePostStudy=1;
%let Classvar=cohort domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type young_grad;
%let Classvar_sql=cohort, domestic, ter_com_subsector, snz_sex_code, demo_eth, ter_com_qual_type;
	%RUN_all_TABZ_DOM(ALL_domestic, ALL_domestic_inc);
/*
%TABZ(has_young_child,has_young_child,data_has_young_child);

data project.young_child_test_set;
set data_has_young_child;

run;
*/
* for international we don't care about sex and enthnicity;
%let Classvar=cohort domestic ter_com_subsector ter_com_qual_type; * don't do young_grad for international;
	%RUN_all_TABZ_INT(ALL_international, ALL_international_inc);


DATA ALL_cohorts;
set 
ALL_domestic 
ALL_international;
dataset='dataset1';
run;
DATA ALL_cohorts_inc;
set 
ALL_domestic_inc 
ALL_international_inc;
dataset='dataset1';
run;
* (SCH): filter out recent cohorts for combined cohort tabulation ;
data domestic intern; set project._FINAL_DATASET_RAW; 
if domestic=1 then output domestic;
if domestic=0 then output intern;
if cohort in (2009, 2010, 2011);
run;
* Tabulation all three cohorts ;
%let Classvar=domestic ter_com_subsector snz_sex_code demo_eth ter_com_qual_type ter_com_NZSCED young_grad;
	%RUN_all_TABZ_DOM(ALL_domestic, ALL_domestic_inc);

* for international we don't care about sex and enthnicity;
%let Classvar=domestic ter_com_subsector ter_com_qual_type ter_com_NZSCED;
	%RUN_all_TABZ_INT(ALL_international, ALL_international_inc);

DATA ALL_all_cohorts;
set 
ALL_domestic 
ALL_international;
dataset='dataset2';
run;
DATA ALL_all_cohorts_inc;
set 
ALL_domestic_inc 
ALL_international_inc;
dataset='dataset2';
run;

DATA CUBE; 
set ALL_all_cohorts ALL_cohorts;
run;

DATA CUBE_inc; 
set ALL_all_cohorts_inc ALL_cohorts_inc;
run;

data project.CUBE;
set CUBE;
run;
data project.Income_cube;
set CUBE_inc;
run; 



