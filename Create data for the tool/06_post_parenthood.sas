
*************************************************************************************************************************************
*************************************************************************************************************************************

DICLAIMER:
This code has been created for research purposed by Analytics and Insights Team, The Treasury. 
The business rules and decisions made in this code are those of author(s) not Statistics New Zealand and The Treasury. 
This code can be modified and customised by users to meet the needs of specific research projects and in all cases, 
Analytics and Insights Team, NZ Treasury must be acknowledged as a source. 
While all care and diligence has been used in developing this code, Statistics New Zealand and The Treasury gives no warranty 
it is error free and will not be liable for any loss or damage suffered by the use directly or indirectly.

*************************************************************************************************************************************
*************************************************************************************************************************************;

*************************************************************************************************************************************
*************************************************************************************************************************************

DICLAIMER:
This code has been modified for research purposes by Evidence and Evaluation Team, Universities New Zealand.
Based off code created by Analytics and Insights Team, The Treasury.
The business rules and decisions made in this code are those of author(s) not Statistics New Zealand and Universities New Zealand
nor The Treasury. 
This code can be modified and customised by users to meet the needs of specific research projects and in all cases, 
Evidence and Evaluation Team, Universities New Zealand must be acknowledged as a source. 
Analytics and Insights Team, NZ Treasury is our source and should also be acknowledge.
While all care and diligence has been used in developing this code, Statistics New Zealand and Universities New Zealand gives no warranty 
it is error free and will not be liable for any loss or damage suffered by the use directly or indirectly.

*************************************************************************************************************************************
*************************************************************************************************************************************
;


*******************************************************************************************************************************************
*******************************************************************************************************************************************

THIS CODE CONTAINS TWO MACROS

Macro "birth_by(datain,dataout,idvar)"-is an assistant macro that automate the repetitive process and included in the main macros that create 
	 annual indicators.
MAIN MACRO 
	Macro "Num_children_pop" - looks at DIA birth records and creates indicators of whether refrence person became a parent and how many chidren
	they given birth or fathered within the window of age and calendar year. 
	Number of chilren is usually 1 or 2 in cases of twins or 3 in cases of triplets

Notes: Only live births are counted ( excludes still births).
		The users should have dataset containing snz_uid and DOB (date of birth ) of reference people


Acronyms:

DIA -Department of Internal Affairs
DOB- Date of Birth

*******************************************************************************************************************************************;
*******************************************************************************************************************************************;
*Picking up records of parent 1, usually MOTHERS
Where our cohort appears as Parent 1;
proc sql;
	create table TEMP_parent1 as select 
		snz_uid as child_snz_uid,
		dia_bir_sex_snz_code as child_sex_snz_code,
		dia_bir_still_birth_code as child_still_birth,
		dia_bir_multiple_birth_code as miltiple_birth,
		dia_bir_birth_month_nbr as birth_month,
		dia_bir_birth_year_nbr as birth_year,
		dia_bir_parent1_child_rel_text as child_parent1_rel,
		parent1_snz_uid,
		(case when parent2_snz_uid=. then 1 else 0 end ) as no_partner
	from dia.births
		where parent1_snz_uid  in (select snz_uid from &population) 
			and MDY(dia_bir_birth_month_nbr,15,dia_bir_birth_year_nbr)<="&sensor"d
			and (parent1_snz_uid ne parent2_snz_uid or parent2_snz_uid=.)
		order by parent1_snz_uid;

	* Picking up records of parent 2, usually FATHERS
	Where our cohort appears as Parent 1;

	* SENSORING TO RELEVANT RECORDS;
proc sql;
	create table TEMP_parent2 as select 
		snz_uid as child_snz_uid,
		dia_bir_sex_snz_code as child_sex_snz_code,
		dia_bir_still_birth_code as child_still_birth,
		dia_bir_multiple_birth_code as miltiple_birth,
		dia_bir_birth_month_nbr as birth_month,
		dia_bir_birth_year_nbr as birth_year,
		dia_bir_parent2_child_rel_text as child_parent2_rel,
		parent2_snz_uid,
		(case when parent1_snz_uid=. then 1 else 0 end ) as no_partner
	from dia.births
		where parent2_snz_uid  in (select snz_uid from &population)
			and MDY(dia_bir_birth_month_nbr,15,dia_bir_birth_year_nbr)<="&sensor"d
			and (parent2_snz_uid ne parent1_snz_uid or parent1_snz_uid=.)
		order by parent2_snz_uid;

	* BUSINESS RULE: Parents should not be the same person and excluding still birth
	* setting appox DOB in a date format;

data TEMP_parent1;
	set TEMP_parent1;

	if child_still_birth not in ("S","D");
	format DIA_bir_DOB date9.;
	DIA_bir_DOB=MDY(birth_month,15,birth_year);
run;

data TEMP_parent2;
	set TEMP_parent2;

	if child_still_birth not in ("S","D");
	format DIA_bir_DOB date9.;
	DIA_bir_DOB=MDY(birth_month,15,birth_year);

run;

* BUSINESS RULE: Use records where DOB of both child and parent is known where child is born after parent is born;
* brining in DOB of the Parent;

proc sql;
	create table TEMP_parent1_1 as select
		a.DIA_bir_DOB,
		a.parent1_snz_uid as snz_uid,
		a.child_parent1_rel,
		a.no_partner,
		b.refdate2,
		b.ter_com_qual
	from TEMP_Parent1 a inner join &population_1. b
		on a.parent1_snz_uid=b.snz_uid;

proc sql;
	create table TEMP_parent2_1 as select
		a.DIA_bir_DOB,
		a.parent2_snz_uid as snz_uid,
		a.child_parent2_rel,
		a.no_partner,
		b.refdate2,
		b.ter_com_qual
	from TEMP_Parent2 a inner join &population_1. b
		on a.parent2_snz_uid=b.snz_uid;


data temp_parent_records;
set TEMP_parent2_1 TEMP_parent1_1;
birth_year = year(DIA_bir_DOB);
birth_month = month(DIA_bir_DOB);
years_after_graduation = intck('year', refdate2, DIA_bir_DOB, 'CONTINUOUS');
age_at_graduation = intck('year', DIA_bir_DOB, refdate2);

months_after_graduation = intck('month', refdate2, DIA_bir_DOB);
fiveth_birthday = intnx('year', DIA_bir_DOB, 5, 'same');
format fiveth_birthday $date9.;

start_month = intck('month', refdate2, DIA_bir_DOB);
end_month = intck('month', refdate2, fiveth_birthday);
run;

data temp_parent_records2;
set temp_parent_records;
array has_young_child_[*] has_young_child_&firstm.-has_young_child_&lastm.;
do ind=&firstm. to &lastm.;
i=ind-(&firstm.-1);
if i >= start_month and i <= end_month then 
has_young_child_(i) = 1;
else
has_young_child_(i) = 0;
end;
run;

proc summary data=temp_parent_records2 nway;
class snz_uid refdate2 ter_com_qual;
var has_young_child_:;
output out=project._post_has_young_child_&date. (drop=_:) max=;
run;


proc datasets lib=work ;
delete TEMP_:;
quit;
