
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

* Do right sensoring;
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

* part B, adding reference date variable to count events in relation to reference date;

proc sql;
create table Overseas_REF
as select
a.*,
b.refdate2,
b.ter_com_qual
from Overseas_OR a inner join &population_1. b
on a.snz_uid=b.snz_uid;



data Overseas_OR1;
set Overseas_REF;
	array OS_da_(*)	OS_da_&firstm.-OS_da_&lastm.;

	do ind=&firstm. to &lastm.;
		i=ind-(&firstm.-1);
		OS_da_(i)=0;
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
				OS_da_(i)=days;
			end;
	end;
	format start_window end_window date9.;
run;
proc means data=Overseas_OR1;
run;
proc summary data=Overseas_OR1 nway;
	class snz_uid refdate2 ter_com_qual;
	var OS_da_&firstm.-OS_da_&lastm.;
	output out=_post_OS_spells_mth_&date(drop=_: ) sum=;
run;

proc means data=_post_OS_spells_mth_&date;
run;

data project._POST_OS_spells_mth_&date; 
retain snz_uid refdate2 ter_com_qual;
set _post_OS_spells_mth_&date;

do i=&firstm. to &lastm.;
			age=i-(&firstm.-1);
			start_window=intnx('MONTH',refdate2,age-1,'S');
			end_window=intnx('MONTH',refdate2,age,'S')-1;

end;

rename OS_da_&firstm.-OS_da_&lastm.=OS_da_post_&firstm.-OS_da_post_&lastm.;
drop i age start_window end_window;
run;

proc datasets lib=work;
delete Overseas_OR: Overseas deletes;
run;



