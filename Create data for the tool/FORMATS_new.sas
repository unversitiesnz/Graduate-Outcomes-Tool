proc format;
value $outLvlI
	'1','2' = '1'
	'3' = '2'
	'4' = '3'
	'5','6' = '4'
	'7' = '5'
	'8' = '6'
;
run;

proc format;
value $outLvl
	'1' = "Level 1-4 Certificates"
	'2' = 'Certificates and Diploma Level 5-7'
	'3' = 'Bachelor Degrees'
	'4' = 'Honours, Postgrad Diploma and Certs'
	'5' = 'Masters degrees'
	'6' = 'Doctoral degrees'
;
run;

proc format;
value agebands
low-24='1 Under24'
25-29='2 25-29'
30-34='3 30-34'
35-44='4 35-44'
45-54='5 45-54'
55-high='6 55above';
run;


*** region of citizenship;
proc format;
value $citreg 
		"ABW"	=	"Central and South America"
		"AFG"	=	"Asia"
		"AGO"	=	"Africa"
		"AIA"	=	"Central and South America"
		"ALB"	=	"Europe"
		"AND"	=	"Europe"
		"ANT"	=	"Central and South America"
		"ARE"	=	"Middle East"
		"ARG"	=	"Central and South America"
		"ARM"	=	"Europe"
		"ASM"	=	"Pacific"
		"ATG"	=	"Central and South America"
		"AUS"	=	"Pacific"
		"AUT"	=	"Europe"
		"AZE"	=	"Europe"
		"BDI"	=	"Africa"
		"BEL"	=	"Europe"
		"BEN"	=	"Africa"
		"BFA"	=	"Africa"
		"BGD"	=	"Asia"
		"BGR"	=	"Europe"
		"BHR"	=	"Middle East"
		"BHI"	=	"Europe"
		"BHS"	=	"Central and South America"
		"BLR"	=	"Europe"
		"BLZ"	=	"Central and South America"
		"BMU"	=	"Northern America"
		"BOL"	=	"Central and South America"
		"BRA"	=	"Central and South America"
		"BRB"	=	"Central and South America"
		"BRN"	=	"Asia"
		"BTN"	=	"Asia"
		"BWA"	=	"Africa"
		"CAF"	=	"Africa"
		"CAN"	=	"Northern America"
		"CHE"	=	"Europe"
		"CHL"	=	"Central and South America"
		"CHN"	=	"Asia"
		"CIV"	=	"Africa"
		"CMR"	=	"Africa"
		"COD"	=	"Africa"
		"COG"	=	"Africa"
		"COL"	=	"Central and South America"
		"COM"	=	"Africa"
		"CPV"	=	"Middle East"
		"CRI"	=	"Central and South America"
		"CUB"	=	"Central and South America"
		"CYM"	=	"Central and South America"
		"CYP"	=	"Europe"
		"CZE"	=	"Europe"
		"DEU"	=	"Europe"
		"DJI"	=	"Africa"
		"DMA"	=	"Central and South America"
		"DNK"	=	"Europe"
		"DOM"	=	"Central and South America"
		"DZA"	=	"Middle East"
		"ECU"	=	"Central and South America"
		"EGY"	=	"Africa"
		"ERI"	=	"Africa"
		"ESH"	=	"Africa"
		"ESP"	=	"Europe"
		"EST"	=	"Europe"
		"ETH"	=	"Africa"
		"FIN"	=	"Europe"
		"FJI"	=	"Pacific"
		"FLK"	=	"Central and South America"
		"FRA"	=	"Europe"
		"FRO"	=	"Europe"
		"FSM"	=	"Pacific"
		"GAB"	=	"Africa"
		"GBR"	=	"Europe"
		"GEO"	=	"Europe"
		"GHA"	=	"Africa"
		"GIB"	=	"Europe"
		"GIN"	=	"Africa"
		"GJS"	=	"Europe"
		"GMB"	=	"Africa"
		"GNB"	=	"Africa"
		"GNQ"	=	"Africa"
		"GRC"	=	"Europe"
		"GRD"	=	"Central and South America"
		"GRL"	=	"Europe"
		"GTM"	=	"Central and South America"
		"GUF"	=	"Central and South America"
		"GUM"	=	"Pacific"
		"GUY"	=	"Central and South America"
		"HKG"	=	"Asia"
		"HND"	=	"Central and South America"
		"HRV"	=	"Europe"
		"HTI"	=	"Central and South America"
		"HUN"	=	"Europe"
		"IDN"	=	"Asia"
		"IND"	=	"Asia"
		"IOM"	=	"Europe"
		"IRL"	=	"Europe"
		"IRN"	=	"Middle East"
		"IRQ"	=	"Middle East"
		"ISL"	=	"Europe"
		"ISR"	=	"Middle East"
		"ITA"	=	"Europe"
		"JAM"	=	"Central and South America"
		"JOR"	=	"Middle East"
		"JPN"	=	"Asia"
		"KAZ"	=	"Europe"
		"KEN"	=	"Africa"
		"KGZ"	=	"Europe"
		"KHM"	=	"Asia"
		"KIR"	=	"Pacific"
		"KNA"	=	"Central and South America"
		"KOR"	=	"Asia"
		"KWT"	=	"Middle East"
		"LAO"	=	"Asia"
		"LBN"	=	"Middle East"
		"LBR"	=	"Africa"
		"LBY"	=	"Middle East"
		"LCA"	=	"Central and South America"
		"LIE"	=	"Europe"
		"LKA"	=	"Asia"
		"LSO"	=	"Africa"
		"LTU"	=	"Europe"
		"LUX"	=	"Europe"
		"LVA"	=	"Europe"
		"MAC"	=	"Asia"
		"MAR"	=	"Middle East"
		"MCO"	=	"Europe"
		"MDA"	=	"Europe"
		"MDG"	=	"Africa"
		"MDV"	=	"Asia"
		"MEX"	=	"Central and South America"
		"MHL"	=	"Pacific"
		"MKD"	=	"Europe"
		"MLI"	=	"Africa"
		"MLT"	=	"Europe"
		"MMR"	=	"Asia"
		"MNG"	=	"Asia"
		"MNP"	=	"Pacific"
		"MOZ"	=	"Africa"
		"MRT"	=	"Middle East"
		"MSR"	=	"Central and South America"
		"MTQ"	=	"Central and South America"
		"MUS"	=	"Africa"
		"MWI"	=	"Africa"
		"MYS"	=	"Asia"
		"NAM"	=	"Africa"
		"NCL"	=	"Pacific"
		"NER"	=	"Africa"
		"NGA"	=	"Africa"
		"NIC"	=	"Central and South America"
		"NLD"	=	"Europe"
		"NOR"	=	"Europe"
		"NPL"	=	"Asia"
		"NRU"	=	"Pacific"
		"NZL"	=	"Pacific"
		"NZP"	=	"Pacific"
		"OMN"	=	"Middle East"
		"PAK"	=	"Asia"
		"PAL"	=	"Middle East"
		"PAN"	=	"Central and South America"
		"PCN"	=	"Pacific"
		"PER"	=	"Central and South America"
		"PHL"	=	"Asia"
		"PLW"	=	"Pacific"
		"PNG"	=	"Pacific"
		"POL"	=	"Europe"
		"PRI"	=	"Central and South America"
		"PRK"	=	"Asia"
		"PRT"	=	"Europe"
		"PRY"	=	"Central and South America"
		"PYF"	=	"Pacific"
		"QAT"	=	"Middle East"
		"REU"	=	"Africa"
		"ROU"	=	"Europe"
		"RUS"	=	"Europe"
		"RWA"	=	"Africa"
		"SAU"	=	"Middle East"
		"SCG"   =   "Europe"
		"SDN"	=	"Africa"
		"SEN"	=	"Africa"
		"SGP"	=	"Asia"
		"SHN"	=	"Africa"
		"SLB"	=	"Pacific"
		"SLE"	=	"Africa"
		"SLV"	=	"Central and South America"
		"SMR"	=	"Europe"
		"SOM"	=	"Africa"
		"SPM"	=	"Northern America"
		"STP"	=	"Africa"
		"SUR"	=	"Central and South America"
		"SVK"	=	"Europe"
		"SVN"	=	"Europe"
		"SWE"	=	"Europe"
		"SWZ"	=	"Africa"
		"SYC"	=	"Africa"
		"SYR"	=	"Middle East"
		"TCA"	=	"Central and South America"
		"TCD"	=	"Africa"
		"TGO"	=	"Africa"
		"THA"	=	"Asia"
		"TJK"	=	"Europe"
		"TKM"	=	"Europe"
		"TLS"	=	"Asia"
		"TON"	=	"Pacific"
		"TTO"	=	"Central and South America"
		"TUN"	=	"Middle East"
		"TUR"	=	"Middle East"
		"TUV"	=	"Pacific"
		"TWN"	=	"Asia"
		"TZA"	=	"Africa"
		"UGA"	=	"Africa"
		"UKR"	=	"Europe"
		"URY"	=	"Central and South America"
		"USA"	=	"Northern America"
		"UZB"	=	"Europe"
		"VAT"	=	"Europe"
		"VCT"	=	"Central and South America"
		"VEN"	=	"Central and South America"
		"VGB"	=	"Central and South America"
		"VIR"	=	"Central and South America"
		"VNM"	=	"Asia"
		"VUT"	=	"Pacific"
		"WSM"	=	"Pacific"
		"YEM"	=	"Middle East"
		"YUG"	=	"Europe"
		"ZAF"	=	"Africa"
		"ZMB"	=	"Africa"
		"ZWE"	=	"Africa"
		""		=	"Unknown";

run;

proc format;
value osdur
       .,low-<.10='a<10%  '
		.10-<.50='b10-<50%'
		.50-high='c50%+   ';
run;


proc format;
value wnsdays
   .='aMissing'
   0='bNone'
   1<-182='c1-6mths'
   182<-365='d6-12mths'
   365<-730='e1-2yrs'
   730<-1095='f2-3yrs'
   1095<-1460='g3-4yrs'
   1460<-high='h4-5yrs';
run;

proc format;
value ages
., low-0 ='aMissing'
1-17='bLT18'
18-19='c18-19'
20-24='d20-24'
25-29='e25-29'
30-high='f30+';
run;

proc format;
value nbrchn
.='aMissing'
0-1='b0-1'
2-3='c2-3'
4-5='d4-5'
6-high='e6+';
run;

proc format;
value inc
.='aMissing'
0='bNone'
0.0000000001-<5000='cLT$5k'
5000-<10000='d$5-$10k'
10000-<20000='e$10-$20k'
20000-<30000='f$20-$30k'
30000-<50000='g$30-$50k'
50000-<75000='h$50-$75k'
75000-<100000='i$75-$100k'
100000-high='j$100k+';
run;

proc format;
value ben
.='aMissing'
0='bNone'
0.00000001-<5000='cLT$5k'
5000-<10000='d$5-$10k'
10000-<15000='e$10-$15k'
15000-high='f$15k+';
run;


proc format;
value benb
.='aMissing'
0='bNone'
0.0005-<5000='cLT$5k'
5000-high='d$5k+';
run;


proc format;
	value bendur
		.,low-0='aNone  '
		  0<-.10='b1-10%'
		.10<-.25='c11-25%'
		.25<-.50='d26-50%'
		.50<-.75='e50-75%'
		.75<-high='f75+%';


proc format;
value migf
0='aNZborn'
1='bPermRes_skilled'
2='cPermRes_family'
3='dPermRes_int'
4='eTempRes'
5='fNonVisa';
run;

proc format;
value yrs_app
.='aNA'
-1,0,1,2,3='b0-3yrs'
4-8='c4-8yrs'
9-12='d9-12yrs'
13-high='e13+yrs';
run;

proc format;
value address
.='aMissing'
1-2='b1-2'
3-4='c3-4'
5-high='d5+';
run;

proc format;
value naddr
.,0-1='a0-1'
2-4='b2-4'
5-high='c5+';
run;


proc format;
value justice
.='aMissing'
1='bCustody'
2='cCommunity'
3='dCharge'
4='eNone';
run;

**Variable labels;

proc format;
value $ labels
'x_female'='Gender'
'x_maori'	='Maori'
'X_m_age_first_ch_cat' =	"Mother's age at birth of first child"
'X_mat_edu_noqual' =	'Mother has no qualifications'
'x_asian'	= 'Asian'
'X_ch_not'	= 'CYF care and protection notification'
'X_f_totinc_sum_cat'=	"Father's earned income" 
'X_f_justice_cat' =	"Father's justice sector history"
'X_m_totinc_sum_cat' =	"Mother's earned income" 
'X_m_justice_cat' =	"Mother's justice sector history"
'x_pacific' =	'Pacific ethnicity'
'X_mother_age_atbirth' =	"Mother's age at birth"
'X_m_STE_sum_cat' =	"Mother's second tier benefit income"
'X_m_WnS_da_sum_cat' =	"Mother's time in wage or salaried employment"
'X_f_WnS_da_sum_cat' =	"Father's time in wage or salaried employment"
'X_prop_onben_aschild' =	"Proportion of childhood supported by benefit"
'X_f_FTE_sum_cat' =	"Father's first tier benefit income"
'X_prop_os_aschild_ca' =	"Proportion of childhood overseas"
'X_f_not_DIA' =	"Father not listed on birth certificate"
'X_child_bentype' =	"Main benefit type in childhood"
'X_newcob_cat'	 ="Country of birth"
'X_m_FTE_sum_cat' =	"Mother's first tier benefit income"
'X_m_chn_atbirth_cat' =	"Mother's number of children at birth reference child"
'X_migrant'	 ="Migrant category"
'x_otheth'	 ="Other ethnic group"
'X_single_parent_chd_at_birth'	 ="Mother a single parent at birth"
'X_m_not_DIA' =	"Current female caregiver not birth mother"
'X_f_STE_sum_cat' =	"Father's second tier benefit income"
'X_yrs_since_app_cat' =	"Years since residence approval"
'X_ch_any_fdgs_abuse' =	"CYF findings of abuse or neglect"
'X_father_age_atbirth' =	"Father's age at birth"
'X_ch_CYF_place' =	"CYF care and protection placement"
'x_european' =	'European'
'X_past5_add_changes_' = 'Number addresses in last 5 years'
'X_ch_YJ_referral' = 'CYF youth justice referral'
'X_ch_YJ_place' = 'CYF youth justice placement'
;
run;






proc format;
value $ newcob
'Polynesia (excludes Hawaii)'='Polynesia (excludes Hawaii)'
'New Zealand'='New Zealand'
'Missing'='Missing'
'MELAA'='MELAA'
'United Kingdom'='United Kingdom'
other='Other';


proc format;
value migf
0='aNZborn'
1='bPermRes_skilled'
2='cPermRes_family'
3='dPermRes_int'
4='eTempRes'
5='fNonVisa';
run;



proc format;
value $Country 
' '='Missing'
'01'='Missing'
'02'='Missing'
'03'='Missing'
'AE'='MELAA'
'AF'='Central Asia'
'AL'='Europe exc. U.K.'
'AM'='Central Asia'
'AN'='Missing'
'AO'='MELAA'
'AR'='MELAA'
'AS'='Polynesia (excludes Hawaii)'
'AT'='Europe exc. U.K.'
'AU'='Australia'
'AZ'='Central Asia'
'BA'='Europe exc. U.K.'
'BB'='MELAA'
'BD'='Southern Asia'
'BE'='Europe exc. U.K.'
'BG'='Europe exc. U.K.'
'BH'='MELAA'
'BI'='MELAA'
'BM'='Northern America'
'BN'='Europe exc. U.K.'
'BO'='Europe exc. U.K.'
'BR'='MELAA'
'BT'='Central Asia'
'BW'='MELAA'
'BY'='Europe exc. U.K.'
'BZ'='MELAA'
'CA'='Northern America'
'CD'='MELAA'
'CG'='MELAA'
'CH'='Europe exc. U.K.'
'CK'='Polynesia (excludes Hawaii)'
'CL'='MELAA'
'CM'='MELAA'
'CN'='Central Asia'
'CO'='MELAA'
'CR'='MELAA'
'CS'='Europe exc. U.K.'
'CU'='MELAA'
'CY'='Europe exc. U.K.'
'CZ'='Europe exc. U.K.'
'DE'='Europe exc. U.K.'
'DK'='Europe exc. U.K.'
'DM'='MELAA'
'DO'='MELAA'
'DZ'='MELAA'
'DJ'='MELAA'
'EC'='MELAA'
'EE'='Europe exc. U.K.'
'EG'='MELAA'
'ER'='MELAA'
'ES'='Europe exc. U.K.'
'ET'='MELAA'
'FI'='Europe exc. U.K.'
'FJ'='Polynesia (excludes Hawaii)'
'FM'='Missing'
'FR'='Europe exc. U.K.'
'GA'='MELAA'
'GB'='United Kingdom'
'GE'='Central Asia'
'GH'='MELAA'
'GM'='MELAA'
'GN'='MELAA'
'GR'='Europe exc. U.K.'
'GT'='MELAA'
'GY'='MELAA'
'HT'='MELAA'
'HK'='North-East Asia'
'HN'='MELAA'
'HR'='Europe exc. U.K.'
'HU'='Europe exc. U.K.'
'ID'='Maritime South-East Asia'
'IE'='United Kingdom'
'IL'='MELAA'
'IN'='Southern Asia'
'IQ'='MELAA'
'IR'='MELAA'
'IS'='Europe exc. U.K.'
'IT'='Europe exc. U.K.'
'JM'='MELAA'
'JO'='MELAA'
'JP'='North-East Asia'
'KE'='MELAA'
'KG'='Central Asia'
'KH'='Mainland South-East Asia'
'KI'='Missing'
'KN'='MELAA'
'KR'='North-East Asia'
'KW'='MELAA'
'KY'='MELAA'
'KZ'='Central Asia'
'LA'='Southern Asia'
'LB'='MELAA'
'LC'='MELAA'
'LI'='Europe exc. U.K.'
'LK'='Southern Asia'
'LR'='MELAA'
'LT'='Europe exc. U.K.'
'LU'='Europe exc. U.K.'
'LV'='Europe exc. U.K.'
'LY'='MELAA'
'MA'='MELAA'
'MD'='Europe exc. U.K.'
'MG'='MELAA'
'MH'='Polynesia (excludes Hawaii)'
'MK'='Europe exc. U.K.'
'MM'='Mainland South-East Asia'
'MN'='North-East Asia'
'MO'='North-East Asia'
'MR'='MELAA'
'MT'='Europe exc. U.K.'
'MU'='Missing'
'MV'='Southern Asia'
'MW'='MELAA'
'MX'='MELAA'
'MY'='Maritime South-East Asia'
'MZ'='MELAA'
'NA'='MELAA'
'NC'='MELAA'
'NG'='MELAA'
'NL'='Europe exc. U.K.'
'NO'='Europe exc. U.K.'
'NP'='Southern Asia'
'NR'='Missing'
'NZ'='New Zealand'
'OM'='MELAA'
'PA'='MELAA'
'PC'='Polynesia (excludes Hawaii)'
'PE'='MELAA'
'PF'='Polynesia (excludes Hawaii)'
'PG'='Missing'
'PH'='Maritime South-East Asia'
'PK'='Southern Asia'
'PL'='Europe exc. U.K.'
'PS'='MELAA'
'PT'='Europe exc. U.K.'
'PX'='MELAA'
'PY'='MELAA'
'QA'='MELAA'
'RK'='Missing'
'RO'='Europe exc. U.K.'
'RS'='Europe exc. U.K.'
'RU'='Europe exc. U.K.'
'RW'='MELAA'
'SA'='MELAA'
'SB'='Missing'
'SC'='MELAA'
'SD'='MELAA'
'SE'='Europe exc. U.K.'
'SG'='Maritime South-East Asia'
'SI'='Europe exc. U.K.'
'SK'='Europe exc. U.K.'
'SL'='MELAA'
'SM'='Europe exc. U.K.'
'SO'='MELAA'
'SP'='Missing'
'SS'='Missing'
'SV'='MELAA'
'SY'='MELAA'
'SZ'='MELAA'
'TG'='MELAA'
'TH'='Mainland South-East Asia'
'TJ'='Central Asia'
'TL'='MELAA'
'TM'='Central Asia'
'TN'='MELAA'
'TP'='Missing'
'TO'='Polynesia (excludes Hawaii)'
'TR'='MELAA'
'TT'='MELAA'
'TV'='Polynesia (excludes Hawaii)'
'TW'='North-East Asia'
'TZ'='MELAA'
'UA'='Europe exc. U.K.'
'UG'='MELAA'
'UK'='Europe exc. U.K.'
'UM'='Northern America'
'UN'='Missing'
'US'='Northern America'
'UY'='MELAA'
'UZ'='Central Asia'
'VC'='MELAA'
'VE'='MELAA'
'VN'='Mainland South-East Asia'
'VU'='Missing'
'WS'='Polynesia (excludes Hawaii)'
'YE'='MELAA'
'YU'='Europe exc. U.K.'
'ZA'='MELAA'
'ZM'='MELAA'
'ZR'='MELAA'
'ZW'='MELAA';
run;


proc format;
	value bendur
		.,low-0='aNone  '
		  0<-.10='b1-10%'
		.10<-.25='c11-25%'
		.25<-.50='d26-50%'
		.50<-.75='e50-75%'
		.75<-high='f75+%';
run;

proc format;
	value $lv8idd
		"40","41","46", "60", "96", "98"      ="1"
		"36"-"37","43"                        ="2"
		"30"-"35"                       ="3"
		"20","25","21"                  ="4"
		"12"-"14"                       ="6"
		"11"                            ="7"
		"01","10"                       ="8"
		"90", "97", "99"                ="9"
		Other                           ="0";
run;

proc format;
	value $lv8id
		"40","41","46", "60", "96", "98"      ="Level 1-3 certificates"
		"36"-"37","43"                        ="Level 4 Certificates"
		"30"-"35"                       ="Certificates and Diploma Level 5-7"
		"20","21","25"                       ="Bachelor degrees"
		"12"-"14"                       ="Honours, postgrad dipl"
		"11"                            ="Masters degrees"
		"01","10"                       ="Doctoral degrees"
		"90", "97", "99"                ="Non formal programmes"
		Other                           ="Error";
run;


proc format;
	value $subsector
		"1","3"="Universities"
		"2"="Polytechnics"
		"4"="Wananga"
		"5","6"="Private Training Establishments";
run;

proc format;
value $field
'01'='Natural and Physical Sciences'
'02'='Information Technology'
'03'='Engineering and Related Technologies'
'04'='Agriculture and Building'
'05'='Agriculture, Environmental and Related Studies'
'06'='Health'
'07'='Education'
'08'='Management and Commerce'
'09'='Society and Culture'
'10'='Creative Arts'
'11'='Food, Hospitality and PErsonal Services'
'12'='Mixed Field Programme';
run;


proc format ;
VALUE $bengp_pre2013wr                  /* Jane suggest to add the old format */
    '020','320' = "Invalid's Benefit"
    '030','330' = "Widow's Benefit"
    '040','044','340','344'
                = "Orphan's and Unsupported Child's benefits"
    '050','350','180','181'
    = "New Zealand Superannuation and Veteran's and Transitional Retirement Benefit"
    '115','604','605','610'
                = "Unemployment Benefit and Unemployment Benefit Hardship"
    '125','608' = "Unemployment Benefit (in Training) and Unemployment Benefit Hardship (in Training)"
    '313','613','365','665','366','666','367','667'
                = "Domestic Purposes related benefits"
    '600','601' = "Sickness Benefit and Sickness Benefit Hardship"
    '602','603' = "Job Search Allowance and Independant Youth Benefit"
    '607'       = "Unemployment Benefit Student Hardship"
    '609','611' = "Emergency Benefit"
    '839','275' = "Non Beneficiary"
    'YP ','YPP' = "Youth Payment and Young Parent Payment"
        ' '     = "No Benefit"
 ;

value $bennewgp 

'020'=	"Invalid's Benefit"
'320'=	"Invalid's Benefit"

'330'=	"Widow's Benefit"
'030'=	"Widow's Benefit"

'040'=	"Orphan's and Unsupported Child's benefits"
'044'=	"Orphan's and Unsupported Child's benefits"
'340'=	"Orphan's and Unsupported Child's benefits"
'344'=	"Orphan's and Unsupported Child's benefits"

'050'=	"New Zealand Superannuation and Veteran's and Transitional Retirement Benefit"
'180'=	"New Zealand Superannuation and Veteran's and Transitional Retirement Benefit"
'181'=	"New Zealand Superannuation and Veteran's and Transitional Retirement Benefit"
'350'=	"New Zealand Superannuation and Veteran's and Transitional Retirement Benefit"

'115'=	"Unemployment Benefit and Unemployment Benefit Hardship"
'604'=	"Unemployment Benefit and Unemployment Benefit Hardship"
'605'=	"Unemployment Benefit and Unemployment Benefit Hardship"
'610'=	"Unemployment Benefit and Unemployment Benefit Hardship"
'607'=	"Unemployment Benefit Student Hardship"
'608'=	"Unemployment Benefit (in Training) and Unemployment Benefit Hardship (in Training)"
'125'=	"Unemployment Benefit (in Training) and Unemployment Benefit Hardship (in Training)"


'313'=  "Domestic Purposes related benefits"
'365'=	"Sole Parent Support "					/* renamed */
'366'=	"Domestic Purposes related benefits"
'367'=	"Domestic Purposes related benefits"
'613'=	"Domestic Purposes related benefits"
'665'=	"Domestic Purposes related benefits"
'666'=	"Domestic Purposes related benefits"
'667'=	"Domestic Purposes related benefits"

'600'=	"Sickness Benefit and Sickness Benefit Hardship"
'601'=	"Sickness Benefit and Sickness Benefit Hardship"

'602'=	"Job Search Allowance and Independant Youth Benefit"
'603'=	"Job Search Allowance and Independant Youth Benefit"

'611'=	"Emergency Benefit"

'315'=	"Family Capitalisation"
'461'=	"Unknown"
'000'=	"No Benefit"
'839'=	"Non Beneficiary"

/* new codes */
'370'=  "Supported Living Payment related"
'675'=  "Job Seeker related"
'500'=  "Work Bonus"
;
run  ;

proc format;
value $ADDSERV
'YP'	='Youth Payment'
'YPP'	='Young Parent Payment'
'CARE'	='Carers'
'FTJS1'	='Job seeker Work Ready '
'FTJS2'	='Job seeker Work Ready Hardship'
'FTJS3'	='Job seeker Work Ready Training'
'FTJS4'	='Job seeker Work Ready Training Hardship'
'MED1'	='Job seeker Health Condition and Disability'
'MED2'	='Job seeker Health Condition and Disability Hardship'
'PSMED'	='Health Condition and Disability'
''		='.';
run;

Proc format;
value HA 
42='National Diploma at level 4 or above'
41='National Certificate at level 4 or above'
40='New Zealand Scholarship award'
39='NCEA level 3 (with Excellence)'
38='NCEA level 3 (with Merit)'
37='NCEA level 3 (with Achieve)'
36='NCEA level 3 (No Endorsement)'
35='Other NQF Qualification at level 3'
29='NCEA level 2 (with Excellence)'
28='NCEA level 2 (with Merit)'
27='NCEA level 2 (with Achieve)'
26='NCEA level 2 (No Endorsement)'
25='Other NQF Qualification at level 2'
19='NCEA level 1 (with Excellence)'
18='NCEA level 1 (with Merit)'
17='NCEA level 1 (with Achievement)'
16='NCEA level 1 (No Endorsement)'
15='Other NQF Qualification at level 1';

value HA_grouped
42,41,40='Level 4 Qualification or above'
39,38,37,36='NCEA level 3 Qualification'
35='Other NQF Qualification at level 3'
29,28,27,26='NCEA level 2 Qualification'
25='Other NQF Qualification at level 2'
19,18,17,16='NCEA level 1 Qualification'
15='Other NQF Qualification at level 1';

Value ha_grp
42,41,40,39,38,37,36,35='NCEA level 3 or above'
29,28,27,26,25='Level 2 Qualification'
19,18,17,16,15='NCEA level 1 Qualification'
0,.='No Formal NCEA Attainment';

run;


* Grouping interventions into groader categores
5	ESOL (English for Speakers of Other Languages)- should not appear for our domestic students
6	Alternative Education- for kids that dont fit into mainstream schools
7	Suspensions-suspections
8	Stand downs-suspentions
9	Non Enrolment Truancy Services-TRUANCY
10	Early Leaving exemptions-other
11	Homeschooling-Homeschooling
12	Section 9-enrolment over legal age
13	Mapihi Pounamu-similar to Boarding burs
14	Boarding bursaries
16	Reading Recovery
17	Off Sites Centres (teen parenting, altern education centres )
24	Special Education Service-SPECIAL EDU ( Physical and mental disabilities)
25	ORRS					-SPECIAL EDU ( Physical and mental disabilities)
26	Over 19 at Secondary	
27	High Health				-SPECIAL EDU ( Physical and mental disabilities)
28	Special School			-SPECIAL EDU ( Physical and mental disabilities)
29	Over 14 at Primary-		-LEARNING DIFF
30	SE Other
31	Resource Teachers: Literacy
32	Truancy (Unjustified Absence)-TRUANCY
36	ENROL- no records
33 	Hearing and eye test conduced at school HELATH
34  Gateway
35  Trade academies and other
37  Interim response fund
******************************************************;

proc format;
	value interv_grp
		5='ESOL'
		6,17='AlTED'
		7='SUSP'
		8='STAND'
		9,32='TRUA'
		12,26,29,24,25,27,28,30='SEDU'
		10='EARLEX'
		11='HOMESCH'
		13,14='BOARD'
		16,31='OTHINT'
		33='HEALTH'
		34,35='SECTER'
		37='IRF';
run;


*******************************************************;
* Education level code:
O 	 Unknown (converted from FM)
A 	 No formal school quals or < 3yrs
B 	 less than 3 SC passes or equivalent
C 	 3 or more SC passes or equivalent
D 	 Sixth form cert, UE or equivalent
E 	 Scholarship, Bursary, HSC 
F 	 Other School Quals
G 	 Post Secodary Quals
H 	 Degree or Professional Quals
I  	 (NCEA1) :1-79 credits
J 	 (NCEA) Level 1:>=80 credits
K 	 (NCEA) Level 2:>=80 credits
L 	 (NCEA) Level 3:>=80 credits
M 	 (NCEA) Level 4: >=72 credits
N 	 Sixth Form Certificate Transitional
P 	 Unknown - auto-enrolled;

proc format;
	value $BDD_edu
		'A', 'B', 'I' = 0
		'C', 'J' = 1
		'D', 'F', 'K' = 2
		'E', 'L','M','G'= 3
		'H' = 4
		other = .
	;
run;
