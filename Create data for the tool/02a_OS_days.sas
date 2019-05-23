
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
*********************************************************************************************************************************
*********************************************************************************************************************************
This macro creates days overseas using Customs data
Analyst: Sarah Tumen
QA Analyst: Scott Henwood
Created date: 11 Sep 2014

*********************************************************************************************************************************
*********************************************************************************************************************************;

proc sql;
	create table Overseas as 
		SELECT 
			a.snz_uid,
			datepart(a.pos_applied_date) as startdate format date9.,
			datepart(a.pos_ceased_date) as enddate  format date9.,
			b.DOB
		FROM data.person_overseas_spell a inner join &population. b
			on a.snz_uid = b.snz_uid
			ORDER BY a.snz_uid, a.pos_applied_date;
quit;


data Overseas;
	set Overseas;
	if startdate<"&sensor"d;
	if enddate>"&sensor"d then
		enddate="&sensor"d;
	if startdate<DOB and enddate>DOB then
		startdate=DOB;
	if startdate <DOB and enddate<DOB then
		delete;
run;

%overlap(Overseas);



data Overseas_OR1;
set Overseas_OR;

Start1=MDY(1,1,&first_anal_yr.);

	array OS_da_(*)	OS_da_&first_anal_yr.-OS_da_&last_anal_yr.;

	do ind=&first_anal_yr. to &last_anal_yr.;
		i=ind-(&first_anal_yr.-1);
		OS_da_(i)=0;
/*		start_window=intnx('YEAR',Start1,i,'S');*/
/*		end_window=intnx('YEAR',Start1,i+1,'S')-1;*/
		/*Scott: The above selects a window which missaligns with the OS_da array, the below would select the correct window.*/
		start_window=intnx('YEAR',Start1,i-1,'S');
		end_window=intnx('YEAR',Start1,i,'S')-1;

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
				OS_da_(i)=days;
			end;
	end;
	format start1 start_window end_window date9.;
run;

proc summary data=Overseas_OR1 nway;
	class snz_uid ;
	var OS_da_&first_anal_yr.-OS_da_&last_anal_yr.;
	output out=project._IND_OS_days_yr_&date(drop=_: ) sum=;
run;

proc datasets lib=work;
delete Overseas: deletes;
run;

