
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
* this code has not yet been used to produce outputs.
/*
Owner: Universities New Zealand
Author: Scott Henwood

Purpose: to find the monthly activity in relation to student support (e.g. student loan/allowance).
         Payments, repayments, interest and interest write off

Datasets required: income output from msd macro, cpi index
Last modified: 26/9/2018
*/

***************************************************************
prep cpi dataset for month windows based off refdate.
cpi to first quarter 2017
given a ref date, record the cpi numbers for each of the following [72] months
***************************************************************;

proc sql;
create table cpi_pop_base as
select *
from &population_1., sch_proj.cpi_index_base2017;
quit;
/*
distribute to month array
*/
data cpi_pop_mth;
set cpi_pop_base;
array CPI_mth_(*)	CPI_mth_&firstm.-CPI_mth_&lastm.;
ref_year = year(refdate2);
year_value = year - ref_year;
if year_value >= 0;
/* has values for three months */
first_month = 0;
select (quarter);
	when (1) first_month = 1;
	when (2) first_month = 4;
	when (3) first_month = 7;
	when (4) first_month = 10;
end;
i = year_value * 12 + first_month;
if i <= &lastm. + 1 then CPI_mth_(i) = CPI_index;
if i + 1 <= &lastm. + 1 then CPI_mth_(i + 1) = CPI_index;
if i + 2 <= &lastm. + 1 then CPI_mth_(i + 2) = CPI_index;
if i > &lastm. + 1 then delete;
run;

* merge into per person cpi array ;
proc summary datadata=cpi_pop_mth nway; 
	class snz_uid refdate2;
	var CPI_mth_&firstm.-CPI_mth_&lastm.;
	output out=temp_cpi_refdate (drop=_: ) max=;
run;
proc sql;
drop table cpi_pop_base;
drop table cpi_pop_mth;
quit;

/* 
Author: Scott Henwood
macro to apply cpi for the given varible, use inside loop. 
line required before: array CPI_mth_(*)	CPI_mth_&firstm.-CPI_mth_&lastm.;
*/
%macro apply_cpi_to_i(var_name, index);
array &var_name.(*)	&var_name.&firstm.-&var_name.&lastm.;

&var_name.(&index) = &var_name.(&index)*(1000/CPI_mth_(&index));
%mend;
*******************************************************
End CPI prep
;

*******************************************************
calculate student support payments/repayments by month
;

* read income set, and add ref date ;
proc sql;
create table student_support_ref as
select a.*, b.refdate2 
from project.INCOME_RAW_&date. a 
inner join &population_1. b on a.snz_uid = b.snz_uid;
quit;

* remove records after sensor date or before ref date, and sense check start and end dates ;
data student_support_ref1; 
set student_support_ref; 
if startdate>"&sensor"d then delete;
if enddate>"&sensor"d then enddate="&sensor"d;
if startdate<=enddate;
if enddate < refdate2 then delete;
if Level2 = 'Study';
run;

* monthly arrays ;
data student_support2;
set student_support_ref1;
* calculate the number of days the observation covers (used to distribute payments between months) ;
total_days = (enddate - startdate) + 1;

array SS_da_(*)	SS_da_&firstm.-SS_da_&lastm.;
array SS_allow_da_(*)	SS_allow_da_&firstm.-SS_allow_da_&lastm.; * days on allowance ;
array SS_allow_pa_(*)	SS_allow_pa_&firstm.-SS_allow_pa_&lastm.; * amount on allowance ;
array SS_loan_repay_(*)	SS_loan_repay_&firstm.-SS_loan_repay_&lastm.; * student loan repayments ;
array SS_loan_borr_total_(*)	SS_loan_borr_total_&firstm.-SS_loan_borr_total_&lastm.; * total borrowing ;
array SS_loan_tuition_(*)	SS_loan_tuition_&firstm.-SS_loan_tuition_&lastm.; * Tuition fees ;
array SS_loan_co_related_(*)	SS_loan_co_related_&firstm.-SS_loan_co_related_&lastm.; * Course related costs ;
array SS_loan_living_(*)	SS_loan_living_&firstm.-SS_loan_living_&lastm.; * Living costs ;
array SS_loan_inter_(*)	SS_loan_inter_&firstm.-SS_loan_inter_&lastm.; * Interest ;
array SS_loan_inter_off_(*)	SS_loan_inter_off_&firstm.-SS_loan_inter_off_&lastm.; * Interest written off ;
	* iterate through months ;
	do ind=&firstm. to &lastm.;
		i=ind- (&firstm.) + 1; /*1 based arrays?, take away the first value from the current value and add one*/
		SS_da_(i)=0;
		SS_allow_da_(i)=0;
		SS_allow_pa_(i)=0;
		SS_loan_repay_(i)=0;
		SS_loan_borr_total_(i)=0;
		SS_loan_tuition_(i)=0;
		SS_loan_co_related_(i)=0;
		SS_loan_living_(i)=0;
		SS_loan_inter_(i)=0;
		SS_loan_inter_off_(i)=0;
		/* SCH: window under observation in interation */
		start_window=intnx('MONTH',refdate2,i-1,'S'); 
		end_window=intnx('MONTH',refdate2,i,'S')-1;
		if not((startdate > end_window) or (enddate < start_window)) then
			do;
				if (startdate <= start_window) and  (enddate > end_window) then
					days=(end_window-start_window)+1;
				else if (startdate <= start_window) and  (enddate <= end_window) then
					days=(enddate-start_window)+1;
				else if (startdate > start_window) and  (enddate <= end_window) then
					days=(enddate-startdate)+1;
				else if (startdate > start_window) and  (enddate > end_window) then
					days=(end_window-startdate)+1;

				SS_da_(i)=days;
				* select based on support activity classification ;
				select (InCDudCode);
					when ('sbasap') do; 
						SS_allow_da_(i)=days; 
						SS_allow_pa_(i)=(Amount/total_days) * days;
					end;
					when ('sbalrm') SS_loan_repay_(i)=(Amount/total_days) * days;
					when ('iltdfe') SS_loan_tuition_(i)=(Amount/total_days) * days; * course fees;
					when ('iltcrf') SS_loan_co_related_(i)=(Amount/total_days) * days; * course related;
					when ('iltllc') SS_loan_living_(i)=(Amount/total_days) * days;
					when ('trnint') SS_loan_inter_(i)=(Amount/total_days) * days;
					when ('trnliw') SS_loan_inter_off_(i)=(Amount/total_days) * days;
					otherwise delete;
				end; * end support classification select ;

				if (InCDudCode in ('iltdfe', 'iltcrf', 'iltllc')) then SS_loan_borr_total_(i)=(Amount/total_days) * days;	
			end; * end window check ;
	end; * end monthly loop ;
	format start_window end_window date9.;
run;

* summarise values with amount ($) totals per person ;
proc summary data=student_support2 nway;
	class snz_uid refdate2;
	var 
SS_allow_pa_&firstm.-SS_allow_pa_&lastm.
SS_loan_repay_&firstm.-SS_loan_repay_&lastm. 
SS_loan_borr_total_&firstm.-SS_loan_borr_total_&lastm.
SS_loan_tuition_&firstm.-SS_loan_tuition_&lastm.
SS_loan_co_related_&firstm.-SS_loan_co_related_&lastm.
SS_loan_living_&firstm.-SS_loan_living_&lastm.
SS_loan_inter_&firstm.-SS_loan_inter_&lastm.
SS_loan_inter_off_&firstm.-SS_loan_inter_off_&lastm.;
	output out=temp_post_SS_amt_mth(drop=_: ) sum=;
run;

* summarise values with day counts per person ;
proc summary data=student_support2 nway;
	class snz_uid refdate2;
	var SS_da_&firstm.-SS_da_&lastm. SS_allow_da_&firstm.-SS_allow_da_&lastm.;
	output out=temp_post_SS_da_mth(drop=_: ) max=;
run;

* narrow down cpi to individuals who appear in student support ;
proc sql;
create table temp_cpi_refdate2 as
select * from temp_cpi_refdate
where snz_uid in (select snz_uid from temp_post_SS_amt_mth);
quit;

* sort datasets to help with merging ;
proc sort data=temp_post_SS_amt_mth; by snz_uid refdate2;
proc sort data=temp_post_SS_da_mth; by snz_uid refdate2;
proc sort data=temp_cpi_refdate2; by snz_uid refdate2;

* merge amount with days datasets, and apply cpi to amounts ;
data project._POST_SS_&date.; 
	merge temp_post_SS_amt_mth temp_post_SS_da_mth temp_cpi_refdate2;
	by snz_uid refdate2; 
	array CPI_mth_(*)	CPI_mth_&firstm.-CPI_mth_&lastm.;
		* apply cpi ;
	do ind=&firstm. to &lastm.;
		i = ind + 1;
		%apply_cpi_to_i(SS_allow_pa_, i);
		%apply_cpi_to_i(SS_loan_repay_, i);
		%apply_cpi_to_i(SS_loan_borr_total_, i);
		%apply_cpi_to_i(SS_loan_tuition_, i);
		%apply_cpi_to_i(SS_loan_co_related_, i);
		%apply_cpi_to_i(SS_loan_living_, i);
		%apply_cpi_to_i(SS_loan_inter_, i);
		%apply_cpi_to_i(SS_loan_inter_off_, i);
	end;
	drop CPI_mth_: ind i;
run;
