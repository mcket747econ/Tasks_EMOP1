/*******************************************************************************
						Mali EMOP Data Cleaning
						
					This is part of Master_clean_emop.do 
		   
	Purpose: This do-file appends EMOP individual-level data sets and 
			 cleans the appended data set.
	Output: Clean dataset. 
		The output is stored in Dropbox/Mining-Mali/data/incCheckProj
	Author: Sakina
	Last date update: August, 2021	
*******************************************************************************/

* Section switches
global append_ind 1 // Append all individual level data sets from 2011 - 2017
global clean_ind  1 // Clean relevant variables and only keep those in the individus data

***** Append all individual level data sets from 2011 - 2017
if $append_ind {

* 2019
use "$modData/EMOP_2019_Individus.dta", clear
gen year = 2019
tempfile append_2019
save `append_2019'
	
* 2018
use "$modData/EMOP_2018_Individus.dta", clear
gen year = 2018
tempfile append_2018
save `append_2018'

* 2017
use "$rawData/2017/EMOP_2017_Individus.dta", clear
gen year = 2017

preserve // Bring in the household weights
	use "$rawData/2017/EMOP_Menage.dta", clear
	rename W1 hhweight
	keep idmenage hhweight
	tempfile weight_2017
	save `weight_2017'
restore 
merge m:1 idmenage using `weight_2017', nogen 

tempfile append_2017
save `append_2017' 

* 2016
use "$rawData/2016/EMOP_2016_Individus.dta", clear
gen year = 2016

preserve // Bring in the household weights
	use "$rawData/2016/EMOP_Menage.dta", clear
	rename W1 hhweight
	keep idmenage hhweight
	tempfile weight_2016
	save `weight_2016'
restore 
merge m:1 idmenage using `weight_2016', nogen

tempfile append_2016
save `append_2016' 


* 2015
use "$rawData/2015/EMOP_2015_Individus.dta", clear
gen year = 2015

preserve // Bring in the household weights
	use "$rawData/2015/EMOP_Menage.dta", clear
	rename W1 hhweight
	keep idmenage hhweight
	tempfile weight_2015
	save `weight_2015'
restore 
merge m:1 idmenage using `weight_2015', nogen

tempfile append_2015
save `append_2015' 

* 2014
use "$rawData/2014/EMOP_2014_Individus.dta", clear
gen year = 2014
rename cercle arrond commune, proper

preserve // Bring in the household weights
	use "$rawData/2014/EMOP_Menage.dta", clear
	rename W1 hhweight
	keep idmenage hhweight
	tempfile weight_2014
	save `weight_2014'
	* This is there are 5045 unique HH weights but for other years there are only like 1100 when there are over 6000 households.
restore 
merge m:1 idmenage using `weight_2014', nogen

tempfile append_2014
save `append_2014' 

* 2013
use "$rawData/2013/EMOP_2013_Individus.dta", clear
gen year = 2013
rename region cercle arrond commune milieu, proper

preserve // Bring in the household weights
	use "$rawData/2013/EMOP_Menage.dta", clear
	rename W1 hhweight
	keep idmenage hhweight
	tempfile weight_2013
	save `weight_2013'
restore 
merge m:1 idmenage using `weight_2013', nogen

tempfile append_2013
save `append_2013' 

* 2011
use "$rawData/2011/EMOP_2011_Individus.dta", clear
gen year = 2011
drop REGION1 // This is exactly the same as region. Dropping it to prevent confusion

preserve // Bring in the household weights
	use "$rawData/2011/EMOP_Menage.dta", clear
	rename W1 hhweight
	keep idmenage hhweight
	tempfile weight_2011
	save `weight_2011'
restore 
merge m:1 idmenage using `weight_2011', nogen

tempfile append_2011
save `append_2011' 

* Append all 
/* Notes:
1. MR6A isn't coded consistently. For now, I'm force-appending. 
This is a question about what type of professional education the interviewee has
had. If important, I'll deal with it later. 

2. TP7 in 2014 isn't coded. For now, I'm just appending this variable forcibly.
This is a question about they type of occupation the interviewee's farther had 
when s/he was 15. It may not be so important for us. 

3. AS1B1 in 2015 is not coded because I think the choices weren't coded well in the questionnaire. For now, I'm just appending this variable forcibly.
This variable isn't too important because it's interviwee's ranking of other jobs.  */


use `append_2011', clear 
append using `append_2013', force
append using  `append_2014', force
append using  `append_2015', force
append using `append_2016', force
append using `append_2017', force
append using `append_2018'
append using `append_2019'

* Fillin missing geo variables
preserve
	use "$project/Intermediate Cleaning/Intermediate cleaning data files/EMOP_GPS.dta", replace
	keep idmenage grappe menage region cercle commune arrond year
	rename grappe menage region cercle commune arrond, proper
	tempfile geo_vars
	save `geo_vars'
restore

merge m:1 idmenage Region Cercle Commune year using `geo_vars', update replace
drop _merge

save "$output/incCheckProj/emop_indivitus_2011_2019.dta", replace

}

***** Clean relevant variables and only keep those in the individus data
if $clean_ind {

use "$output/incCheckProj/emop_indivitus_2011_2019.dta", clear

*** Define common value lables
label def yes_no 0 "No" 1 "Yes"

*** ID variables

* Individual ID
rename Idindividu iid
label var iid "Individual ID"

* HH ID
rename idmenage hhid
label var hhid "Household ID"

* Year
label var year "Year"

* Cluster
rename Grappe cluster
label var cluster "Survey cluster"

* Geographical info
rename Region, lower
label var region "Region"
label define REGION 8 "Kidal", modify
rename Cercle circle 
label var circle "Cirlce" // What's this?
rename Arrond borough
label var borough "Borough"
rename Commune town
label var town "Town"
rename Milieu urban
recode urban (2=0)
label var urban "Urban or rural"

rename Strate area
label var area "Area of residence"


*** Individual chracteristics

* Residence status (This indicates if the interviewee is an actual HH member or a visitor.)
rename M02 resid
label var resid "Residence status at the household"
label def M02 1 "Present" 2 "Absent" 3 "Visiting", modify

* Sex
rename M03 female
label var female "Sex"
recode female (1 = 0) (2 = 1)
label def M03 0 "Male" 1 "Female", replace
label val female M03

* Age
rename M04 age
label var age "Age"

* Relationship to the HHH
rename M05 rhhh
label var rhhh "Relationship to HHH"
label def M05 1 "HHH" 2 "Spouse" 3 "Child of HHH or spouse" 4 "Parent of HHH or spouse" 5 "Other parent of HHH or spouse" 6 "Unrelated" 7 "Domestic", modify // ?? What is domestic?

* Marital status
rename M06 marst
label var marst "Marital status"
label def M06 1 "Monogamous" 2 "Polygamous" 3 "Common-law" 4 "Never married" 5 "Divorced/separated" 6 "Widowed" 7 "Under age 12", modify

* Nationality
rename M07A natl 
label var natl "Nationality"
label def M07A 1 "Malian" 2 "UEMOA countries" 3 "ECOWAS countries other then UEMOA" 4 "Other", modify

* Other nationality (binary)
rename M07B natl_sec_b
label var natl_sec_b "Other nationality (binary)"
recode natl_sec_b (2=0)
label val natl_sec_b yes_no

* Other nationality
rename M07C natl_sec 
label def M07C 9 "Other African country" 11 "Other European country" 12 "USA" 13 "Other American country" 14 "Saudi Arabia" 15 "Other Asian country" 17 "Oceanian country", modify

* Religion
rename M08 relgn
label def M08 1 "Muslim" 2 "Catholic" 3 "Protestant" 4 "Animist" 5 "Other" 6 "No religion", modify   

* In which language can you read and write fluently?
rename M16A lit_fr // French
rename M16B lit_ab // Arab
rename M16C lit_eg // English
rename M16D lit_nl // National languages 
rename M16E lit_ot // Other 
local abb "fr ab eg nl ot"
local full "French Arabic English National_languages Other"
forval i = 1/5 {

	local vnam : word `i' of `abb'
	local vlab : word `i' of `full'
	
	label var lit_`vnam' "Literacy (`vlab')"
	recode lit_`vnam' (2=0)
	label val lit_`vnam' yes_no
}

* Have you ever attended school?
rename M17 schl
label var schl "Ever attended school"
recode schl (2=0)
label val schl yes_no 

* What is the highest level of education completed?
rename M18 edu_comp
label var edu_comp "Highest level of education completed"
label def M18 0 "Kindergarten" 1 "1st grade" 2 "2nd grade" 3 "3rd grafde" 4 "4th grade" 5 "5th grade" 6 "6th grade" 7 "7th grade" 8 "8th grade" 9 "9th grade" 10 "Secondary" 11 "Superior" 12 "Any", modify // ?? What's mean by any/aucune?

* What type of secondary education 
rename M18A sed_type
label var sed_type "Type of secondary education"
label def M18A 1 "General" 2 "Technical and Professional", modify

* Highest diploma obtained
rename M19 diplm
label var diplm "Highest diploma obtained"
label def M19 1 "None" 8 "Bachelor/Master/Master 1" 10 "Doctorate/PhD", modify

* Are you still going to school?
rename M20 in_schl
label var in_schl "Still going to school"
recode in_schl (2=0)
label val in_schl yes_no

 
*** Main occupation 

* Occupation
rename AP1 job_m 
label var job_m "Main occupation"
notes job_m: "AP1. What is the name of the trade, profession, position, task that you"

* Sector
rename AP2 job_m_sec
label var job_m_sec "Sector of main occupation"
notes job_m_sec: "AP2. What is the main activity of the company in which you have ex"

* Position
rename AP3 job_m_pos
label var job_m_pos "Position in main occupation"
notes job_m_pos: "AP3. What is your socio-professional category?"

* Type of institution the interviewee works for
rename AP4 job_m_typ 
label var job_m_typ "Type of institution (main occupation)"
notes job_m_typ: "AP4. The company in which you carry out your main job is:"

* Size of institution the interviwee works for 
rename AP5 job_m_sz
label var job_m_sz "Size of institution (main occupation)"
notes job_m_sz: "AP5. How many people in total work in this company?"

* Tax regime of institution the interviwee works for
rename AP6A job_m_tx
label var job_m_tx "Tax regime of institution (main occupation)"
notes job_m_tx: "AP6a. What tax regime is this establishment subject to?"

* Locality of the main occupation (?? I'm not sure what this means.)
rename AP7 job_m_lc
label var job_m_lc "?? of main occupation"
notes job_m_lc: "AP7. In what type of premises did you exercise your main job?"

* Number of years worked at the main occupation
rename AP8A1 job_m_yr1
label var job_m_yr1 "Number of years at the main occupation"
notes job_m_yr1: "AP8a1. What year have you been in your current job?"

* Number of years worked at this institution
rename AP8A2 job_m_yr2
label var job_m_yr2 "Number of years at the current institution (main occupation)"
notes job_m_yr1: "AP8a2. What year have you been working in this company?"

* Have the interviwee been promoted at this institution
rename AP8A3A job_m_pm
label var job_m_pm "Promotion at the current institution (main occupation)"
notes job_m_pm: "AP8a3a. In this business, have you had a promotion?"

* Number of hours worked per week
rename AP11 job_m_hr
label var job_m_hr "Number of hours worked per week (main occupation)" 
notes job_m_hr: "AP11. How many hours did you spend on your main job during"

* Form of payment
rename AP12 job_m_py
label var job_m_py "Form of payment (main occupation)"
notes job_m_py: "AP12. In what form are you paid, or do you get your income, in your"

* Last month's earnings from the main job
rename AP13A1 mpsalary 
label var mpsalary "Last month's earnings from the main occupation"
notes mpsalary: "AP13a1. In your main job, how much have you earned in the last month (o"

* Benefits
egen job_m_bn = rowtotal(AP16A11 AP16A21 AP16B11 AP16B21 AP16B31 AP16B71 AP16B81), missing
label var job_m_bn "Total benefts in CFA (main occupation)"
notes job_m_bn: "Sum of familay allowances, cash benefits (accomodation, electricity, transport, telephone), end of year bonuses, INPS and other premiums, profit-sharing, special medical services, in-kind beneftis (accomodation, electricity, transport, telephone)"

* Farmer dummy
gen farmer = .
replace farmer = 0 if job_m != 60001 & job_m !=.
replace farmer = 1 if job_m == 60001 
label var farmer "Primary occupation farmer"

* Herder dummy
gen herder = . 
replace herder = 0 if job_m != 60009 & job_m !=.
replace herder = 1 if job_m == 60009
label var herder "Primary occupation herder"

* Herder dummy
gen fisher = . 
replace fisher = 0 if job_m !=  60010 | job_m !=  60011 & job_m !=.
replace fisher = 1 if job_m ==  60010 | job_m ==  60011
label var fisher "Primary occupation fisher"


* Self-employed dummy
gen semplyd =.
replace semplyd = 0 if job_m_pos != 7 & job_m_pos !=.
replace semplyd = 1 if job_m_pos == 7
label var semplyd "Primary occupation self-employed"

* Employee dummy 
gen emplyee =.
replace emplyee = 0 if job_m_pos > 5 & job_m_pos !=.
replace emplyee = 0 if job_m_pos <= 5
label var emplyee "Primary occupation employee"

* Work in public sector dummy
gen public =. 
replace public = 0 if job_m_typ > 2 & job_m_typ !=.
replace public = 1 if job_m_typ == 1 | job_m_typ == 2
label var public "Primary occupation in public sector"

* Work in private sector dummy 
gen private =.
replace private = 0 if job_m_typ != 3 & job_m_typ !=.
replace private = 1 if job_m_typ == 3
label var private "Primary occupation in private sector"

*** Secondary occupation

* Jobs other than main occupation
rename AS1A sec_jobs
label var sec_jobs "Jobs other than main occupation"
notes sec_jobs: "AS1a. In addition to your main job, did you have any other jobs, such as q"

* Number of secondary jobs
rename AS1C num_sec_jobs
label var num_sec_jobs "Number of secondary jobs"
notes num_sec_jobs: "AS1c. Number of secondary jobs"

* Occupation 
rename AS2 job_s
label var job_s "Secondary occupation"
notes job_s: "AS2. What is the name of the trade, profession, position, task of the emp"

* No sector info for secondary occupations

* Position
rename AS4 job_s_pos
label var job_s_pos "Position in main occupation"
notes job_s_pos: "AS4. What is your socio-professional category?"

* Type of institution the interviewee works for
rename AS5 job_s_typ 
label var job_s_typ "Type of institution (secondary occupation)"
notes job_s_typ: "AS5. The company in which you do your secondary job is:"

* Size of institution the interviwee works for 
rename AS6 job_s_sz
label var job_s_sz "Size of institution (secondary occupation)"
notes job_s_sz: "AS6. How many people in total work in this establishment (including"

* Tax regime of institution the interviwee works for
rename AS7A job_s_tx
label var job_s_tx "Tax regime of institution (secondary occupation)"
notes job_s_tx: "AS7a. What tax regime is this establishment subject to?"

* Locality of the secondary occupation (?? I'm not sure what this means.)
rename AS8 job_s_lc
label var job_s_lc "?? of secondary occupation"
notes job_s_lc: "AS8. In what type of premises did you exercise your secondary job"

* Number of hours worked per week
rename AS9 job_s_hr
label var job_s_hr "Number of hours worked per week (secondary occupation)" 
notes job_m_hr: "AS9. How many hours do you usually spend on all your jobs (secomdai"

* Last month's earnings from the main job
rename AS11BA mssalary 
label var mssalary "Last month's earnings from the secondary occupation"
notes mssalary: "AS11ba. In your secondary job, how much did you earn last month ..."

*** Other sources of income

/* Notes:
There are no data recorded on other sources of income in 2018
*/

* Work pension
rename RHA1B osi_wpns
label var osi_wpns "Work pension (FCFA)"

* Other pensions 
rename RHA2B osi_opns
label var osi_opns "Other pensions (FCFA)"

* Annuitites and property income
rename RHA3B osi_api
label var osi_api "Annuities and property income (FCFA)"

* Financial incomes, investment
rename RHA4B osi_fin
label var osi_fin "Financial incomes and investments (FCFA)"

* Scholarship
rename RHA5B osi_sch
label var osi_sch "Scholarships (FCFA)"

* International remittances
rename RHA6C osi_irem
label var osi_irem "Int'l remittances (CFA)"
notes osi_irem: "RHA6. Sends regular money from a parent who has emigrated from Mali"

* International remittances
rename RHA7C osi_lrem
label var osi_lrem "Local remittances (CFA)"
notes osi_lrem: "RHA7. Sends regular money from a parent living in Mali to another local"

* Other regular income
rename RHA8B osi_oth
label var osi_oth "Other regular income (CFA)"

* International donations
rename RHA9B osi_idn
label var osi_idn "International donations (CFA)"

* Domestic donations
rename RHA10B osi_ddn
label var osi_ddn "Domestic donations (CFA)"

* Unemployment support
rename C4A uem_supp
label var uem_supp "C4a. How much do you collect per month (during unemployment)? (CFA)"

label var hhweight "Household weight"

* Recode missing values in income variables
local inc_vars "mpsalary mssalary osi_wpns osi_opns osi_api osi_fin osi_sch osi_irem osi_lrem osi_oth osi_idn osi_ddn uem_supp"

foreach var of local inc_vars {
	replace `var' = . if `var' == 9999999
}

* Annual earnings
gen mslry_ann = mpsalary*12
label var mslry_ann "Annual earnings from the main occupation"

gen sslry_ann = mssalary*12
label var sslry_ann "Annual earning from the secondary occupation"

* If a HH reported to have moved because of insecurity in the north in 2013
gen if_idp_2013 = 0
replace if_idp_2013 = 1 if year == 2013 & M14 == 5

* Fill in missing obs in borough
bys region circle town: carryforward borough, replace

* For R users
gen region_id = region
gen circle_id = circle 
gen borough_id =  borough
gen town_id = town

* Organize the dataset
keep iid hhid year cluster region region_id circle circle_id borough borough_id town town_id hhweight urban area resid /*hh_size*/ female age rhhh marst natl natl_sec_b natl_sec relgn lit_* schl edu_comp sed_type diplm in_schl farmer herder fisher semplyd emplyee public private job_*  sec_jobs num_sec_jobs `inc_vars' mslry_ann sslry_ann if_idp_2013

order iid hhid year cluster region region_id circle circle_id borough borough_id town town_id urban area resid /*hh_size*/ female age rhhh marst natl natl_sec_b natl_sec relgn lit_* schl edu_comp sed_type diplm in_schl farmer herder fisher semplyd emplyee public private job_*  sec_jobs num_sec_jobs `inc_vars' mslry_ann sslry_ann if_idp_2013

recast byte circle, force

* Check duplicates
duplicates tag iid hhid year region borough town, gen(dup)
drop if dup == 1 & age == 1 // May not be the best thing. There is only dup ob.

save "$output/incCheckProj/emop_indivitus_2011_2019_cl.dta", replace

}

/*
foreach yr in 2011 2013 2014 2015 2016 2017 2018 2019 {
	di "`yr'"
	sum hh_size if year == `yr'
	di " "
}

/*
foreach yr in 2011 2013 2014 2015 2016 2017 2018 2019 {
	di "`yr'"
	sum hhweight if year == `yr'
	unique hhweight if year == `yr'
	di " "
}


