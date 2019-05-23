
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


**DEFINE CHILDRENS' RESIDENCE STATUS ;

**Identify those with a DIA birth record;
proc sql;
create table births
as select a.snz_uid
      ,case when dia_bir_sex_snz_code='1' then 1 when dia_bir_sex_snz_code='2' then 2 else . end as dia_sex
      ,dia_bir_birth_month_nbr as dia_birth_month
      ,dia_bir_birth_year_nbr as dia_birth_year
	  ,dia_bir_birth_weight_nbr
	  ,dia_bir_birth_gestation_nbr
from &population. a
left join dia.births b
on a.snz_uid=b.snz_uid
where dia_bir_still_birth_code is null 
order by snz_uid;
quit;

**There is a duplicate birth record for one person;

/*
proc sort data=births nodupkey;
by snz_uid;
run;
*/
data births;
set births;
by snz_uid;
if first.snz_uid;
run;

**identify people with permanent residence approvals, ever;

proc sql;
create table residents
as select snz_uid
  ,snz_dol_uid
  ,dol_dec_decision_date as decision_date
  ,dol_dec_application_type_code as app_code
  ,dol_dec_application_stream_text as stream 
  ,dol_dec_nationality_code as nationality
     /* ,dol_dec_birth_month_nbr as dol_birth_month
      ,dol_dec_birth_year_nbr as dol_birth_year
      ,case when dol_dec_sex_snz_code='1' then 1 when dol_dec_sex_snz_code='2' then 2 else . end as dol_sex*/
from dol.decisions
     where dol_dec_decision_type_code='A' /*Approval*/
     and dol_dec_application_type_code in ('16', '17', '18')
	 and snz_uid in (select distinct snz_uid from &population.)
order by snz_uid, dol_dec_decision_date;
quit;

data res;
set residents;
by snz_uid decision_date;
if first.snz_uid;
run;


**People with temporary visas, ever; 

proc sql;
create table nonresidents
as select snz_uid
  ,snz_dol_uid
  ,dol_dec_decision_date as decision_date
  ,dol_dec_application_type_code as app_code
  ,dol_dec_application_stream_text as stream 
  ,dol_dec_application_criteria_tex as criteria
  ,dol_dec_nationality_code as nationality
      /*
      ,dol_dec_birth_month_nbr as dol_birth_month
      ,dol_dec_birth_year_nbr as dol_birth_year
      ,case when dol_dec_sex_snz_code='1' then 1 when dol_dec_sex_snz_code='2' then 2 else . end as dol_sex*/
from dol.decisions
     where dol_dec_decision_type_code='A' /*Approval*/
     and dol_dec_application_type_code in ('11', '12', '13', '14', '19', '20', '21', '22')
	 and snz_uid in (select distinct snz_uid from &population.)
 order by snz_uid, dol_dec_decision_date;
 quit;

proc sort data=nonresidents;
by snz_uid decision_date;
run;

data nonres;
set nonresidents;
by snz_uid decision_date;
if first.snz_uid;
run;


**Define each person's residence status using prioritisation rules;
**children who eventually get permanent residence will be classified as such;
**At this stage we are creating variables that are fixed in time;

data project._IND_demog;
merge &population.(in=a ) 
    births(in=b keep=snz_uid dia_birth_year) 
    res(in=c keep=snz_uid stream nationality decision_date 
       rename=(stream=perm_res_stream )) 
    nonres(in=d keep=snz_uid nationality stream decision_date rename=(stream=temp_res_stream ));    
by snz_uid;
if a ;
if c then do;
    age_at_approval=floor((intck('month',dob,decision_date)- (day(decision_date) < day(dob))) / 12);
	end;
if dia_birth_year>0 then nzborn=1; else nzborn=0;
if dia_birth_year>0 then res_status=1;  *NZ birth record - prioritised;
else if c then res_status=2;  *Became perm resident - 2nd priority ;
else if d then res_status=4;  **Temp resident, did not convert to permanent;
else  res_status=3; **unrecorded, possibly a NZ or Aus citizen who was born outside nz;
if nzborn=1 then nationality='NZ'; 
if MISSING(nationality) then nationality='UN';
X_CoB_cat=put(nationality, $Country.);

**Only a small fraction of the Australian born can be identified so I am combining them all with NZ born;
if X_CoB_cat='Australia' then X_CoB_cat='New Zealand';
if (perm_res_stream='BUSINESS / SKILLED' or perm_res_stream='RETURNING RESIDENT' ) /*and age_at_approval>=5 */ 
    then demo_mig_skilled=1; else demo_mig_skilled=0;
if perm_res_stream='INTERNATIONAL / HUMANITARIAN' /*and age_at_approval>=5*/ then demo_mig_human=1; else demo_mig_human=0;
if perm_res_stream in ('UNCAPPED FAMILY SPONSORED STREAM', 'PARENT SIBLING ADULT CHILD STREAM') /*and age_at_approval>=5*/ then demo_mig_family=1;
    else demo_mig_family=0;
if res_status=3 then demo_mig_other=1; else demo_mig_other=0;
if res_status=4 then demo_mig_temp=1; else demo_mig_temp=0;
if res_status=1 then demo_migrant=0;
else if demo_mig_skilled=1 then demo_migrant=1;
else if demo_mig_family=1 then demo_migrant=2;
else if demo_mig_human=1 then demo_migrant=3;
else if demo_mig_temp=1 then demo_migrant=4;
else if res_status=3 then demo_migrant=5;
format demo_migrant migf.;

demo_birth_country=put(X_CoB_cat,$newcob.);
/*keep snz_uid demo_:;*/
run;

proc freq data=project._IND_demog;
tables res_status demo_:;
run;
