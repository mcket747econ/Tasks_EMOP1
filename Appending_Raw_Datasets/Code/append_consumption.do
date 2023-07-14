/*******************************************************************************
						Mali EMOP Data Cleaning
						
					This is part of Master_clean_emop.do 

	Purpose: This do-file appends EMOP consumption data sets and 
			 cleans the appended data set.
	Output: Clean dataset. 
		The output is stored in Dropbox/Mining-Mali/data/incCheckProj
	Author: Sakina
	Last date update: August, 2021
*******************************************************************************/
if c(username) == "mcket" {
	global dropbox "C:\Users\mcket\Dropbox"
	global  git "C:\Users\mcket\OneDrive\Documents\Mali Project 2022\mali_climate_conflict_matt_fork\EMOP\Codes\cleaning\Stata"
	}

// 	global user 1 // Matt
// if ${user} == 1 {
// 	global project "C:/Users/mcket/Dropbox/Mining-Mali/Matt's Work/Tasks_EMOP/Appending_Raw_Datasets"
// 	global input "${project}/Input"
// 	global output "${project}/Output"
// }


	global user 1 // Matt
if ${user} == 1 {
	global project "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
	global tasks "${project}/Appending_Raw_Datasets"
	global input "${tasks}/Input"
	global output "${tasks}/Output"
}


//
// global project "$dropbox\Mining-Mali"
// global rawData "$project\data\raw\EMOP"
// global modData "$project\data\ModifiedData\matts_modified_output"
// global output  "$project/data/cleaned/EMOP/matt_output"
// global do_files"$git/emop_clean_master"

*** Load data 
use "$input/EMOP_Depenses_passage_2011_2017.dta", clear

*** Append 2018 and 2019 data
 append using "$input/EMOP_Depenses_2018.dta"  "$input/EMOP_Depenses_2019.dta"

*** ID variables

* HH ID
// rename idmenage hhid
// label var hhid "Household ID"
//
// * Year
// label var year "Year"
//
// * Cluster
// rename Grappe cluster
// label var cluster "Survey cluster"

* Geographical info
// rename Region, lower
// label var region "Region"
// label define REGION 8 "Kidal", modify
// rename Cercle circle 
// label var circle "Cirlce" // What's this?
// rename Arrond borough
// label var borough "Borough"
// rename Commune town
// label var town "Town"
rename Milieu urban
recode urban (2=0)
label def MILIEU 0 "Rural", modify
label var urban "Urban or rural"

egen tot_exp = rowtotal(consom_total_s1 consom_total_s2 consom_total_s3 consom_total_s4), missing 
label var tot_exp "Total HH expenditure (CFA)"

*keep hhid year cluster region circle borough town urban tot_exp taille_men

* For 2014 and 2016 ciricle, borough, and town are completely missing
// preserve
// use "$input/emop_indivitus_2011_2019.dta", clear
// keep iid hhid year region circle borough town
// collapse (firstnm)  region circle borough town, by(hhid year)
// keep if year == 2011 | year == 2013 | year == 2014 | year == 2016
// tempfile geo_vars
// save `geo_vars'
// restore
//
// merge 1:1 hhid year using `geo_vars', update replace
// drop _merge
//
// * For R users
// gen region_id = region
// gen circle_id = circle 
// gen borough_id =  borough
// gen town_id = town

* Check duplicates
// duplicates report hhid cluster region circle borough town year // None
// rename hhid idmenage

save "$output/emop_despenses_2011_2019_cl.dta", replace
save "${project}\Consumption_By_Season_Cleaning\Input\emop_despenses_2011_2019_cl.dta", replace
