
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

*****************************************************************************************************************************************
Create Tertiary completions indicators
******************************************************************************************************************************************;
%contents(moe.completion);
%freq(moe.completion,moe_com_qual_level_code*moe_com_year_nbr);
/*%contents(sandmoe.tertiary_completions);*/
/*%freq(sandmoe.tertiary_completions,year )*/

proc sql;
	create table TER_compl as
		select  distinct 
			snz_uid,
			moe_com_year_nbr as year,
			moe_com_qual_code as qual,
			moe_com_provider_code as provider,
			put(moe_com_qacc_code,$lv8id.) as qual_type,
			moe_com_qacc_code as actual_qacc,
			moe_com_qual_level_code as level,
			substr(moe_com_qual_nzsced_code,1,2) as NZSCED,
			moe_com_qual_nzsced_code as NZSCED_detailed,
			moe_com_field_main1_code as NZSCED_main_1,
			moe_com_field_main2_code as NZSCED_main_2,
			moe_com_field_main3_code as NZSCED_main_3
		from moe.completion
			where snz_uid in
				(select distinct snz_uid from &population.)
					and MDY(12,31,moe_com_year_nbr)<="&sensor"d
			and moe_com_year_nbr>=2000 ;
quit;

data TER_compl; 
set TER_compl;
com_provider_code=1*provider;
com_level=1*level;
run;

proc sort data=sandmoe.moe_provider_lookup_table Out=moe_provider_lookup_table nodupkey; 
by provider_code; 
run;

* plugin subsector;
proc sql;
create table TER_compl_1
as select 
	a.*,
	b.provider_type as subsector
from TER_compl a 
left join 
moe_provider_lookup_table b
on a.com_provider_code=b.provider_code;

%freq(TER_compl_1,com_level subsector );

data project.TERTIARY_COMPL_raw_&date.; set TER_compl_1;
run;

proc datasets lib=work;
delete Ter_: com: temp;
run;

