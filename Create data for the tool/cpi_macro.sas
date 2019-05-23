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
***************************************************************
prep cpi dataset for month windows based off refdate.
cpi to desired time
given a ref date, record the cpi numbers for each of the following [72] months
***************************************************************;
%macro create_cpi_set(cpi_target_pop, cpi_set /*the dataset to store the cpi series*/);
proc sql;

create table targeted_refdates as
select distinct refdate2 from &cpi_target_pop.
where refdate2 < "&sensor"d
;
quit;
* for every ref date, calculate the following [72] months, output each as seperate observations ;
data ref_mth (keep=refdate2 i year month quarter); 
	set targeted_refdates;
	do ind=&firstm. to &lastm.;
		i = ind + 1;
		start_window=intnx('MONTH',refdate2,i-1,'S'); 
		end_window=intnx('MONTH',refdate2,i,'S')-1;
		year = year(start_window);
		month = month(start_window);
		select (month);
			when (1, 2, 3) quarter = 1;
			when (4, 5, 6) quarter = 2;
			when (7, 8, 9) quarter = 3;
			when (10, 11, 12) quarter = 4;
		end;
		output;
	end;
run;
* get cpi for each month of interest ;
proc sql;
create table cpi_mth as
select refdate2, i, cpi.*  from ref_mth ref left join project.cpi_index_base2017 cpi on ref.year = cpi.year and ref.quarter = cpi.quarter;
quit;

proc sort data=cpi_mth; By refdate2 i;
* assign cpi value to correct point in array ;
data cpi_mth_array;
set cpi_mth;
array CPI_mth_(*) CPI_mth_&firstm.-CPI_mth_&lastm.;
CPI_mth_(i) = CPI_index;
run;
* merge cpi array into one observation per refdate ;
proc summary data=cpi_mth_array nway; 
	class refdate2;
	var CPI_mth_&firstm.-CPI_mth_&lastm.;
	output out=&cpi_set. (drop=_: ) max=;
run;
* sort for merge by refdate ;
proc sort data=&cpi_set.; by refdate2;

proc datasets lib=work;
delete targeted_refdates ref_mth cpi_mth cpi_mth_array; run;
%mend;
/* 
Author: Scott Henwood
macro to apply cpi for the given varible, use inside loop. 
line required before: array CPI_mth_(*)	CPI_mth_&firstm.-CPI_mth_&lastm.;
*/
%macro apply_cpi_to_i(var_name, index, current_cpi = 1006);
array &var_name.(*)	&var_name.&firstm.-&var_name.&lastm.;

&var_name.(&index) = &var_name.(&index)*(&current_cpi./CPI_mth_(&index));
%mend apply_cpi_to_i;
*******************************************************
End CPI prep
;


