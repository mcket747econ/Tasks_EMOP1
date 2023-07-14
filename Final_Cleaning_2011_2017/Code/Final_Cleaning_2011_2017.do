	
gl PATH "C:/Users/mcket/Dropbox/Mining-Mali/data"
cd $PATH
* Settings ----------------------

clear
clear matrix
clear mata
set matsize 800
set more off

global user 1 // Matt
if ${user} == 1 {
	global Tasks "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
	global project "${Tasks}/Final_Cleaning_2011_2017"
	global input "${project}/Input"
	global output "${project}/Output"
}




use ${input}/EMOP_Depenses_2011, clear

 append using ${input}/EMOP_Depenses_2013 ${input}/EMOP_Depenses_2014 ///
			${input}/EMOP_Depenses_2015 ${input}/EMOP_Depenses_2016 ///
// 				 ModifiedData/EMOP_Depenses_2017
drop DEPTRI13

* Key consumption variables

* Total expenditures by season 

	foreach x in s1 s2 s3 s4 {

	gen consom_total_`x'=riz_achat_`x'+ riz_autocons_`x' + riz_cadeau_`x' + mil_achat_`x' + mil_cadeau_`x' + mil_autocons_`x' + ///
	sorgho_achat_`x' + sorgho_autocons_`x' + sorgho_cadeau_`x' + mais_achat_`x' + mais_autocons_`x' + mais_cadeau_`x' + ///
	haricot_achat_`x' + haricot_autocons_`x' + haricot_cadeau_`x' + viande_achat_`x' + viande_autocons_`x' + viande_cadeau_`x'+ ///
	poisson_achat_`x' + poisson_autocons_`x' + poisson_cadeau_`x' + sucre_achat_`x' + sucre_autocons_`x' + sucre_cadeau_`x' + ///
	the_achat_`x' + the_autocons_`x' + the_cadeau_`x' + beurreKarite_achat_`x' + beurreKarite_autocons_`x' + beurreKarite_cadeau_`x' + ///
	huile_achat_`x' + huile_autocons_`x' + huile_cadeau_`x' + maggi_achat_`x' + maggi_autocons_`x' + maggi_cadeau_`x' + ///
	oignon_achat_`x' + oignon_autocons_`x' + oignon_cadeau_`x' + pain_achat_`x' + pain_autocons_`x' + pain_cadeau_`x' + ///
	arachide_achat_`x' + arachide_autocons_`x' + arachide_cadeau_`x' + tubercule_achat_`x' + tubercule_autocons_`x' + tubercule_cadeau_`x' + ///
	lait_achat_`x' + lait_autocons_`x' + lait_cadeau_`x'  + alcool_achat_`x' + cloth_achat_`x' + logement_achat_`x' + meuble_achat_`x' + sante_achat_`x' + ///
	transport_achat_`x' +communication_achat_`x'+ loisirs_achat_`x' +education_achat_`x' +restaurant_achat_`x' +bien_autre_achat_`x'
	label var consom_total_`x' "household total consumption in CFA for season `x'"
}


* Food expenditure

foreach x in s1 s2 s3 s4 {

gen consom_food_`x'=riz_achat_`x'+ riz_autocons_`x' + riz_cadeau_`x' + mil_achat_`x' + mil_cadeau_`x' + mil_autocons_`x' + ///
	sorgho_achat_`x' + sorgho_autocons_`x' + sorgho_cadeau_`x' + mais_achat_`x' + mais_autocons_`x' + mais_cadeau_`x' + ///
	haricot_achat_`x' + haricot_autocons_`x' + haricot_cadeau_`x' + viande_achat_`x' + viande_autocons_`x' + viande_cadeau_`x'+ ///
	poisson_achat_`x' + poisson_autocons_`x' + poisson_cadeau_`x' + sucre_achat_`x' + sucre_autocons_`x' + sucre_cadeau_`x' + ///
	the_achat_`x' + the_autocons_`x' + the_cadeau_`x' + beurreKarite_achat_`x' + beurreKarite_autocons_`x' + beurreKarite_cadeau_`x' + ///
	huile_achat_`x' + huile_autocons_`x' + huile_cadeau_`x' + maggi_achat_`x' + maggi_autocons_`x' + maggi_cadeau_`x' + ///
	oignon_achat_`x' + oignon_autocons_`x' + oignon_cadeau_`x' + pain_achat_`x' + pain_autocons_`x' + pain_cadeau_`x' + ///
	arachide_achat_`x' + arachide_autocons_`x' + arachide_cadeau_`x' + tubercule_achat_`x' + tubercule_autocons_`x' + tubercule_cadeau_`x' + ///
	lait_achat_`x' + lait_autocons_`x' + lait_cadeau_`x' 
	label var consom_food_`x' "household total food consumption in CFA for season `x'"
}


* Non food expenditure

foreach x in s1 s2 s3 s4 {

	gen consom_nonfood_`x'= alcool_achat_`x' + cloth_achat_`x' + logement_achat_`x' + meuble_achat_`x' + sante_achat_`x' + ///
	transport_achat_`x' +communication_achat_`x'+ loisirs_achat_`x' +education_achat_`x' +restaurant_achat_`x' +bien_autre_achat_`x'
	label var consom_nonfood_`x' "Household non-food expenditure in CFA for season `x'"
}

foreach x in idmenage Grappe Menage Region Cercle Arrond Commune Milieu Passage {

	rename `x', lower
}

drop passage

order idmenage grappe menage region cercle arrond commune milieu ///
se idse W1 W2 consom_total_* consom_food_* consom_nonfood_*

save  ${output}/EMOP_Depenses_passage_2011_2017, replace
save  ${Tasks}/Appending_Raw_Datasets/Input/EMOP_Depenses_passage_2011_2017, replace