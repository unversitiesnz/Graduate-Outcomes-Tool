
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

****************************************************************************************************************************
****************************************************************************************************************************

CORRECTIONS DATA CORRECTIONS DATA CORRECTIONS DATA CORRECTIONS DATA CORRECTIONS DATA CORRECTIONS DATA
		PRISON	Prison sentenced	PRISON
		REMAND	Remanded in custody		PRISON
		ESO	Extended supervision order	COMMUNITY
		HD_REL	Released to HD	HOME
		PAROLE	Paroled	COMMUNITY
		ROC	Released with conditions	COMMUNITY
		HD_SENT	Home detention sentenced	HOME
		PDC	Post detention conditions	COMMUNITY
		INT_SUPER	Intensive supervision	COMMUNITY
		COM_DET	Community detention	COMMUNITY
		SUPER	Supervision	COMMUNITY
		CW	Community work		COMMUNITY
		PERIODIC	Periodic detention		COMMUNITY
		COM_PROG	Community programme		COMMUNITY
		COM_SERV	Community service		COMMUNITY
		OTH_COM	Other community		COMMUNITY


***********************************************************************************************************************
***********************************************************************************************************************
* COURTS DATASET INDICATORS 
* Nbr APPEARANCES IN YOUTH COURT, Nbr PROVEN OFFENCES (incl youth and adult courts), Nbr CONVICTIONS(youth and adult courts);
* This section of code written by Sylvia Dixon on 25 September;
* The measure of proven offences is generated because Youth Courts generally don't convict offenders even when the charge is proven.
   Adult courts also discharge some offenders without conviction;
**Note that breaches (of a sentences for a prior offence) are excluded from the 'conviction' and 'proven offences' 
  indicators created here, following advice from Charles Sullivan;
**The conviction and proven offence measures count all charges that the person was convicted of - note that there
  can be multiple charges associated with one criminal act, and multiple charges and convictions on a single day;
**Use the outcome dates if you wish to create a measure of the number of court appearances;

****************************************************************************************************************************
TWO macros that assist in creation of correction indicators for reference person
****************************************************************************************************************************;

*********************************************************************************************************************************************************
Create Correction indicators for population of interest
*********************************************************************************************************************************************************;

proc sql;
	create table COR as
		SELECT distinct 
		 snz_uid,
			cor_mmp_period_start_date as startdate ,
			cor_mmp_period_end_date as enddate,
			cor_mmp_mmc_code,  
           /* Creating wider correction sentence groupings */
	    	(case when cor_mmp_mmc_code in ('PRISON','REMAND' ) then 'Cust'
			     when cor_mmp_mmc_code in ('HD_SENT','HD_SENT', 'HD_rel' ) then 'Cust'
                 when cor_mmp_mmc_code in ('ESO','PAROLE','ROC','PDC' ) then 'Post_Re'
				 when cor_mmp_mmc_code in ('COM_DET','CW','COM_PROG','COM_SERV' ,'OTH_COMM','INT_SUPER','SUPER','PERIODIC') then 'Comm'
                 else 'OTH' end) as sentence 
		FROM COR.ov_major_mgmt_periods 
		where snz_uid in (SELECT DISTINCT snz_uid FROM &population_1.) 
		/* exclude birthdate and aged out records */
		AND cor_mmp_mmc_code IN ('PRISON','REMAND','HD_SENT','HD_REL','ESO','PAROLE','ROC','PDC','PERIODIC',
			'COM_DET','CW','COM_PROG','COM_SERV','OTH_COMM','INT_SUPER','SUPER')

		ORDER BY snz_uid,startdate;
quit;

data COR;
set COR;
if startdate > enddate then delete;
format startdate enddate date9.;
run;

%OVERLAP (COR);

* add refdate2 ;
proc sql;
create table COR_1 as select
a.* ,
b.refdate2,
b.ter_com_qual
from COR_OR a inner join &population_1. b
on a.snz_uid=b.snz_uid
order by a.snz_uid, startdate;

* clean corrections data based on dates ;
data COR_clean; 
set COR_1; 
by snz_uid startdate;
if startdate>"&sensor"d then delete;
if enddate < refdate2 then delete;
if enddate>"&sensor"d then enddate="&sensor"d;
if startdate<=enddate;
run;
* distribute days on sentence by months ;
data COR_clean2;
set COR_clean;

	array COR_cust_da_(*)	COR_cust_da_&firstm.-COR_cust_da_&lastm.;
/*	array COR_HD_da_(*)	COR_HD_da_&firstm.-COR_HD_da_&lastm.;*/
/*	array COR_Post_Re_da_(*)	COR_Post_Re_da_&firstm.-COR_Post_Re_da_&lastm.;*/
/*	array COR_Comm_da_(*)	COR_Comm_da_&firstm.-COR_Comm_da_&lastm.;*/
/*	array COR_OTH_da_(*)	COR_OTH_da_&firstm.-COR_OTH_da_&lastm.;*/
	* iterate through months ;
	do ind=&firstm. to &lastm.;
		i=ind - &firstm. + 1; /*1 based arrays, take away the first value from the current value and add one*/
		COR_cust_da_(i)=0;
/*		COR_HD_da_(i)=0;*/
/*		COR_Post_Re_da_(i)=0;*/
/*		COR_Comm_da_(i)=0;*/
/*		COR_OTH_da_(i)=0;*/
		* calculate iteration window ;
		start_window=intnx('MONTH',refdate2,i-1,'S'); 
		end_window=intnx('MONTH',refdate2,i,'S')-1;
		* check if observation valid for any time during the iteration window ;
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

				if days>0 and sentence='Cust' then COR_cust_da_(i)=days;
/*					when ('HD') COR_HD_da_(i)=days;*/
/*					when ('Post_Re') COR_Post_Re_da_(i)=days;*/
/*					when ('Comm') COR_Comm_da_(i)=days;*/
/*					when ('OTH') COR_OTH_da_(i)=days;*/
			end; * end check window ;
	end; * end month iteration ;
	format start_window end_window date9.;
run;

* summaise per person for categories ;
proc summary data=COR_clean2 nway;
class snz_uid refdate2 ter_com_qual;
var 
COR_cust_da_&firstm.-COR_cust_da_&lastm. 
/*COR_HD_da_&firstm.-COR_HD_da_&lastm. */
/*COR_Post_Re_da_&firstm.-COR_Post_Re_da_&lastm. COR_Comm_da_&firstm.-COR_Comm_da_&lastm.*/
/*COR_OTH_da_&firstm.-COR_OTH_da_&lastm.*/
;
output out=project._POST_Corr_&date.(drop=_:) sum=;
run;

proc datasets lib=work;
delete COR: ; run;

proc means data= project._POST_Corr_&date.;
var COR_cust_da_:;
run;