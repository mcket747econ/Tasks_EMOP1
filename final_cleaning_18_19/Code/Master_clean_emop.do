/*******************************************************************************
			Clening EMOP Data
			
Purpose: Master do-file to rule all do-files

Author: Sakina
	
Notes: 
	
*******************************************************************************/

***************
* Housekeeping
***************

clear
/*
if c(username) == "sakina" {
	global dropbox "C:\Users\sakina\Dropbox\Projects"
	global git     "C:\Users\sakina\Documents\Git"
	}
	*/
	
if c(username) == "mcket" {
	global project "C:\Users\mcket\OneDrive\Documents\Tasks_EMOP"
// 	global  git    "C:\Users\mcket\OneDrive\Documents\Mali Project 2022\mali_climate_conflict_matt_fork\EMOP\Codes\cleaning\Stata"
	}

// global project "$dropbox\Mining-Mali"
global task "${project}\final__cleaning_18_19"
global input "${task}\Input"
global output "${task}\Output"
global do_files "${task}\Code"

* Sections (Change any of these to 1 to run the relevant code.)
global ind_data 1
global hh_data 0
global append 0

***********************
* Individual lvel data
***********************

if $ind_data {
	
	/* 
		The 2018 and 2019 data sets have a different naming convention 
		from earlier EMOP data sets.
		
		These do files align the names so they can be appended to the pre-2018 data.
		
		Note that the ouput data sets contains only relevant variables.
	*/
	
	do ${do_files}\clean_2018_indiv.do
		* Output: project/output/emop_indivitus_2019.dta

	do "${do_files}\clean_2019_indiv.do"
		* Output:  project/output/emop_indivitus_2019.dta
		
}


****************************
* HH-level expenditure data
****************************
if $hh_data {
	
	/*
		The cleaning do-file for the hh-level consumption data 
		before 2018 is:
		
		Dropbox\Mining-Mali\do-file\Consumption_by_season_Cleaning_EMOP_NT.do
		
		Ask Jeremy to grant you access to this Dropbox folder.
		
		I didn't want to move this do-file to the emop_clean repo 
		because it's not a file that I created, and is unclear who is using it for what.
	*/
	
	*** Clean hh-level consumption data after 2018
	do "$do_files\clean_HH_consumption_post2018.do"
		* Output 1: project/output/EMOP_Depenses_2018.dta
		* Output 2: project/output/EMOP_Depenses_2019.dta
}


****************************************
* Append data sets from different years

*In the task based code structure, this section is not needed. Handled By The Appending Code and , final_2011_2017_code
****************************************


// if $append {
//	
// 	*** Append all individual-level data and clean
// 	do "$do_files/append_individual.do"
// 		* Output 1: Dropbox\Mining-Mali\data\cleaned\EMOP\incCheckProj\emop_indivitus_2011_2019.dta
// 		* Output 2: Dropbox\Mining-Mali\data\cleaned\EMOP\incCheckProj\emop_indivitus_2011_2019_cl.dta
//	
// 	*** Append all household-level consumption data and clean
// 	do "$do_files/append_consumption.do"
// 		* Output : Dropbox\Mining-Mali\data\cleaned\EMOP\incCheckProj\emop_despenses_2011_2019_cl.dta
//	
// }






