
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
*********************************************************************************
Owner: Universities New Zealand
Title: post study outcomes, time on benefits by month
Purpose: to find the length of time the individuals under observation have been 
         on a benefit per month, during a pre-determined period calculated using:
         refdate2, &firstm, and &lastm.
Datasets: msd_spell and the study population
Last modified by: Scott Henwood (24/09/2018)
**********************************************************************************
**********************************************************************************;
* DateofBirth isn't used in part A ;

%macro create_MSD_SPELL;

data msd_spel;
 set msd.msd_spell;
%* Formating dates and sensoring;
	format startdate enddate spellfrom spellto date9.;
	spellfrom=msd_spel_spell_start_date;
	spellto=msd_spel_spell_end_date;
	if spellfrom<"&sensor"d;
	if spellfrom<"01Jan1993"d then spellfrom="01Jan1993"d;* BDD left censor;
	if spellto>"&sensor"d then spellto="&sensor"d;
	if spellto=. then spellto="&sensor"d;
	startdate=spellfrom;
	enddate=spellto;
%* TRANSLATING POST REFORM SERVF INTO PRE REFORM FOR OLD TIME SERIES******;
    length ben ben_new $20.;
	if msd_spel_prewr3_servf_code='' then prereform=put(msd_spel_servf_code, $bengp_pre2013wr.); 
	else prereform=put(msd_spel_prewr3_servf_code,$bengp_pre2013wr.);	

* applying wider groupings;
     if prereform in ("Domestic Purposes related benefits", "Widow's Benefit","Sole Parent Support ") then ben='dpb';
else if prereform in ("Invalid's Benefit", "Supported Living Payment related") then ben='ib';
else if prereform in ("Unemployment Benefit and Unemployment Benefit Hardship",
                      "Unemployment Benefit Student Hardship", "Unemployment Benefit (in Training) and Unemployment Benefit Hardship (in Training)") then ben='ub';
else if prereform in ("Job Search Allowance and Independant Youth Benefit") then ben='iyb';
else if prereform in ("Sickness Benefit and Sickness Benefit Hardship") then ben='sb';
else if prereform in ("Orphan's and Unsupported Child's benefits") then ben='ucb';
else ben='othben';

%* TRANSLATING PREREFORM SERVF INTO POST REFORM SERVF FOR NEW TIME SEIRES*****;
length benefit_desc_new $50;
servf=msd_spel_servf_code;
additional_service_data=msd_spel_add_servf_code;
	if  servf in ('602', /* Job Search Allowance - a discontinued youth benefit */
			   	  '603') /* IYB then aft 2012 Youth/Young Parent Payment */	 
		          and additional_service_data ne 'YPP' then benefit_desc_new='1: YP Youth Payment Related' ;/* in 2012 changes some young DPB-SP+EMA moved to YPP */

	else if servf in ('313')   /* EMA(many were young mums who moved to YPP aft 2012) */
		          or additional_service_data='YPP' then benefit_desc_new='1: YPP Youth Payment Related' ;
  
	else if  (servf in (
				   '115', /* UB Hardship */
                   '610', /* UB */
                   '611', /* Emergency Benefit (UB for those that did not qualify)*/
				   '030', /* B4 2012 was MOST WB, now just WB paid overseas) */ 
				   '330', /* Widows Benefit (weekly, old payment system) */ 
				   '366', /* DPB Woman Alone (weekly, old payment system) */
				   '666'))/* DPB Woman Alone */
		 or (servf in ('675') and additional_service_data in (
					'FTJS1', /* JS Work Ready */
					'FTJS2')) /* JS Work Ready Hardship */	
		then benefit_desc_new='2: Job Seeker Work Ready Related'; 

	else if  (servf in ('607', /* UB Student Hardship (mostly over summer holidays)*/ 
				   '608')) /* UB Training */
        or (servf in ('675') and additional_service_data in (
					'FTJS3', /* JS Work Ready Training */
					'FTJS4'))/* JS Work Ready Training Hardship */
		then benefit_desc_new='2: Job Seeker Work Ready Training Related'; 

	else if (servf in('600', /* Sickness Benefit */
				  '601')) /* Sickness Benefit Hardship */ 
		or (servf in ('675') and additional_service_data in (
				'MED1',   /* JS HC&D */
				'MED2'))  /* JS HC&D Hardship */
		then benefit_desc_new='3: Job Seeker HC&D Related' ;

	else if servf in ('313',   /* Emergency Maintenance Allowance (weekly) */
				   '365',   /* B4 2012 DPB-SP (weekly), now Sole Parent Support */
				   '665' )  /* DPB-SP (aft 2012 is just for those paid o'seas)*/
		then benefit_desc_new='4: Sole Parent Support Related' ;/*NB young parents in YPP since 2012*/

	else if (servf in ('370') and additional_service_data in (
						'PSMED', /* SLP */
						'')) /* SLP paid overseas(?)*/ 
		or (servf ='320')    /* Invalids Benefit */
		or (servf='020')     /* B4 2012 020 was ALL IB, now just old IB paid o'seas(?)*/
		then benefit_desc_new='5: Supported Living Payment HC&D Related' ;

	else if (servf in ('370') and additional_service_data in ('CARE')) 
		or (servf in ('367',  /* DPB - Care of Sick or Infirm */
					  '667')) /* DPB - Care of Sick or Infirm */
		then benefit_desc_new='6: Supported Living Payment Carer Related' ;

	else if servf in ('999') /* merged in later by Corrections... */
		then benefit_desc_new='7: Student Allowance';

	else if (servf = '050' ) /* Transitional Retirement Benefit - long since stopped! */
		then benefit_desc_new='Other' ;

	else if benefit_desc_new='Unknown'   /* hopefully none of these!! */;

* applying wider groupings;


     if prereform in ("Domestic Purposes related benefits", "Widow's Benefit","Sole Parent Support ") then ben='DPB';
else if prereform in ("Invalid's Benefit", "Supported Living Payment related") then ben='IB';
else if prereform in ("Unemployment Benefit and Unemployment Benefit Hardship",
                      "Unemployment Benefit Student Hardship", "Unemployment Benefit (in Training) and Unemployment Benefit Hardship (in Training)") then ben='UB';
else if prereform in ("Job Search Allowance and Independant Youth Benefit") then ben='IYB';
else if prereform in ("Sickness Benefit and Sickness Benefit Hardship") then ben='SB';
else if prereform in ("Orphan's and Unsupported Child's benefits") then ben='UCB';
else ben='OTHBEN';

if benefit_desc_new='2: Job Seeker Work Ready Training Related' then ben_new='JSWR_TR';
else if benefit_desc_new='1: YP Youth Payment Related' then ben_new='YP';
else if benefit_desc_new='1: YPP Youth Payment Related' then ben_new='YPP';
else if benefit_desc_new='2: Job Seeker Work Ready Related' then ben_new='JSWR';

else if benefit_desc_new='3: Job Seeker HC&D Related' then ben_new='JSHCD';
else if benefit_desc_new='4: Sole Parent Support Related' then ben_new='SPSR';
else if benefit_desc_new='5: Supported Living Payment HC&D Related' then ben_new='SLP_HCD';
else if benefit_desc_new='6: Supported Living Payment Carer Related' then ben_new='SLP_C';
else if benefit_desc_new='7: Student Allowance' then ben_new='SA';

else if benefit_desc_new='Other' then ben_new='OTH';
if prereform='370' and ben_new='SLP_C' then ben='DPB';
if prereform='370' and ben_new='SLP_HCD' then ben='IB';

if prereform='675' and ben_new='JSHCD' then ben='SB';
if prereform='675' and (ben_new ='JSWR' or ben_new='JSWR_TR') then ben='UB';
	spell=msd_spel_spell_nbr;
	keep snz_uid spellfrom spellto spell servf ben ben_new;
rename spellfrom=startdate;
rename spellto=enddate;

run;

* BDD partner spell table;
data icd_bdd_ptnr;
	set msd.msd_partner;
	format ptnrfrom ptnrto date9.;
	spell=msd_ptnr_spell_nbr;
	ptnrfrom=msd_ptnr_ptnr_from_date;
	ptnrto=msd_ptnr_ptnr_to_date;

	* Sensoring;
	if ptnrfrom>"&sensor"d then
		delete;

	if ptnrto=. then
		ptnrto="&sensor"d;

	if ptnrto>"&sensor"d then
		ptnrto="&sensor"d;
	keep snz_uid partner_snz_uid spell ptnrfrom ptnrto;
run;

* MAIN BENEFITS AS PARTNER (relationship);
proc sql;
	create table prim_mainben_part_data as
		select
			s.partner_snz_uid, s.ptnrfrom as startdate, s.ptnrto as enddate,s.spell,
			s.snz_uid as main_snz_uid

		from  icd_bdd_ptnr  s inner join MSD_spel t
			on t.snz_uid = s.partner_snz_uid
		order by s.snz_uid, s.spell;

/*%**ADD benefit type to the partner's dataset**;*/
/*%**Note that snz_uid+spell does not uniquely identify benefit spells**;*/
/*% *therefore the start and enddate of each spell is also used below to correctly match **;*/
/*%*partner spells to those of the main beneficiary**;*/

/*%** This is done in two steps (1) spells with fully matching start and end dates**;*/
/*%** (2) partner spells that fall within the matching main benefit spell but are not as long** ;*/


proc sort data=msd_spel out=main nodupkey;
	by snz_uid spell startdate enddate;
run;

proc sort data=prim_mainben_part_data out=partner(rename=(main_snz_uid=snz_uid)) nodupkey;
	by main_snz_uid spell startdate enddate;
run;

data fullymatched  unmatched(drop=ben ben_new servf);
	merge partner (in = a)
		main (in = b);
	by snz_uid spell startdate enddate;

	if a and b then
		output fullymatched;
	else if a and not b then
		output unmatched;
run;

proc sql;
	create table partlymatched as
		select a.partner_snz_uid, a.snz_uid, a.spell, a.startdate, a.enddate,
			b.ben, b.ben_new, b.servf
		from unmatched a left join main b
			on a.snz_uid=b.snz_uid and a.spell=b.spell and a.startdate>=b.startdate and (a.enddate<=b.enddate or b.enddate=.) ;
quit;
run;

data prim_mainben_part_data_2;
	set fullymatched partlymatched;
run;

proc freq data=prim_mainben_part_data_2;
	tables ben_new ben;
run;

/*%* CONSOLIDATING BENEFIT SPELLS AS PRIMARY AND PARTNER;*/
data MSD_SPELL;
	set msd_spel (in=a)
		prim_mainben_part_data_2 (in=b);
	if b then
		snz_uid=partner_snz_uid; 
	if b then
		partner_spell_id=1; 
	drop partner_snz_uid ;

/*	* Deleting benefit spells Before DOB of refrence person;*/
/*	if startdate<DOB then*/
/*		output del;*/
/*	else output prim_bennzs_data_1;*/

if ben_new='' then ben_new="OTH";
if ben='' then ben="OTHBEN";
run;

proc sort data = MSD_SPELL;
	by snz_uid startdate enddate;
run;

%overlap(MSD_SPELL);

proc datasets lib=work;
delete 
	MSD_spell_main_part 
	msd_spel msd_spell  
	fullymatched  
	unmatched 
	partlymatched
	prim_mainben_part_data_2
	icd_bdd_ptnr 
	prim_mainben_part_data 
	partner 
	main
	deletes;
run;
%mend;


*********************************************************************************************************************************
Creates Clean and censored MSD spell dataset for given population and removes overlaping spells in the dataset
*********************************************************************************************************************************;

* population has snz_uids ;
* popn_date is unique on snz_uid and refdate (labelled DOB) ; 

%macro create_MSD_SPELL_pop;

%create_msd_spell;

%* limit the records to population of interest;
proc sql;
create table 
msd_spell_OR_pop as select 
a.*,
b.DOB
from msd_spell_OR a inner join &population. b
on a.snz_uid=b.snz_uid
order by snz_uid, DOB ;
quit;

%mend;


*************************************************************************************************************************
Macro creates benefit indicators for days in benefit type
requires: i (index) & days
Scott Henwood: rewrote on 24/09/2018 to decrease exicution times.
*************************************************************************************************************************;
%macro adult_bentype_age(bentype /*benefit code, and used in var/array name.*/);
	array da_&bentype._[*] da_&bentype._&firstm.-da_&bentype._&lastm. ;
	if ben="&bentype." or ben_new="&bentype." then da_&bentype._(i) = days;
	else da_&bentype._(i) = 0;
%mend;

*******************************************************************************************************************************
Creates indicators of days on benefit as an adults for populaton of interest
*******************************************************************************************************************************;

%create_MSD_spell_pop;

* bring in ref date ;
proc sql;
create table MSD_post
as select 
a.*,
b.refdate2,
b.ter_com_qual
from MSD_spell_OR_pop a inner join &population_1. b
on a.snz_uid=b.snz_uid;

* distribute observations by month ;
data MSD_tmp;
set MSD_post;
	format refdate2 date9.;
	array total_da_onben_(*) total_da_onben_&firstm.-total_da_onben_&lastm.;
	array JS_all_da_(*) JS_all_da_&firstm.-JS_all_da_&lastm.;
	* check if observation in one of the targeted categories ;
	if ben in ('DPB', 'IB', 'UB', 'IYB', 'SB', 'UCB', 'OTHBEN') or ben_new in ('DPB', 'IB', 'UB', 'IYB', 'SB', 'UCB', 'OTHBEN') then do;	
		* iterate through months ;
		do ind=&firstm. to &lastm.;
			i=ind-(&firstm.-1);
			days = 0;
			total_da_onben_(i)=0;
			* calculate iteration window ;
			start_window=intnx('MONTH',refdate2,i-1,'S'); 
			end_window=intnx('MONTH',refdate2,i,'S')-1;
			* check if observation valid for any time during the iteration window ;
			if not((startdate > end_window) or (enddate < start_window)) then do;

				if (startdate <= start_window) and  (enddate > end_window) then
					days=(end_window-start_window)+1;
				else if (startdate <= start_window) and  (enddate <= end_window) then
					days=(enddate-start_window)+1;
				else if (startdate > start_window) and  (enddate <= end_window) then
					days=(enddate-startdate)+1;
				else if (startdate > start_window) and  (enddate > end_window) then
					days=(end_window-startdate)+1;	
									
				total_da_onben_(i)=days; * SCH: I assume both the ben and new_ben will not have valid values in different catigories;
				%adult_bentype_age(DPB);
				%adult_bentype_age(IB);
				%adult_bentype_age(UB);
				%adult_bentype_age(IYB);
				%adult_bentype_age(SB);
				%adult_bentype_age(UCB);
				%adult_bentype_age(OTHBEN);

			end; * end window check ;		

/*					%adult_bentype_age(YP);*/
/*					%adult_bentype_age(YPP);*/
/*					%adult_bentype_age(SPSR);*/
/*					%adult_bentype_age(SLP_C);*/
/*					%adult_bentype_age(SLP_HCD);*/
					%adult_bentype_age(JSWR);
					%adult_bentype_age(JSWR_TR);
					%adult_bentype_age(JSHCD);
/*					%adult_bentype_age(OTH);*/

		if da_JSWR_(i)>0 or da_JSWR_TR_(i)>0 or da_JSHCD_(i)>0 then JS_all_da_(i)=1; else JS_all_da_(i)=0;
		* We might need brakdown by each benefit type but at this stage interested in total ;
		end; * end month iteration ;
	end; * end targeted benefit check ;
run;

* summarise per person (SCH: currently only keeping the total) ;
proc summary data=MSD_tmp nway;
class snz_uid refdate2 ter_com_qual;
var total_da_: JS:;
* keeping total and job seeker related benefits;
output out=_POST_BEN_adult_&date(drop=_type_ _freq_) sum=;
run;

* remove partial observations, and save dataset to project;
data project._POST_BEN_adult_mth_&date; 
set _POST_BEN_adult_&date;

do ind=&firstm. to &lastm.;
	i=ind-(&firstm.-1);
	start_window=intnx('MONTH',refdate2,i-1,'S');
	end_window=intnx('MONTH',refdate2,i,'S')-1;
 
end;
drop start_window end_window ind i ;*/;

rename total_da_onben_&firstm.-total_da_onben_&lastm.=total_da_onben_post_&firstm.-total_da_onben_post_&lastm.;
rename JS_all_da_&firstm.-JS_all_da_&lastm.=JS_all_da_post_&firstm.-JS_all_da_post_&lastm.;

run;

proc datasets lib=work;
delete MSD: ;
run;

proc means data=project._POST_BEN_adult_mth_&date;
var total_da_onben_: JS_all_da_:;
run;