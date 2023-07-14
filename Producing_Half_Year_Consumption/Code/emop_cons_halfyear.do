* Calculating Total and Per Capita Consumption from Seasonal data
* Osas Olurotimi / Mizuhiro Suzuki
*2022: Matt McKetty

* Settings ----------------------
clear
clear matrix
clear matrix
set matsize 800
set more off
set varabbrev off

// global user 1 // Matt
// if ${user} == 1 {
// 	global project "/Users/mcket/Dropbox/Mining-Mali/"
// 	global data "${project}/data/cleaned/EMOP/matt_output"
// }

global user 1 // Matt
if ${user} == 1 {
	global Tasks "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
	global project "${Tasks}/Producing_Half_Year_Consumption"
	global input "${project}/Input"
	global output "${project}/Output"
}





* open data
*use "${data}/EMOP_All_firstcleaned_passage_2011_2017withdist & limited regions07102019.dta", clear
use "${input}/EMOP_All_firstcleaned_passage_2011_2019_f.dta", clear


*rename hhid idmenage 

* merge GPS data
merge m:1 commune_name using "${input}/commune_gps_f.dta"
keep if _merge==3
drop _merge
	 
* generate unique household id
egen hhid = group(idmenage year)

* Calculate quarterly consumption ---------------------
* calculate quarterly consumption of locally produced grains: millet, sorghum, and maize
forvalues q = 1/4 {
  egen millet_cons_s`q' = rowtotal(mil_achat_s`q' mil_autocons_s`q' mil_cadeau_s`q')
  egen sorghum_cons_s`q' = rowtotal(sorgho_achat_s`q' sorgho_autocons_s`q' sorgho_cadeau_s`q')
  egen maize_cons_s`q' = rowtotal(mais_achat_s`q' mais_autocons_s`q' mais_cadeau_s`q')
  egen meat_purchase_s`q'= rowtotal(viande_achat_s`q')
  egen meat_auto_s`q' = rowtotal(viande_autocons_s`q') 
  egen meat_gift_s`q' = rowtotal(viande_cadeau_s`q')
  egen meat_cons_s`q' = rowtotal(viande_achat_s`q'  viande_autocons_s`q' viande_cadeau_s`q')
} 

forvalues q = 1/4 {
  egen rice_cons_s`q' = rowtotal(riz_achat_s`q' riz_autocons_s`q' riz_cadeau_s`q')
  egen rice_purchase_s`q' = rowtotal(riz_achat_s`q')
  egen rice_gift_s`q' = rowtotal(riz_cadeau_s`q')
  egen rice_auto_s`q' = rowtotal(riz_autocons_s`q')
  egen leisure_cons_s`q' = rowtotal(loisirs_achat_s`q')
  egen educ_cons_s`q' = rowtotal(education_achat_s`q') 
  egen grain_cons_s`q' = rowtotal(millet_cons_s`q' sorghum_cons_s`q' maize_cons_s`q' rice_cons_s`q')
  egen grain_purchase_s`q' = rowtotal(mil_achat_s`q' sorgho_achat_s`q' mais_achat_s`q' riz_achat_s`q')
} 

forvalues q = 1/4 { 
  egen grain_auto_s`q' = rowtotal(mil_autocons_s`q' sorgho_autocons_s`q' mais_autocons_s`q' rice_auto_s`q')
  egen grain_gift_s`q' = rowtotal(mil_cadeau_s`q' sorgho_cadeau_s`q' mais_cadeau_s`q' rice_gift_s`q') 
  egen oignon_cons_s`q' = rowtotal(oignon_autocons_s`q' oignon_cadeau_s`q' oignon_achat_s`q')
  egen tuber_cons_s`q' = rowtotal(tubercule_autocons_s`q' tubercule_cadeau_s`q' tubercule_achat_s`q')
  egen bean_cons_s`q' = rowtotal(haricot_autocons_s`q' haricot_cadeau_s`q' haricot_achat_s`q')
  egen bread_cons_s`q' = rowtotal(pain_autocons_s`q' pain_cadeau_s`q' pain_achat_s`q')
  egen milk_cons_s`q' = rowtotal(lait_autocons_s`q' lait_cadeau_s`q' lait_achat_s`q')
  
  
 }
 //Add some new categories. 
 
 forvalues q = 1/4 {  
 	egen vegetable_cons_s`q' = rowtotal(tuber_cons_s`q' bean_cons_s`q' oignon_cons_s`q')
	egen sugar_cons_s`q' = rowtotal(sucre_achat_s`q' sucre_cadeau_s`q' sucre_autocons_s`q')
	egen fish_cons_s`q' = rowtotal(poisson_achat_s`q' poisson_autocons_s`q' poisson_cadeau_s`q')
	egen oil_cons_s`q' = rowtotal(huile_achat_s`q' huile_autocons_s`q' huile_cadeau_s`q')
	egen tea_cons_s`q' = rowtotal(the_achat_s`q' the_autocons_s`q' the_cadeau_s`q')
	egen peanut_cons_s`q' = rowtotal(arachide_achat_s`q' arachide_autocons_s`q' arachide_cadeau_s`q')
	egen maggi_cons_s`q' = rowtotal(maggi_achat_s`q' maggi_autocons_s`q' maggi_cadeau_s`q')
	egen butter_cons_s`q' = rowtotal(beurreKarite_achat_s`q' beurreKarite_autocons_s`q' beurreKarite_cadeau_s`q')
// 	egen alcool_cons = sum(alcool_achat_s`q')

// 	egen misc_cons_s`q' = rowtotal()
	
	//egen 
	//egen other_cons_s`q' = rowtotal() 

 }
 
 
//   forvalues q = 1/4 {  
//  	egen vegetable_cons_s`q' = rowtotal(tuber_cons_s`q' bean_cons_s`q' oignon_cons_s`q')
// 	egen sugar_cons_s`q' = rowtotal(sucre_achat_s`q' sucre_cadeau_s`q' sucre_autocons_s`q')
// 	egen fish_cons_s`q' = rowtotal(poisson_achat_s`q' poisson_autocons_s`q' poisson_cadeau_s`q')
// 	egen oil_cons_s`q' = rowtotal(huile_achat_s`q' huile_autocons_s`q' huile_cadeau_s`q')
// 	egen tea_cons_s`q' = rowtotal(tea_achat_s`q' tea_autocons_s`q' tea_cadeau_s`q')
// 	egen peanut_cons_s`q' = rowtotal(arachide_achat_s`q' arachide_autocons_s`q' arachide_cadeau_s`q')
// 	egen maggi_cons_s`q' = rowtotal(maggi_achat_s`q' maggi_autocons_s`q' maggi_cadeau_cadeau_s`q')
// 	egen butter_cons_s`q' = rowtotal(beurreKarite_achat_s`q' beurreKarite_autocons_s`q' beurreKarite_cadeau_s`q')
// 	egen alcool_cons = sum(alcool_achat_s`q')
//
//  }
// 

// foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {
//
// 	gen tp`x'=`x' if fonction==8
// 	bys idmenage: egen communication_`x'=mean(tp`x')
// 	label var communication_`x' "communication expenditure by season" 
// 	drop tp`x'	
// }

// drop alcool_achat

// gen alcool_achat = alcool_achat_s1 + alcool_achat_s2 + alcool_achat_s3 + alcool_achat_s4
//  forvalues q = 1/4 {  
//   egen alcool_achat = rowtotal(alcool_achat_s`q')
//   egen cloth_achat = rowtotal(cloth_achat_s`q')
//   egen logement_achat = rowtotal(logement_achat_s`q')
//   egen meuble_achat = rowtotal(meuble_achat_s`q')
//   egen sante_achat = rowtotal(sante_achat_s`q')
//   egen transport_achat = rowtotal(transport_achat_s`q')
//   egen communication_achat = rowtotal(communication_achat_s`q')
//   egen loisirs_achat = rowtotal(loisirs_achat_s`q') 
//  }

forvalues q = 1/4{
	rename communication_achat_s`q' comm_achat_s`q'
}  
  

* calculate per-capital consumption by dividing by household size
forvalues q = 1/4 {
	foreach var in consom_total consom_food consom_nonfood ///
		grain_cons grain_purchase grain_auto grain_gift meat_cons meat_purchase meat_auto ///
		meat_gift rice_cons rice_purchase rice_auto rice_gift leisure_cons educ_cons ///
		milk_cons fish_cons vegetable_cons bread_cons ///
        oil_cons tea_cons butter_cons peanut_cons maggi_cons sugar_cons ///
		alcool_achat sante_achat cloth_achat logement_achat ///
		meuble_achat transport_achat comm_achat ///
		restaurant_achat bien_autre_achat{
		gen percap_`var'_s`q' = `var'_s`q' / size_hh
		}			
  }



* Calculate annual consumption ---------------------
**# Bookmark #1
foreach var in consom_total consom_food consom_nonfood ///
		grain_cons grain_purchase grain_auto grain_gift meat_cons meat_purchase meat_auto ///
		meat_gift rice_cons rice_purchase rice_auto rice_gift leisure_cons educ_cons ///
		milk_cons fish_cons vegetable_cons bread_cons ///
        oil_cons tea_cons butter_cons peanut_cons maggi_cons sugar_cons ///
		alcool_achat sante_achat cloth_achat logement_achat ///
		meuble_achat transport_achat comm_achat ///
		restaurant_achat bien_autre_achat{
  egen annual_`var' = rowtotal(`var'_s?)
  egen percap_annual_`var' = rowtotal(percap_`var'_s?)
  }

* save data of annual consumption
save "${output}/Emop_annual_cons.dta", replace

* Calculate "1st and 2nd" and "3rd and 4th" quarter consumption ---------------------
* aggregate consumption

/*
foreach var in consom_total consom_food consom_nonfood ///
  grain_cons grain_purchase grain_auto grain_gift meat_cons meat_purchase meat_auto ///
  meat_gift rice_cons rice_purchase rice_auto rice_gift leisure_cons educ_cons {
  egen `var'_q12 = rowtotal(`var'_s1 `var'_s2)
  egen percap_`var'_q12 = rowtotal(percap_`var'_s1 percap_`var'_s2)
  egen `var'_q34 = rowtotal(`var'_s3 `var'_s4)
  egen percap_`var'_q34 = rowtotal(percap_`var'_s3 percap_`var'_s4)
}*/
	foreach var in consom_total consom_food consom_nonfood ///
		grain_cons grain_purchase grain_auto grain_gift meat_cons meat_purchase meat_auto ///
		meat_gift rice_cons rice_purchase rice_auto rice_gift leisure_cons educ_cons ///
		milk_cons fish_cons vegetable_cons bread_cons ///
        oil_cons tea_cons butter_cons peanut_cons maggi_cons sugar_cons ///
		alcool_achat sante_achat cloth_achat logement_achat ///
		meuble_achat transport_achat comm_achat ///
		restaurant_achat bien_autre_achat{
		gen `var'_h1 = (`var'_s1 + `var'_s2)/2
		gen percap_`var'_h1 = (percap_`var'_s1 + percap_`var'_s2)/2
		gen `var'_h2 = (`var'_s3 + `var'_s4)/2
		gen percap_`var'_h2 = (percap_`var'_s3 + percap_`var'_s4)/2
	}








* save data of half-year aggregated consumption
save "${output}/emop_half_year_aggregate_cons.dta", replace

*Reshape to half-year data
reshape long consom_total_h consom_food_h consom_nonfood_h ///
  grain_cons_h grain_purchase_h grain_auto_h grain_gift_h ///
  meat_cons_h meat_purchase_h meat_auto_h meat_gift_h ///
  rice_cons_h rice_purchase_h rice_auto_h rice_gift_h ///
  milk_cons_h fish_cons_h vegetable_cons_h bread_cons_h ///
  oil_cons_h tea_cons_h butter_cons_h peanut_cons_h maggi_cons_h sugar_cons_h ///
  leisure_cons_h educ_cons_h alcool_achat_h sante_achat_h cloth_achat_h logement_achat_h ///
  meuble_achat_h transport_achat_h comm_achat_h ///
  restaurant_achat_h bien_autre_achat_h /// 
  percap_consom_total_h percap_consom_food_h percap_consom_nonfood_h ///
  percap_grain_cons_h percap_grain_purchase_h percap_grain_auto_h percap_grain_gift_h ///
  percap_meat_cons_h percap_meat_purchase_h percap_meat_auto_h percap_meat_gift_h ///
  percap_rice_cons_h percap_rice_purchase_h percap_rice_auto_h percap_rice_gift_h ///
  percap_educ_cons_h percap_leisure_cons_h percap_alcool_achat_h percap_sante_achat_h ///
  percap_cloth_achat_h percap_logement_achat_h percap_meuble_achat_h percap_transport_achat_h ///
  percap_comm_achat_h percap_restaurant_achat_h percap_bien_autre_achat_h, ///
  i(hhid) j(half_year)
rename ( ///
  consom_total_h consom_food_h consom_nonfood_h ///
  grain_cons_h grain_purchase_h grain_auto_h grain_gift_h ///
  meat_cons_h meat_purchase_h meat_auto_h meat_gift_h ///
  rice_cons_h rice_purchase_h rice_auto_h rice_gift_h ///
  milk_cons_h fish_cons_h vegetable_cons_h bread_cons_h ///
  oil_cons_h tea_cons_h butter_cons_h peanut_cons_h maggi_cons_h sugar_cons_h ///
  leisure_cons_h educ_cons_h alcool_achat_h sante_achat_h cloth_achat_h logement_achat_h ///
  meuble_achat_h transport_achat_h comm_achat_h ///
  restaurant_achat_h bien_autre_achat_h /// 
  percap_consom_total_h percap_consom_food_h percap_consom_nonfood_h ///
  percap_grain_cons_h percap_grain_purchase_h percap_grain_auto_h percap_grain_gift_h ///
  percap_meat_cons_h percap_meat_purchase_h percap_meat_auto_h percap_meat_gift_h ///
  percap_rice_cons_h percap_rice_purchase_h percap_rice_auto_h percap_rice_gift_h ///
  percap_educ_cons_h percap_leisure_cons_h percap_alcool_achat_h percap_sante_achat_h ///
  percap_cloth_achat_h percap_logement_achat_h percap_meuble_achat_h percap_transport_achat_h ///
  percap_comm_achat_h percap_restaurant_achat_h percap_bien_autre_achat_h ///
  ) ///
  ( ///
  consom_total consom_food consom_nonfood ///
  grain_cons grain_purchase grain_auto grain_gift ///
  meat_cons meat_purchase meat_auto meat_gift ///
  rice_cons rice_purchase rice_auto rice_gift ///
  milk_cons fish_cons vegetable_cons bread_cons ///
  oil_cons tea_cons butter_cons peanut_cons maggi_cons sugar_cons ///
  leisure_cons educ_cons alcool_achat sante_achat cloth_achat logement_achat ///
  meuble_achat transport_achat comm_achat ///
  restaurant_achat bien_autre_achat ///
  percap_consom_total percap_consom_food percap_consom_nonfood ///
  percap_grain_cons percap_grain_purchase percap_grain_auto percap_grain_gift ///
  percap_meat_cons percap_meat_purchase percap_meat_auto percap_meat_gift ///
  percap_rice_cons percap_rice_purchase percap_rice_auto percap_rice_gift ///
  percap_educ_cons percap_leisure_cons percap_alcool_achat percap_sante_achat ///
  percap_cloth_achat percap_logement_achat percap_meuble_achat percap_transport_achat ///
  percap_comm_achat percap_restaurant_achat percap_bien_autre_achat ///
  ) ///
  


bysort half_year: sum ///
  consom_total consom_food consom_nonfood ///
  grain_cons grain_purchase grain_auto grain_gift ///
  meat_cons meat_purchase meat_auto meat_gift  ///
  rice_cons rice_purchase rice_auto rice_gift ///
  leisure_cons educ_cons alcool_achat ///
  milk_cons fish_cons vegetable_cons bread_cons ///
  oil_cons tea_cons butter_cons peanut_cons maggi_cons sugar_cons ///
  sante_achat cloth_achat logement_achat ///
  meuble_achat transport_achat comm_achat ///
  restaurant_achat bien_autre_achat
* drop quarterly variables that will not be used
drop *_s1 *_s2 *_s3 *_s4 
*drop *_h1 *_h2
* generate half_year-year variable
egen half_year_year = group(half_year year)

*Generate Ramadan Variables
generate ramadan_1=.
replace ramadan_1=1 if year == 2016|2017|2018|2019
replace ramadan_1=0 if year < 2016

generate ramadan_2=.
replace ramadan_2=1 if year == 2011|2013|2014|2015
replace ramadan_2=0 if year > 2015

// save "${data}/emop_halfyear_cons_2011_2019.dta", replace





save "${output}/emop_halfyear_cons_for_regressions.dta", replace
save "${Tasks}/Final_GCVI_Regressions/Input/emop_halfyear_cons_for_regressions", replace
save "${Tasks}/Final_GNDVI_Regressions/Input/emop_halfyear_cons_for_regressions", replace
save "${Tasks}/Final_NDVI_Regressions/Input/emop_halfyear_cons_for_regressions", replace
save "${Tasks}/Final_EVI_Regressions/Input/emop_halfyear_cons_for_regressions", replace








































/*


* Reshape to quarterly data --------------------
reshape long consom_total_s consom_food_s consom_nonfood_s ///
  grain_cons_s grain_purchase_s grain_auto_s grain_gift_s ///
  meat_cons_s meat_purchase_s meat_auto_s meat_gift_s ///
  rice_cons_s rice_purchase_s rice_auto_s rice_gift_s ///
  leisure_cons_s educ_cons_s /// 
  percap_consom_total_s percap_consom_food_s percap_consom_nonfood_s ///
  percap_grain_cons_s percap_grain_purchase_s percap_grain_auto_s percap_grain_gift_s ///
  percap_meat_cons_s percap_meat_purchase_s percap_meat_auto_s percap_meat_gift_s ///
  percap_rice_cons_s percap_rice_purchase_s percap_rice_auto_s percap_rice_gift_s ///
  percap_educ_cons_s percap_leisure_cons_s, ///
  i(hhid) j(quarter)
rename ( ///
  consom_total_s consom_food_s consom_nonfood_s ///
  grain_cons_s grain_purchase_s grain_auto_s grain_gift_s ///
  meat_cons_s meat_purchase_s meat_auto_s meat_gift_s ///
  rice_cons_s rice_purchase_s rice_auto_s rice_gift_s ///
  leisure_cons_s educ_cons_s ///
  percap_consom_total_s percap_consom_food_s percap_consom_nonfood_s ///
  percap_grain_cons_s percap_grain_purchase_s percap_grain_auto_s percap_grain_gift_s ///
  percap_meat_cons_s percap_meat_purchase_s percap_meat_auto_s percap_meat_gift_s ///
  percap_rice_cons_s percap_rice_purchase_s percap_rice_auto_s percap_rice_gift_s ///
  percap_educ_cons_s percap_leisure_cons_s ///
  ) ///
  ( ///
  consom_total consom_food consom_nonfood ///
  grain_cons grain_purchase grain_auto grain_gift ///
  meat_cons meat_purchase meat_auto meat_gift ///
  rice_cons rice_purchase rice_auto rice_gift ///
  leisure_cons educ_cons ///
  percap_consom_total percap_consom_food percap_consom_nonfood ///
  percap_grain_cons percap_grain_purchase percap_grain_auto percap_grain_gift ///
  percap_meat_cons percap_meat_purchase percap_meat_auto percap_meat_gift ///
  percap_rice_cons percap_rice_purchase percap_rice_auto percap_rice_gift ///
  percap_educ_cons percap_leisure_cons ///
  )

bysort quarter: sum ///
  consom_total consom_food consom_nonfood ///
  grain_cons grain_purchase grain_auto grain_gift ///
  meat_cons meat_purchase meat_auto ///
  meat_gift rice_cons rice_purchase rice_auto rice_gift ///
  leisure_cons educ_cons 
* drop quarterly variables that will not be used
drop *_s1 *_s2 *_s3 *_s4 

* generate quarter-year variable
egen quarter_year = group(quarter year)

save "${data}/emop_quarterly_cons_2011_2019.dta", replace

generate halfyear=.
replace halfyear= 1 if quarter == 1 | quarter ==2 
replace halfyear= 2 if quarter == 3 | quarter ==4 

*/