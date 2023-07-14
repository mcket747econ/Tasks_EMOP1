/*******************************************************************************
Cleaning the 2018 and 2019 HH level consumption EMOP data

This is part of Master_clean_emop.do 

Notes: This code is largely based on Nouhoum's code in 
Dropbox/Projects/Mining-Mali/do-file/Consumption_by_season_Cleaning_EMOP_NT.do
*******************************************************************************/

/*
if c(username) == "mcket" {
	global dropbox "C:\Users\mcket\Dropbox"
	global  git "C:\Users\mcket\OneDrive\Documents\Mali Project 2022\mali_climate_conflict_matt_fork\EMOP\Codes\cleaning\Stata"
	}

global project "$dropbox\Mining-Mali"
global rawData "$project\data\raw\EMOP"
global modData "$project\data\ModifiedData\matts_modified_output"zs
global output  "$project/data/cleaned/EMOP/matt_output"
global do_files"$git/emop_clean_master"


*/


global user 1 // Matt
if ${user} == 1 {
		global project "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
	global task "${project}/Clean_HH_Consumption_Post2018"
	global input "${project}/Input"
	global output "${project}/Output"
}



foreach year in 2018 2019 {
	
	if `year' == 2018 {
		
		use "$rawData/2018/From_Masa/DEPENSES_TOUS_PASSAGES_2018_2019_tabulation_Utilisateur.dta", clear
		* ID vars
		gen idmenage = GRAPPE*1000 + MENAGE // HH ID
		gen year = 2018
		rename GRAPPE MENAGE REGION milieu depenses ///
			PASSAGE codeprod fonction taille_men, proper
		rename dep_mod2 Dep_mod2
		rename (FREQ MODACQ) (Freqachat Modeacq)
	
		* Bring in Cercle Arrond Commune
		preserve
		use  "C:/Users/mcket/Dropbox/Mining-Mali/data/ModifiedData/EMOP_2018_Individus.dta", clear
		duplicates drop idmenage, force
		keep idmenage Cercle Arrond Commune 
		tempfile geo_2018
		save `geo_2018'
		restore
		rename Taille_Men taille_men
		merge m:1 idmenage using `geo_2018', nogen
	}
	
	else if `year' == 2019 {
		
		import spss using "$rawData/2019/Edition 8 2019-2020/annuel_vf/annuel_vf/Bases de tabulation/DEPENSES_TOUS_PASSAGES_2019-2020_Tabulation_vf.sav", clear
	
	
		* ID vars
		gen idmenage = GRAPPE*1000 + MENAGE // HH ID
		gen year = 2019
		rename GRAPPE MENAGE region MILIEU depenses ///
		 	PASSAGE codeprod fonction, proper
		rename dep_mod2 Dep_mod2
		rename (FREQ MODACQ) (Freqachat Modeacq)

		keep Grappe Menage Codeprod Freqachat Modeacq Passage ///
			Depenses Region Milieu Fonction Dep_mod2 idmenage year taille_men
		
		* Bring in Cercle Arrond Commune
		preserve
		use "C:\Users\mcket\Dropbox\Mining-Mali\data\ModifiedData\EMOP_2019_Individus", clear
		duplicates drop idmenage, force
		keep idmenage Cercle Arrond Commune
		tempfile geo_2019
		save `geo_2019'
		restore
		
		merge m:1 idmenage using `geo_2019', nogen
		
	}

	
	*** Converting to seasonal values (each season= 13 weeks, 3 months or year/4)

		replace Depenses=Depenses*13 if Freqachat==1
		replace Depenses=Depenses/4 if Freqachat==3
		replace Depenses=Depenses*3 if Freqachat==4
		replace Depenses=0 if Depenses==.
			
	*** Trimesterly consumption by source 
	foreach j in 1 2 3 { // 1 = purchase 2 = Auto comsumption 3 = gift
		
		foreach i in 1 2 3 4 {
			
			if `j' == 1 {
				local varname "achat"
				local varlab "purchase"
			}
			else if `j' == 2 {
				local varname "autocons"
				local varlab "auto-consumption"
			}
			else if `j' == 3 {
				local varname "cadeau"
				local varlab "gift"
			}
			 
			bys idmenage Codeprod: egen tp`i' = mean(Depenses) ///
				if Modeacq == `j' & Passage == `i'
			bys idmenage Codeprod: egen `varname'_s`i' = mean(tp`i') 	
			replace `varname'_s`i' = 0 if `varname'_s`i' == .
			label var `varname'_s`i' "Trimesterly consumption (`varlab')"

		}
		drop tp1 tp2 tp3 tp4
		}

	duplicates drop idmenage Codeprod, force


	*** Seasonal consumption by food items by source

	local varlabs_eng "Rice Millet Sorghum Maiz Beans Meat Fish Sugar Tea SheaButter CookingOil CubeMaggi Onion Bread Peanut Tuber Milk"  
	local varnames "riz mil sorgho mais haricot viande poisson sucre the beurreKarite huile maggi oignon pain arachide tubercule lait"
	local itemIDs "101 102 104 107 120 114 110 103 106 108 111 118 117 112 113 116 115"

	local n: word count `itemIDs'	
	forvalues i = 1/`n' {
		
		di `i'
		
		local varlab: word `i' of `varlabs_eng'
		local varname: word `i' of `varnames'
		local itemID: word `i' of `itemIDs'
		
		di "itemID: `itemID'"
		di "varlab: `varlab'"
		di "varname: `varname'"
		
		* Purchase
		foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

			gen tp`x' = `x' if Codeprod == `itemID'
			bys idmenage: egen `varname'_`x' = mean(tp`x')
			label var `varname'_`x' "`varlab' purchased by season"
			drop tp`x'	
		}

		* Auto-comsumption
		foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

			gen tp`x' = `x' if Codeprod == `itemID'
			bys idmenage: egen `varname'_`x' = mean(tp`x')
			label var `varname'_`x' "`varlab' auto consumed by season"
			drop tp`x'	
		}
		
		* Gift
		foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

			gen tp`x' = `x' if Codeprod == `itemID'
			bys idmenage: egen `varname'_`x' = mean(tp`x')
			label var `varname'_`x' "`varlab' received as gift by season"
			drop tp`x'	
		}
	}


	*** Other expenditure -- these are only purchased (no gift or auto consumed)

	local varnames "alcool cloth logement meuble sante transport communication loisirs education restaurant bien_autre"
	local itemIDs "2 3 4 5 6 7 8 9 10 11 12"

	local n: word count `itemIDs'
	forvalues i = 1/`n' {
		
		local varname: word `i' of `varnames'
		local itemID: word `i' of `itemIDs'
		
		if `i' == 1 {
			local varlab "alcool tobacco and narcotic"	
		}
		else if `i' == 2 {
			local varlab "apparel and shoes item"	
		}
		else if `i' == 3 {
			local varlab "housing and bills"
		}
		else if `i' == 4 {
			local varlab "furniture, household expenditures and maintenance"
		}
		else if `i' == 5 {
			local varlab "health"
		}
		else if `i' == 6 {
			local varlab "transportation"
		}
		else if `i' == 7 {
			local varlab "communication"
		}
		else if `i' == 8 {
			local varlab "leisure and culture"
		}
		else if `i' == 9 {
			local varlab "education"
		}
		else if `i' == 10 {
			local varlab "restaurant and hotel"
		}
		else if `i' == 11 {
			local varlab "miscellaneous goods and services"
		}
		
		foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

			gen tp`x' = `x' if Fonction == `itemID'
			bys idmenage: egen `varname'_`x' = mean(tp`x')
			label var `varname'_`x' "expenditue on `varlab' by season"
			drop tp`x'	
		}
	}

	* Total expenditures by season 

	foreach x in s1 s2 s3 s4 {

		gen consom_total_`x'=riz_achat_`x'+ riz_autocons_`x' + riz_cadeau_`x' + ///
			mil_achat_`x' + mil_cadeau_`x' + mil_autocons_`x' + ///
			sorgho_achat_`x' + sorgho_autocons_`x' + sorgho_cadeau_`x' + ///
			mais_achat_`x' + mais_autocons_`x' + mais_cadeau_`x' + ///
			haricot_achat_`x' + haricot_autocons_`x' + haricot_cadeau_`x' + ///
			viande_achat_`x' + viande_autocons_`x' + viande_cadeau_`x'+ ///
			poisson_achat_`x' + poisson_autocons_`x' + poisson_cadeau_`x' + ///
			sucre_achat_`x' + sucre_autocons_`x' + sucre_cadeau_`x' + ///
			the_achat_`x' + the_autocons_`x' + the_cadeau_`x' + beurreKarite_achat_`x' + ///
			beurreKarite_autocons_`x' + beurreKarite_cadeau_`x' + ///
			huile_achat_`x' + huile_autocons_`x' + huile_cadeau_`x' + ///
			maggi_achat_`x' + maggi_autocons_`x' + maggi_cadeau_`x' + ///
			oignon_achat_`x' + oignon_autocons_`x' + oignon_cadeau_`x' + ///
			pain_achat_`x' + pain_autocons_`x' + pain_cadeau_`x' + ///
			arachide_achat_`x' + arachide_autocons_`x' + arachide_cadeau_`x' + ///
			tubercule_achat_`x' + tubercule_autocons_`x' + tubercule_cadeau_`x' + ///
			lait_achat_`x' + lait_autocons_`x' + lait_cadeau_`x' + alcool_achat_`x' + ///
			cloth_achat_`x' + logement_achat_`x' + meuble_achat_`x' + sante_achat_`x' + ///
			transport_achat_`x' +communication_achat_`x'+ loisirs_achat_`x' + ///
			education_achat_`x' + restaurant_achat_`x' + bien_autre_achat_`x'
		label var consom_total_`x' "Household total consumption in CFA for season `x'"
	}

	* Food expenditure by season
	foreach x in s1 s2 s3 s4 {

		gen consom_food_`x'=riz_achat_`x'+ riz_autocons_`x' + riz_cadeau_`x' + ///
			mil_achat_`x' + mil_cadeau_`x' + mil_autocons_`x' + ///
			sorgho_achat_`x' + sorgho_autocons_`x' + sorgho_cadeau_`x' + ///
			mais_achat_`x' + mais_autocons_`x' + mais_cadeau_`x' + ///
			haricot_achat_`x' + haricot_autocons_`x' + haricot_cadeau_`x' + ///
			viande_achat_`x' + viande_autocons_`x' + viande_cadeau_`x'+ ///
			poisson_achat_`x' + poisson_autocons_`x' + poisson_cadeau_`x' + ///
			sucre_achat_`x' + sucre_autocons_`x' + sucre_cadeau_`x' + ///
			the_achat_`x' + the_autocons_`x' + the_cadeau_`x' + beurreKarite_achat_`x' + ///
			beurreKarite_autocons_`x' + beurreKarite_cadeau_`x' + ///
			huile_achat_`x' + huile_autocons_`x' + huile_cadeau_`x' + ///
			maggi_achat_`x' + maggi_autocons_`x' + maggi_cadeau_`x' + ///
			oignon_achat_`x' + oignon_autocons_`x' + oignon_cadeau_`x' + ///
			pain_achat_`x' + pain_autocons_`x' + pain_cadeau_`x' + ///
			arachide_achat_`x' + arachide_autocons_`x' + arachide_cadeau_`x' + ///
			tubercule_achat_`x' + tubercule_autocons_`x' + tubercule_cadeau_`x' + ///
			lait_achat_`x' + lait_autocons_`x' + lait_cadeau_`x' 
		label var consom_food_`x' "Household total food consumption in CFA for season `x'"
	}


	* Non food expenditure by season
	foreach x in s1 s2 s3 s4 {

		gen consom_nonfood_`x'= alcool_achat_`x' + cloth_achat_`x' + ///
			logement_achat_`x' + meuble_achat_`x' + sante_achat_`x' + ///
			transport_achat_`x' +communication_achat_`x'+ loisirs_achat_`x' + ///
			education_achat_`x' +restaurant_achat_`x' +bien_autre_achat_`x'
		label var consom_nonfood_`x' "Household non-food expenditure in CFA for season `x'"
	}

	drop Codeprod Fonction Freqachat Modeacq Depenses Dep_mod2

	duplicates drop idmenage, force

	save "$modData/EMOP_Depenses_`year'", replace

}


