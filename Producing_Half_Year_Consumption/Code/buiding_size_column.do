if c(username) == "mcket" {
	global dropbox "C:\Users\mcket\Dropbox"
	global  git "C:\Users\mcket\OneDrive\Documents\Mali Project 2022\mali_climate_conflict_matt_fork\EMOP\Codes\cleaning\Stata"
	}

global project "$dropbox\Mining-Mali"
global rawData "$project\data\raw\EMOP"
global modData "$project\data\ModifiedData\matts_modified_output"
global output  "$project/data/cleaned/EMOP/matt_output"
global do_files"$git/emop_clean_master"



use cleaned/EMOP/matt_output/EMOP_All_firstcleaned_passage_2011_2019_f

foreach year in 2011 2013 2014 2015 2016 2017 2018 2019 {
	if `year' inlist(2011,2013,2014,2015,2016,2017) {
		size_hh1 = size_hh
	}
	else if `year' inlist(2018,2019) {
		size_hh1 = taille_men
	}
}
