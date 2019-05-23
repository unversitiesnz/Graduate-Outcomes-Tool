
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
**********************************************************************************************************************************
**********************************************************************************************************************************
Owner: Universities New Zealand
Project name : 2018 A4 Student outcomes
Developers : Sarah Randal & Scott Henwood 
Last update date: 13 May 2019

This code integrates all codes using for this project
Step 1: Define base population
 
**********************************************************************************************************************************
**********************************************************************************************************************************
Global paremeters and Libraries

**********************************************************************************************************************************
**********************************************************************************************************************************;

/*%let version=archive;* for IDI refresh version control; * this is June 2018 refresh; */

%let version=20180420;* switching to previour refresh due to mess with Ter completion dataset; 
%let date=10082018; * for dataset version control, the date when refresh was announced;
%let projectlib=project; * the indicators datasets will be saved permanently in this folder

* define path that is long "location/folder" string that will be repeating everywhere;
* this is just shortcut so i dont repeat over and over;
*%let path=/nas/DataLab/MAA/MAA2017-31 Tertiary graduate outcomes 3 and 5 years post graduation/Scott/2018_A4_student_outcomes (SCH)/;
%let path=/nas/DataLab/MAA/MAA2017-31 Tertiary graduate outcomes 3 and 5 years post graduation/2018_A4_student_outcomes.1/;
*libname Project "&path.Datasets";

* create SAS libraries based on version;
%include "&path.codes/Std_libs.txt";

* set projet library;
libname Project "&path.datasets";
options compress=yes reuse=yes ; 

%let first_anal_yr=2003;
%let last_anal_yr=2017;
%let sensor=31Jan2018;

**********************************************************************************************************************************
Set standard macros
**********************************************************************************************************************************;
* CALL AnI generic macros that not related to specific collections;
%include "&path.codes/STAND_macro_new.sas";
* Call macro that includes Common formats;
%include "&path.codes/FORMATS_new.sas";
* call in MOE formats;
%include "&path.codes/pb_formats.sas";

%include "&path.codes/RR3.sas";
**********************************************************************************************************************************
**********************************************************************************************************************************
STEP 1: DEFINE BASE POPULATION
	This is BASE population
	we restricted to those who completed between 2003-2016
	base popualtion that we will refine later
**********************************************************************************************************************************
**********************************************************************************************************************************;
%include "&path.codes/01_base_population.sas"; 

%let population=project.POPULATION_base;
proc sort data=&population; by snz_uid;run;

**********************************************************************************************************************************
**********************************************************************************************************************************

STEP 2: DEMOGRAPHIC VARIABLES
	Consolidates demo variables
	Creates immigration related variables

**********************************************************************************************************************************
**********************************************************************************************************************************;

%include "&path.codes/02_Migration_country_birth_vars.sas";
%include "&path.codes/02_get_ethnicity.sas";
%include "&path.codes/02a_OS_days.sas";

**********************************************************************************************************************************
**********************************************************************************************************************************

STEP 3: Tertiary enrolment and completion

Creates detailed summary of tertiary enrolment related variables
Creates detailed summary of tertiary completion related variables
Created compressed summary of tertiary enrolment and completion 
**********************************************************************************************************************************
**********************************************************************************************************************************;

%include "&path.codes/03_Tertiary_enrol.sas";
%include "&path.codes/03_Tertiary_comp.sas";
%include "&path.codes/03_Tertiary_summary.sas";

**********************************************************************************************************************************
**********************************************************************************************************************************

STEP 5:  Study Population

All information compiled in step 1-4 used to narrow down population of interest
we also create the reference date, which will beused in Step 6

**********************************************************************************************************************************
**********************************************************************************************************************************;

%include "&path.codes/05_Study_population.sas"; 

%let population_1=project.STUDY_POPULATION;
proc sort data=&population_1; by snz_uid;run;

* Reference date will be called refdate2
**********************************************************************************************************************************
**********************************************************************************************************************************

STEP 6: Outcome variables for study popualtion

Days overseas
Days in custody
Days in employment and earnings
Days in Education ( IT and MA included)
GIS variables to trackmovements

**********************************************************************************************************************************
**********************************************************************************************************************************;

%let firstm=0 ; 
%let lastm=72; * Follow up period is 5 years;

%include "&path.codes/06_Post_OS_days.sas"; 
%include "&path.codes/06_Post_Benefit.sas";
%include "&path.codes/06_Post_Education.sas";
%include "&path.codes/06_Post_employment.sas";
%include "&path.codes/06_Post_Custody.sas"; 
%include "&path.codes/06_Post_Location.sas";


* this code needs some work;

**********************************************************************************************************************************
**********************************************************************************************************************************
STEP 7: Summary Results
**********************************************************************************************************************************
**********************************************************************************************************************************;

%include "&path.codes/07_Results_TAB.sas";

**********************************************************************************************************************************
**********************************************************************************************************************************
STEP 8: Calculate underlining counts, suppression and RR3
**********************************************************************************************************************************
**********************************************************************************************************************************;
%include "&path.codes/08_counting_and_rounding.sas";

**********************************************************************************************************************************
**********************************************************************************************************************************
STEP 9: Export
**********************************************************************************************************************************
**********************************************************************************************************************************;
%include "&path.codes/09_Export.sas";