
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
*****************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************
Creating arrays of income Inetrested incomes
Wages and Salaries

*****************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************;
%include "&path.codes/cpi_macro.sas";
%macro inc_mth(type);
array &type._[*] &type._&firstm.-&type._&lastm. ;

&type._(i)=0;

if not((startdate > end_window) or (enddate < start_window)) and TYPE="&type." then do;

					

					if (startdate <= start_window) and  (enddate > end_window) then
						days=(end_window-start_window)+1;
					else if (startdate <= start_window) and  (enddate <= end_window) then
						days=(enddate-start_window)+1;
					else if (startdate > start_window) and  (enddate <= end_window) then
						days=(enddate-startdate)+1;
					else if (startdate > start_window) and  (enddate > end_window) then
						days=(end_window-startdate)+1;	

					&type._[i]=days*rate;

end;
%mend;
******************************************************************************************************************************************************************;
* Monthly EMS data;
proc sql;
	create table job_summary1 as 

	SELECT distinct 
		a.snz_uid AS snz_uid,
		a.inc_cal_yr_year_nbr AS year,
		a.snz_employer_ird_uid,
		a.inc_cal_yr_income_source_code AS income_source_code,
		sum(a.inc_cal_yr_mth_01_amt) AS m1, 
		sum(a.inc_cal_yr_mth_02_amt) AS m2, 
		sum(a.inc_cal_yr_mth_03_amt) AS m3, 
		sum(a.inc_cal_yr_mth_04_amt) AS m4, 
		sum(a.inc_cal_yr_mth_05_amt) AS m5, 
		sum(a.inc_cal_yr_mth_06_amt) AS m6, 
		sum(a.inc_cal_yr_mth_07_amt) AS m7, 
		sum(a.inc_cal_yr_mth_08_amt) AS m8, 
		sum(a.inc_cal_yr_mth_09_amt) AS m9, 
		sum(a.inc_cal_yr_mth_10_amt) AS m10, 
		sum(a.inc_cal_yr_mth_11_amt) AS m11, 
		sum(a.inc_cal_yr_mth_12_amt) AS m12, 
		b.DOB

	FROM data.income_cal_yr a inner join &population. b
	ON a.snz_uid=b.snz_uid
	WHERE a.inc_cal_yr_year_nbr >= &first_anal_yr. and inc_cal_yr_year_nbr <= &last_anal_yr. 
		AND a.snz_ird_uid>0	and inc_cal_yr_income_source_code = 'W&S' /* filter down to Wage and Salary here to save space and time */
	GROUP BY a.snz_uid, a.inc_cal_yr_year_nbr, a.inc_cal_yr_income_source_code, a.snz_employer_ird_uid
		ORDER BY a.snz_uid, a.inc_cal_yr_year_nbr , a.inc_cal_yr_income_source_code, a.snz_employer_ird_uid
	;
quit;

data job_summary2;
	set job_summary1;
	do j=1 to 12;
		cal_month =j;
		if  j=1 then inc = m1;
		else if j=2 then inc = m2;
		else if j=3 then inc = m3;
		else if j=4 then inc = m4;
		else if j=5 then inc = m5;
		else if j=6 then inc = m6;
		else if j=7 then inc = m7;
		else if j=8 then inc = m8;
		else if j=9 then inc = m9;
		else if j=10 then inc = m10;
		else if j=11 then inc = m11;
		else if j=12 then inc = m12;

		if cal_month<=3 then quarter=1;
		else if cal_month>3 and cal_month<=6 then quarter=2;
		else if cal_month>6 and cal_month<=9 then quarter=3;
		else if cal_month>=10 then quarter=4;

		if inc ne 0 then output; 
	end;
drop j m1-m12;
run;

Proc Univariate data=job_summary2;
var inc;
run;

data job_summary2; set job_summary2;
if inc>15000 then inc=15000;
run;

* adjusting income to 2017 Q4 dollars;
proc sql;
	create table job_summary3 as select
		a.*,
		MDY(a.cal_month,1,a.year) as startdate format date9.,
		intnx('month',MDY(a.cal_month,1,a.year),0,'E') as enddate format date9.,
		b.cpi_index,
		a.inc*(1006/CPI_index) as inc_2017q4
	from job_summary2 a left join project.CPI_INDEX_BASE2017 b
	on a.year=b.year and a.quarter=b.quarter;
quit;

* convert to spell event data and filter out the self-employed data;
Data work.Income_raw_&date.;
	set job_summary3;
	if income_source_code='W&S' then income_source_code='WnS';
	format startdate enddate date9.;
	* exclude spells before DOB;
	if startdate<DOB and enddate<DOB then delete;
	if startdate<DOB and enddate>DOB then startdate=DOB;
keep snz_uid snz_employer_ird_uid income_source_code DOB inc_2017q4 startdate enddate;
run;
proc datasets lib=work;
delete job_: ;
run;
* SEI data ;
* Self-employment income;
Proc sql;
		create table sei_summary as 
		SELECT  distinct 
			a.snz_uid,
			b.DOB,
			a.inc_tax_yr_year_nbr-1 as year,
			MDY(4,1,inc_tax_yr_year_nbr-1) AS startdate format date9.,
			MDY(3,31,inc_tax_yr_year_nbr) AS enddate format date9.,
			max('SEI') AS income_source_code,
			sum(inc_tax_yr_tot_yr_amt) AS gross_earnings_amt
	FROM  data.income_tax_yr a inner join &population. b
	ON a.snz_uid=b.snz_uid
			WHERE a.inc_tax_yr_year_nbr >= &first_anal_yr
				AND a.inc_tax_yr_income_source_code in ('P00', 'P01', 'P02', 'C00', 'C01', 'C02', 'S00', 'S01', 'S02', 'S03') 
	GROUP BY a.snz_uid, startdate
	ORDER BY a.snz_uid, startdate ;
quit;
* get refdate ;
proc sql;
create table sei_summary_ref as
select a.*, b.refdate2, b.ter_com_qual
from sei_summary a 
inner join &population_1. b on a.snz_uid = b.snz_uid;
quit;

data sei_summary_ref;
	set sei_summary_ref;
	if startdate>"&sensor"d then delete;
	if enddate>"&sensor"d then enddate="&sensor"d;
	if enddate < refdate2 then delete;
	* delete spells starting before DOB;
	if startdate<DOB and enddate<DOB then delete;
	if startdate<DOB and enddate>DOB then startdate=DOB;
run;
* monthly arrays ;
data sei_mth_a;
set sei_summary_ref;
	* calculate the number of days the observation covers (used to distribute payments between months) ;
	total_days = (enddate - startdate) + 1;

	array SEI_da_(*)	SEI_da_&firstm.-SEI_da_&lastm.; * days in period ;
	array SEI_inc_(*)	SEI_inc_&firstm.-SEI_inc_&lastm.; * income by month ;

	* iterate through months ;
	do ind=&firstm. to &lastm.;
		i= ind - &firstm. + 1; * find array index for current month (1 based array) ;
		SEI_da_(i)=0;
		SEI_inc_(i)=0;
		
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

				SEI_da_(i)=days;
				SEI_inc_(i)=(gross_earnings_amt/total_days) * days;	

			end; * end window check ;
	end; * end monthly loop ;
	format start_window end_window date9.;
run;

* summarise values with amount ($) totals per person ;
proc summary data=sei_mth_a nway;
	class snz_uid refdate2 ter_com_qual;
	var 
SEI_inc_&firstm.-SEI_inc_&lastm.;
	output out=temp_post_SEI_amt_mth(drop=_: ) sum=;
run;
* summarise days on self employment ;
proc summary data=sei_mth_a nway;
	class snz_uid refdate2 ter_com_qual;
	var 
SEI_da_&firstm.-SEI_da_&lastm.;
	output out=temp_post_SEI_da_mth(drop=_: ) max=;
run;

%create_cpi_set(&population_1., temp_cpi_refdate2);

* Apply CPI to amount ($) arrays ;
proc sort data=temp_post_SEI_amt_mth; by refdate2;
data temp_post_SEI_amt_mth2;
merge temp_post_SEI_amt_mth temp_cpi_refdate2;
by refdate2; 
if snz_uid NE .;
array CPI_mth_(*)	CPI_mth_&firstm.-CPI_mth_&lastm.;
		* apply cpi ;
	do ind=&firstm. to &lastm.;
		i = ind + 1;
		%apply_cpi_to_i(SEI_inc_, i);
	end;

	drop CPI_mth_: ind i;
run;
* sort arrays before merging ;
proc sort data=temp_post_SEI_amt_mth2; by snz_uid refdate2 ter_com_qual;
proc sort data=temp_post_SEI_da_mth; by snz_uid refdate2 ter_com_qual;


* merge amount with days datasets ;
data project.sei_raw_&date.; 
	merge temp_post_SEI_amt_mth2 temp_post_SEI_da_mth;
	by snz_uid refdate2 ter_com_qual; 
run;
proc means data= project.sei_raw_&date.;
run;
proc datasets lib=work;
delete sei_: job_: temp_: ; run;
***************************************************************************************************************************************************************;
/*Data TEMP_EARN;
	set job_summary1;
	if income_source_code='W&S' then income_source_code='WnS';
	format startdate enddate date9.;
	* exclude spells before DOB;
	if startdate<DOB and enddate<DOB then delete;
	if startdate<DOB and enddate>DOB then startdate=DOB;
keep snz_uid snz_employer_ird_uid income_source_code DOB inc_2017q4 startdate enddate;
run;*/

Proc sql;
create table TEMP_EARN_1 
	as select 
	a.*,
	c.refdate2,
	c.ter_com_qual
from work.Income_raw_&date. /*TEMP_EARN*/ a
left join &population_1. c
on a.snz_uid=c.snz_uid
where a.income_source_code='WnS' and c.refdate2 NE .;

proc sql;
create table temp_wns_employer as
select wns.*, inc_pbn_pbn_nbr, inc_pbn_enterprise_nbr 
from TEMP_EARN_1 wns left join data.income_pbn_ent pbn
on wns.snz_uid = pbn.snz_uid 
and wns.snz_employer_ird_uid = pbn.snz_employer_ird_uid
and year(enddate) * 100 + month(enddate) = pbn.inc_pbn_dim_month_key
;
quit;

data temp_wns_employer;
set temp_wns_employer;
if refdate2 = . then delete;
run;

/*
data temp_wns_check2;
set temp_wns_employer;
if inc_pbn_pbn_nbr = '';
run;

data temp_wns_check2;
set temp_wns_employer;
if inc_pbn_pbn_nbr NE '';
run;
*/
* 19:42.91  ;
proc sql;
create table temp_wns_employer_data as
select wns.*, br_pbn_pbn_anzsic06_code, br_pbn_geo_anzsic06_code, br_pbn_geo_reg_council_code, br_pbn_geo_ta_code, br_pbn_ent_business_type96_code, br_pbn_ent_inst_sector96_code from temp_wns_employer wns left join br.pbn pbn
on wns.inc_pbn_pbn_nbr = pbn.br_pbn_pbn_nbr
and year(enddate) * 100 + month(enddate) between br_pbn_dim_start_month_key and br_pbn_dim_end_month_key
;
quit;
* are there duplicates ? ;
/*
data temp_wns_check;
set temp_wns_employer_data;
if br_pbn_pbn_anzsic06_code NE '';
run;

data temp_wns_check2;
set temp_wns_employer_data;
if br_pbn_pbn_anzsic06_code = '';
run;
*/
data temp_wns_employer_data2;
set temp_wns_employer_data;
index = ((year(startdate) - year(refdate2)) * 12) + (month(startdate) - month(refdate2)) + 1;
if index <= &firstm. or index > &lastm. + 1 then delete;
run;

* put into array... ;

* one row per person, refdate ;
* choose the best date of 
;

proc sort data=temp_wns_employer_data2; by snz_uid refdate2 ter_com_qual index descending inc_2017q4 descending inc_pbn_pbn_nbr;

%macro summary_employer_data();
%do ind=&firstm. %to &lastm.;

data temp_wns_arr_&ind. (keep=snz_uid refdate2 ter_com_qual WNS_uid_&ind. WNS_pbn_&ind. WNS_ent_&ind. WNS_ent_type_&ind. WNS_ent_sector_&ind. WNS_reg_&ind. WNS_ta_&ind. WNS_anzsic_&ind.);
retain p_snz_uid p_refdate2 p_ter_com_qual;
set temp_wns_employer_data2;
by snz_uid refdate2;
if index = (&ind. + 1);
if p_snz_uid = snz_uid and p_refdate2 = refdate2 and p_ter_com_qual = ter_com_qual then delete; * deletes entries not first row ;

WNS_uid_&ind. = snz_employer_ird_uid;
*WNS_pbn_&ind. = , WNS_ent_&ind., WNS_reg_&ind., WNS_anzsic_&ind.;
WNS_ent_type_&ind. = br_pbn_ent_business_type96_code;
WNS_ent_sector_&ind. = br_pbn_ent_inst_sector96_code;
WNS_inc_&ind. = inc_2017q4;
WNS_pbn_&ind. = inc_pbn_pbn_nbr;
WNS_ent_&ind. = inc_pbn_enterprise_nbr;
WNS_reg_&ind. = br_pbn_geo_reg_council_code;
WNS_ta_&ind. = br_pbn_geo_ta_code;
WNS_anzsic_&ind. = br_pbn_geo_anzsic06_code;
p_snz_uid = snz_uid;
p_refdate2 = refdate2;
p_ter_com_qual = ter_com_qual;

run;
%end;
data temp_wns_person_mth;
merge temp_wns_arr_:;
by snz_uid refdate2 ter_com_qual;
run;
proc datasets lib=work;
delete temp_wns_arr_: ; run;
%mend;

%summary_employer_data();

data temp_wns_person_mth2;
set temp_wns_person_mth;
array WNS_reg_(*) $ WNS_reg_&firstm.-WNS_reg_&lastm.;
array WNS_reg_ch_(*) WNS_reg_ch_&firstm.-WNS_reg_ch_&lastm.;
array WNS_ta_(*) $ WNS_ta_&firstm.-WNS_ta_&lastm.;
array WNS_ta_ch_(*) WNS_ta_ch_&firstm.-WNS_ta_ch_&lastm.;
array WNS_uid_(*) WNS_uid_&firstm. -WNS_uid_&lastm.;
array WNS_uid_ch_(*) WNS_uid_ch_&firstm. -WNS_uid_ch_&lastm.;
array WNS_pbn_(*) $ WNS_pbn_&firstm. -WNS_pbn_&lastm.;
array WNS_pbn_ch_(*) WNS_pbn_ch_&firstm. -WNS_pbn_ch_&lastm.;
length pre_WNS_pbn $ 10;
pre_WNS_pbn = '';
length pre_WNS_reg $ 10;
pre_WNS_reg = '';
length pre_WNS_ta $ 10;
pre_WNS_ta = '';
pre_WNS_uid = .;
do ind=&firstm. to &lastm.;
		
		i=ind - &firstm. + 1;
		if pre_WNS_reg = '' then pre_WNS_reg = WNS_reg_(i);
		if pre_WNS_ta = '' then pre_WNS_ta = WNS_ta_(i);
		if pre_WNS_pbn = '' then pre_WNS_pbn = WNS_pbn_(i);
		if pre_WNS_uid = . then pre_WNS_uid = WNS_uid_(i);
		if i > 1 then do; * check to avoid index out of bounds (1 based index) ;
			* location is known in both months, and location has changed is counted as change ;
			if /*WNS_reg_(i) NE WNS_reg_(i - 1) and*/ WNS_reg_(i) NE '' and WNS_reg_(i) NE pre_WNS_reg then do; 
				WNS_reg_ch_(i) = 1; 
				pre_WNS_reg = WNS_reg_(i);
			end;
			else WNS_reg_ch_(i) = 0;
			if WNS_ta_(i) NE '' and WNS_ta_(i) NE pre_WNS_ta then do; 
				WNS_ta_ch_(i) = 1;
				pre_WNS_ta = WNS_ta_(i);
			end;
			else WNS_ta_ch_(i) = 0;
			if WNS_uid_(i) NE . and WNS_uid_(i) NE pre_WNS_uid then do;
				WNS_uid_ch_(i) = 1;
				pre_WNS_uid = WNS_uid_(i);
			end;
			else WNS_uid_ch_(i) = 0;
			if WNS_pbn_(i) NE '' and WNS_pbn_(i) NE pre_WNS_pbn then do;
				WNS_pbn_ch_(i) = 1;
				pre_WNS_pbn = WNS_pbn_(i);
			end;
			else WNS_pbn_ch_(i) = 0;
		end; * end index check ;
	end;
	
	drop pre_WNS_reg pre_WNS_ta pre_WNS_pbn pre_WNS_uid ind i;
;
run;

* write to project folder ;
data project._POST_EMPLOYER_WNS_MTH_&date.; set temp_wns_person_mth2;
run;

* Put into months? I think there should be a better way.;

data TEMP_EARN_2; set TEMP_EARN_1 ; 
rate=inc_2017q4/(enddate-startdate+1); * daily rate;
type=income_source_code;

if refdate2>0;
do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
		start_window=intnx('MONTH',refdate2,i-1,'S');
		end_window=intnx('MONTH',refdate2,i,'S')-1;
	%inc_mth(WnS);

end;
run;

proc summary data=TEMP_EARN_2 nway;
class snz_uid refdate2 ter_com_qual;
var WNS_: ;
output out=TEMP_dollar(drop=_:) sum=;
run;

data project.WnS_dollar_part;
set TEMP_dollar;
run;

proc sort data=project.sei_raw_&date.; By snz_uid refdate2 ter_com_qual;
proc sort data=project.WnS_dollar_part; By snz_uid refdate2 ter_com_qual;

data project._POST_INC_MTH_&date.; 
merge project.WnS_dollar_part project.sei_raw_&date.; 
by snz_uid refdate2 ter_com_qual;
run;

proc means data=project._post_inc_mth_&date.;
run;

proc datasets lib=work;
delete temp_: ; run;
