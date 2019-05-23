

******************************************************************************************************************;
******************************************************************************************************************;

* EARNINGS EARNINGS EARNINGS EARNINGS EARNINGS EARNINGS EARNINGS EARNINGS  EARNINGS EARNINGS EARNINGS EARNINGS 

******************************************************************************************************************;
******************************************************************************************************************;
* The main source of income is through the EMS data;
* In this  program the summary tables have been used;


%macro inc_mth(type);
array &type._[*] &type._&firstagem.-&type._&lastagem. ;
array &type._id_[*] &type._id_&firstagem.-&type._id_&lastagem. ;

&type._(i)=0;
&type._id_(i)=0;

if not((startdate > end_window) or (enddate < start_window)) and income_source_code="&type." then do;

					&type._id_(i)=1;

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


%macro PRE_Create_Earn_pop_mth;
proc sql;
	create table job_summary as 

	SELECT distinct 
		a.snz_uid AS snz_uid,
		a.inc_cal_yr_year_nbr AS year,
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
		AND a.snz_ird_uid>0	AND a.inc_cal_yr_income_source_code ='W&S'
	GROUP BY a.snz_uid, a.inc_cal_yr_year_nbr , a.inc_cal_yr_income_source_code
		ORDER BY a.snz_uid, a.inc_cal_yr_year_nbr , a.inc_cal_yr_income_source_code 
	;
quit;

data job_summary ( drop=m1-m12 );
	set job_summary;

	do j=1 to 12;
		cal_month =j;

		if      j=1 then
			inc = m1;
		else if j=2      then
			inc = m2;
		else if j=3 	  then
			inc = m3;
		else if j=4      then
			inc = m4;
		else if j=5      then
			inc = m5;
		else if j=6      then
			inc = m6;
		else if j=7      then
			inc = m7;
		else if j=8      then
			inc = m8;
		else if j=9      then
			inc = m9;
		else if j=10     then
			inc = m10;
		else if j=11     then
			inc = m11;
		else if j=12     then
			inc = m12;

		if cal_month<=3 then
			quarter=1;
		else if cal_month>3 and cal_month<=6 then
			quarter=2;
		else if cal_month>6 and cal_month<=9 then
			quarter=3;
		else if cal_month>=10 then
			quarter=4;

		if inc ne 0 then
			output;
	end;

	drop j;
run;

* adjusting income to 2015 Q4 dollars;
proc sql;
	create table job_summary1 as select
		a.*,
		MDY(a.cal_month,1,a.year) as startdate format date9.,
		intnx('month',MDY(a.cal_month,1,a.year),0,'E') as enddate format date9.,
		b.cpi_index,
		a.inc*(1006/CPI_index) as inc_2017q4
	from job_summary a left join project.CPI_INDEX_BASE2017 b
		on a.year=b.year and a.quarter=b.quarter;
quit;


* convert to spell event data and filter out the self-employed data;
Data job_summary1;
	set job_summary1;

	*relabel the ACC payment;
/*	if income_source_code = 'CLM' then	income_source_code = 'ACC';*/
	if income_source_code='W&S' then income_source_code='WnS';
	format startdate enddate date9.;
	* exclude spells before DOB;
	if startdate<DOB and enddate<DOB then
		delete;
	if startdate<DOB and enddate>DOB then
		startdate=DOB;
	keep snz_uid income_source_code DOB inc_2017q4 startdate enddate;
	if income_source_code='WnS';
run;

proc datasets lib=work;
delete job_summary ; run;

* combining and brining in Refmth;
data FACT_INC_mth;
set JOB_SUMMARY1(in= a) ;
rate=inc_2015q4/(enddate-startdate+1);
run;

proc datasets lib=work;
delete sei_summary1 job_summary1 ; run;


proc sql;
create table FACT_INC_combined
as select
	a.*,

	b.refdate2
from FACT_INC_mth a left join &population_1. b 
on a.snz_uid=b.snz_uid;


* COMBINE ALL THE SOURCES OF INCOME BY CALENDAR YEAR;
************************************;
* combining;


data FACT_INC_PRE;
set FACT_INC_combined(in=a) &population_1.(keep=snz_uid ref:);
if refmth1>0;
if NOT a then rate=0;
DOB=intnx('MONTH',ref_date1,-36,'S');
do ind=&firstagem. to &lastagem.;
			i=ind-(&firstagem.-1);
			start_window=intnx('MONTH',DOB,i-1,'S');
			end_window=intnx('MONTH',DOB,i,'S')-1;
			%inc_mth(WnS);
/*			%inc_mth(SEI);*/
/*			%inc_mth(ACC);*/
/*			%inc_mth(BEN);*/
/*			%inc_mth(PPL);*/
/*			%inc_mth(STU);*/
/*			%inc_mth(PEN);*/

	if (WnS_(i)>0 and Wns_(i)<10) then do;
	 	WnS_id_(i)=0;
		WnS_(i)=0;
	end;

	if  WnS_(i)>20000 then do;
	 	WnS_id_(i)=1;
		WnS_(i)=20000;
	end;

end;
run;
* large datasets take a lotof space ;
proc datasets  lib=work;
delete SEI_summary: job_summary: temp: _ind: T: cor: hos: all: _cost:;
run;

proc summary data=FACT_INC_PRE nway;
class snz_uid ref:;
var 
WNS_&firstagem.-WNS_&lastagem.;
output out=earn_dollars (drop=_:) sum=;run;

proc summary data=FACT_INC_PRE nway;
class snz_uid ref:;
var 
WNS_id_&firstagem.-WNS_id_&lastagem.;
output out=earn_ind (drop=_:) max= ;
run;


data &projectlib.._PRE_EARN_mth_&date. ;
merge earn_dollars earn_ind; by snz_uid ref:;
rename  WNS_&firstagem.-WNS_&lastagem.=WNS_pre_&lastagem.-WNS_pre_&firstagem.;
rename  WNS_id_&firstagem.-WNS_id_&lastagem.=WNS_id_pre_&lastagem.-WNS_id_pre_&firstagem.;
run;

%mend; 


%macro POST_Create_Earn_pop_mth;
proc sql;
	create table job_summary as 

	SELECT distinct 
		a.snz_uid AS snz_uid,
		a.inc_cal_yr_year_nbr AS year,
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
		AND a.snz_ird_uid>0	AND a.inc_cal_yr_income_source_code ='W&S'
	GROUP BY a.snz_uid, a.inc_cal_yr_year_nbr , a.inc_cal_yr_income_source_code
		ORDER BY a.snz_uid, a.inc_cal_yr_year_nbr , a.inc_cal_yr_income_source_code 
	;
quit;

data job_summary ( drop=m1-m12 );
	set job_summary;

	do j=1 to 12;
		cal_month =j;

		if      j=1 then
			inc = m1;
		else if j=2      then
			inc = m2;
		else if j=3 	  then
			inc = m3;
		else if j=4      then
			inc = m4;
		else if j=5      then
			inc = m5;
		else if j=6      then
			inc = m6;
		else if j=7      then
			inc = m7;
		else if j=8      then
			inc = m8;
		else if j=9      then
			inc = m9;
		else if j=10     then
			inc = m10;
		else if j=11     then
			inc = m11;
		else if j=12     then
			inc = m12;

		if cal_month<=3 then
			quarter=1;
		else if cal_month>3 and cal_month<=6 then
			quarter=2;
		else if cal_month>6 and cal_month<=9 then
			quarter=3;
		else if cal_month>=10 then
			quarter=4;

		if inc ne 0 then
			output;
	end;

	drop j;
run;

* adjusting income to 2015 Q4 dollars;
proc sql;
	create table job_summary1 as select
		a.*,
		MDY(a.cal_month,1,a.year) as startdate format date9.,
		intnx('month',MDY(a.cal_month,1,a.year),0,'E') as enddate format date9.,
		b.cpi_index,
		a.inc*(1214/CPI_index) as inc_2015q4
	from job_summary a left join sandmaa.TSY_cpi_index_&date. b
		on a.year=b.year and a.quarter=b.quarter;
quit;


* convert to spell event data and filter out the self-employed data;
Data job_summary1;
	set job_summary1;

	*relabel the ACC payment;
	if income_source_code='W&S' then income_source_code='WnS';
	format startdate enddate date9.;
	* exclude spells before DOB;
	if startdate<DOB and enddate<DOB then
		delete;
	if startdate<DOB and enddate>DOB then
		startdate=DOB;
	keep snz_uid income_source_code DOB inc_2015q4 startdate enddate;
	if income_source_code='WnS';
run;

proc datasets lib=work;
delete job_summary ; run;

* combining and brining in Refmth;
data FACT_INC_mth;
set JOB_SUMMARY1(in= a) ;
rate=inc_2015q4/(enddate-startdate+1);
run;

proc datasets lib=work;
delete job_summary1 ; run;


proc sql;
create table FACT_INC_combined
as select
	a.*,
	b.refmth2,
	b.ref_date2
from FACT_INC_mth a left join &population_1. b 
on a.snz_uid=b.snz_uid;


* COMBINE ALL THE SOURCES OF INCOME BY CALENDAR YEAR;
************************************;
* combining;


data FACT_INC_POST;
set FACT_INC_combined(in=a) &population_1.(keep=snz_uid refmth2 ref_date2);
if refmth2>0;
if NOT a then rate=0;
DOB=ref_date2;
do ind=&firstagem. to &lastagem.;
			i=ind-(&firstagem.-1);
			start_window=intnx('MONTH',DOB,i-1,'S');
			end_window=intnx('MONTH',DOB,i,'S')-1;
			%inc_mth(WnS);
/*			%inc_mth(SEI);*/
/*			%inc_mth(ACC);*/
/*			%inc_mth(BEN);*/
/*			%inc_mth(PPL);*/
/*			%inc_mth(STU);*/
/*			%inc_mth(PEN);*/
	if (WnS_(i)>0 and Wns_(i)<10) then do;
	 	WnS_id_(i)=0;
		WnS_(i)=0;
	end;

	if  WnS_(i)>20000 then do;
	 	WnS_id_(i)=1;
		WnS_(i)=20000;
	end;

end;
run;
* large datasets take a lotof space ;
proc datasets  lib=work;
delete job_summary: temp: _ind: T: cor: hos: all: _cost:;
run;

proc summary data=FACT_INC_POST nway;
class snz_uid DOB refmth2 ref_date2;
var 
WNS_&firstagem.-WNS_&lastagem.;
output out=earn_dollars (drop=_:) sum=;run;

proc summary data=FACT_INC_POST nway;
class snz_uid DOB refmth2 ref_date2;
var 
WNS_id_&firstagem.-WNS_id_&lastagem.;
output out=earn_ind (drop=_:) max= ;
run;


data &projectlib.._POST_EARN_mth_&date. ;
merge earn_dollars earn_ind; 
by snz_uid DOB refmth2 ref_date2;

do ind=&firstagem. to &lastagem.;
			i=ind-(&firstagem.-1);

			start_window=intnx('MONTH',DOB,i-1,'S');
			end_window=intnx('MONTH',DOB,i,'S')-1;

	%partialobs_mth(WNS_id_);
	%partialobs_mth(WNS_);

end;
drop DOB;


rename  WNS_&firstagem.-WNS_&lastagem.=WNS_post_&firstagem.-WNS_post_&lastagem.;
rename  WNS_id_&firstagem.-WNS_id_&lastagem.=WNS_id_post_&firstagem.-WNS_id_post_&lastagem.;

run;

proc means data=&projectlib.._POST_EARN_mth_&date. ;run;

%mend; 
