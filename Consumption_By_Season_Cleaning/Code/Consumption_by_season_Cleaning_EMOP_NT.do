
* Mali
* EMOP Data 2011 - 2017
* Nouhoum Traore


* Settings

clear
clear matrix
clear mata
set matsize 800
set more off



* Set Directory 

* Nouhoum Traore

	*gl PATH "/Users/nouhoumtraore/Dropbox/EMOP_DATA/"
	*cd $PATH
	
*Matt McKetty
    
	
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
	global project "${Tasks}/Consumption_By_Season_Cleaning"
	global input "${project}/Input"
	global output "${project}/Output"
}



********************************************************************************
********************************************************************************
*** Food Consumption
* Here we aim to estimate household food consumption for the 4 seasons of the year 
* Since different items were bought in different frequency (weekly, trimesterly, annually)
* we will convert all consumption to trimesterly consumption assuming that one year=52 weeks
* and a trimester=13 weeks (52/4).

* Households were visited 4 times to collect data on household expenses. 
* Consumption values include purchases, gifts, and autoconsumption. Gift
* is only asked in first, third, and fourth passage, while purchages and autoconsumption
* are asked in all passages (1, 2, 3, and 4). 


/*
foreach z in 2011 2013 2014 2015 2016 2017 2018 2019 {

	use $PATH/raw/EMOP/`z'/EMOP_Depenses_`z', clear
	
	*rename Idmenage idmenage

* Converting to seasonal values (each season= 13 weeks, 3 months or year/4)

		replace Depenses=Depenses*13 if Freqachat==1
		replace Depenses=Depenses/4 if Freqachat==3
		replace Depenses=Depenses*3 if Freqachat==4
		replace Depenses=0 if Depenses==.
		
** Trimesterly consumption by source 

* Purchase 

foreach i in 1 2 3 4 {
	
	bys idmenage Codeprod: egen tp`i'=mean(Depenses) if Modeacq==1 & Passage==`i'
	bys idmenage Codeprod: egen achat_s`i'=mean(tp`i') 	
	replace achat_s`i'=0 if achat_s`i'==.
}

drop tp1 tp2 tp3 tp4

* auto consumption 

foreach i in 1 2 3 4 {
	
	bys idmenage Codeprod: egen tp`i'=mean(Depenses) if Modeacq==2 & Passage==`i'
	bys idmenage Codeprod: egen autocons_s`i'=mean(tp`i') 	
	replace autocons_s`i'=0 if autocons_s`i'==.
}

drop tp1 tp2 tp3 tp4

* gift

foreach i in 1 2 3 4 {
	
	bys idmenage Codeprod: egen tp`i'=mean(Depenses) if Modeacq==3 & Passage==`i'
	bys idmenage Codeprod: egen cadeau_s`i'=mean(tp`i') 
	replace cadeau_s`i'=0 if cadeau_s`i'==.
}

drop tp1 tp2 tp3 tp4

duplicates drop idmenage Codeprod, force

***********************
***********************

** Food items

* Rice

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==101
	bys idmenage: egen riz_`x'=mean(tp`x')
	label var riz_`x' "rice purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==101
	bys idmenage: egen riz_`x'=mean(tp`x')
	label var riz_`x' "rice auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==101
	bys idmenage: egen riz_`x'=mean(tp`x')
	label var riz_`x' "rice received as gift by season"
	drop tp`x'	
}



* Millet

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==102
	bys idmenage: egen mil_`x'=mean(tp`x')
	label var mil_`x' "millet purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==102
	bys idmenage: egen mil_`x'=mean(tp`x')
	label var mil_`x' "millet auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==102
	bys idmenage: egen mil_`x'=mean(tp`x')
	label var mil_`x' "millet received as gift by season"
	drop tp`x'	
}



* Sorgho

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==104
	bys idmenage: egen sorgho_`x'=mean(tp`x')
	label var sorgho_`x' "sorghum purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==104
	bys idmenage: egen sorgho_`x'=mean(tp`x')
	label var sorgho_`x' "sorghum auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==104
	bys idmenage: egen sorgho_`x'=mean(tp`x')
	label var sorgho_`x' "sorghum received as gift by season"
	drop tp`x'	
}


* Mais

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==107
	bys idmenage: egen mais_`x'=mean(tp`x')
	label var mais_`x' "maize purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==107
	bys idmenage: egen mais_`x'=mean(tp`x')
	label var mais_`x' "maize auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==107
	bys idmenage: egen mais_`x'=mean(tp`x')
	label var mais_`x' "maize received as gift by season"
	drop tp`x'	
}



* Haricot

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==120
	bys idmenage: egen haricot_`x'=mean(tp`x')
	label var haricot_`x' "beens purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==120
	bys idmenage: egen haricot_`x'=mean(tp`x')
	label var haricot_`x' "beens auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==120
	bys idmenage: egen haricot_`x'=mean(tp`x')
	label var haricot_`x' "beens received as gift by season"
	drop tp`x'	
}


* Viande boeuf, chevre

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==105 |Codeprod==114
	bys idmenage: egen viande_`x'=mean(tp`x')
	label var viande_`x' "meat purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==105 |Codeprod==114
	bys idmenage: egen viande_`x'=mean(tp`x')
	label var viande_`x' "meat auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==105 |Codeprod==114
	bys idmenage: egen viande_`x'=mean(tp`x')
	label var viande_`x' "meat received as gift by season"
	drop tp`x'	
}



* Poisson frais et fume


foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==109 |Codeprod==110
	bys idmenage: egen poisson_`x'=mean(tp`x')
	label var poisson_`x' "fish purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==109 |Codeprod==110
	bys idmenage: egen poisson_`x'=mean(tp`x')
	label var poisson_`x' "fish auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==109 |Codeprod==110
	bys idmenage: egen poisson_`x'=mean(tp`x')
	label var poisson_`x' "fish received as gift by season"
	drop tp`x'	
}


* Sucre

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==103
	bys idmenage: egen sucre_`x'=mean(tp`x')
	label var sucre_`x' "sugar purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==103
	bys idmenage: egen sucre_`x'=mean(tp`x')
	label var sucre_`x' "sugar auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==103
	bys idmenage: egen sucre_`x'=mean(tp`x')
	label var sucre_`x' "sugar received as gift by season"
	drop tp`x'	
}


* The

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==106
	bys idmenage: egen the_`x'=mean(tp`x')
	label var the_`x' "tea purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==106
	bys idmenage: egen the_`x'=mean(tp`x')
	label var the_`x' "tea auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==106
	bys idmenage: egen the_`x'=mean(tp`x')
	label var the_`x' "tea received as gift by season"
	drop tp`x'	
}


* Beurre de Karite


foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==108
	bys idmenage: egen beurreKarite_`x'=mean(tp`x')
	label var beurreKarite_`x' "shea butter purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==108
	bys idmenage: egen beurreKarite_`x'=mean(tp`x')
	label var beurreKarite_`x' "shea butter auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==108
	bys idmenage: egen beurreKarite_`x'=mean(tp`x')
	label var beurreKarite_`x' "shea butter received as gift by season"
	drop tp`x'	
}


* Huile


foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==111
	bys idmenage: egen huile_`x'=mean(tp`x')
	label var huile_`x' "cooking oil purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==111
	bys idmenage: egen huile_`x'=mean(tp`x')
	label var huile_`x' "cooking oil auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==111
	bys idmenage: egen huile_`x'=mean(tp`x')
	label var huile_`x' "cooking oil received as gift by season"
	drop tp`x'	
}


* Cube Maggi

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==118
	bys idmenage: egen maggi_`x'=mean(tp`x')
	label var maggi_`x' "cube maggi purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==118
	bys idmenage: egen maggi_`x'=mean(tp`x')
	label var maggi_`x' "cube maggi auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==118
	bys idmenage: egen maggi_`x'=mean(tp`x')
	label var maggi_`x' "cube maggi received as gift by season"
	drop tp`x'	
}


* Oignon

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==117
	bys idmenage: egen oignon_`x'=mean(tp`x')
	label var oignon_`x' "onion purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==117
	bys idmenage: egen oignon_`x'=mean(tp`x')
	label var oignon_`x' "onion auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==117
	bys idmenage: egen oignon_`x'=mean(tp`x')
	label var oignon_`x' "onion received as gift by season"
	drop tp`x'	
}


* Pain

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==112
	bys idmenage: egen pain_`x'=mean(tp`x')
	label var pain_`x' "bread purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==112
	bys idmenage: egen pain_`x'=mean(tp`x')
	label var pain_`x' "bread auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==112
	bys idmenage: egen pain_`x'=mean(tp`x')
	label var pain_`x' "bread received as gift by season"
	drop tp`x'	
}


* Arachide

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==113
	bys idmenage: egen arachide_`x'=mean(tp`x')
	label var arachide_`x' "peanut purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==113
	bys idmenage: egen arachide_`x'=mean(tp`x')
	label var arachide_`x' "peanut auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==113
	bys idmenage: egen arachide_`x'=mean(tp`x')
	label var arachide_`x' "peanut received as gift by season"
	drop tp`x'	
}



* Tubercules et plantain

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==116
	bys idmenage: egen tubercule_`x'=mean(tp`x')
	label var tubercule_`x' "tuber purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==116
	bys idmenage: egen tubercule_`x'=mean(tp`x')
	label var tubercule_`x' "tuber auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==116
	bys idmenage: egen tubercule_`x'=mean(tp`x')
	label var tubercule_`x' "tuber received as gift by season"
	drop tp`x'	
}


* Lait frais et en poudre

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Codeprod==115 |Codeprod==119
	bys idmenage: egen lait_`x'=mean(tp`x')
	label var lait_`x' "milk purchased by season"
	drop tp`x'	
}

foreach x in autocons_s1 autocons_s2 autocons_s3 autocons_s4 {

	gen tp`x'=`x' if Codeprod==115 |Codeprod==119
	bys idmenage: egen lait_`x'=mean(tp`x')
	label var lait_`x' "milk auto consumed by season"
	drop tp`x'	
}

foreach x in cadeau_s1 cadeau_s2 cadeau_s3 cadeau_s4 {

	gen tp`x'=`x' if Codeprod==115 |Codeprod==119
	bys idmenage: egen lait_`x'=mean(tp`x')
	label var lait_`x' "milk received as gift by season"
	drop tp`x'	
}


*********************
*********************
** Other expenditure -- these are only purchased (no gift or auto consumed)

* Alcool

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==2
	bys idmenage: egen alcool_`x'=mean(tp`x')
	label var alcool_`x' "consumption of alcool, tobacco and narcotic by season"
	drop tp`x'	
}


* Habillement

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==3
	bys idmenage: egen cloth_`x'=mean(tp`x')
	label var cloth_`x' "spending on apparel and shoes item by season"
	drop tp`x'	
}


* Logement

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==4
	bys idmenage: egen logement_`x'=mean(tp`x')
	label var logement_`x' "expenditure on housing and bills by season"
	drop tp`x'	
}



* Meubles, article de menage


foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==5
	bys idmenage: egen meuble_`x'=mean(tp`x')
	label var meuble_`x' "expenditure on furniture, household expenditures and maintenance by season" 
	drop tp`x'	
}



* Sante

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==6
	bys idmenage: egen sante_`x'=mean(tp`x')
	label var sante_`x' "health expenditure by season" 
	drop tp`x'	
}


* Transport

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==7
	bys idmenage: egen transport_`x'=mean(tp`x')
	label var transport_`x' "transportation expenditure by season" 
	drop tp`x'	
}


* Communication

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==8
	bys idmenage: egen communication_`x'=mean(tp`x')
	label var communication_`x' "communication expenditure by season" 
	drop tp`x'	
}



* Loisirs et cultures

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==9
	bys idmenage: egen loisirs_`x'=mean(tp`x')
	label var loisirs_`x' "spending on leisure and culture by season" 
	drop tp`x'	
}


* Enseignements

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==10
	bys idmenage: egen education_`x'=mean(tp`x')
	label var education_`x' "spending on education by season" 
	drop tp`x'	
}


* Restaurants et hotels

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==11
	bys idmenage: egen restaurant_`x'=mean(tp`x')
	label var restaurant_`x' "restaurant and hotel expenditure by season" 
	drop tp`x'	
}



* Biens et services divers

foreach x in achat_s1 achat_s2 achat_s3 achat_s4 {

	gen tp`x'=`x' if Fonction==12
	bys idmenage: egen bien_autre_`x'=mean(tp`x')
	label var bien_autre_`x' " spending on miscellaneous goods and services by season" 
	drop tp`x'	
}


drop Codeprod Fonction Freqachat Modeacq Depenses Dep_mod2

duplicates drop idmenage, force


gen year=`z'

save ModifiedData/EMOP_Depenses_`z', replace

}


********************* 
********************* 
*** append expenditure data


use ModifiedData/EMOP_Depenses_2011, clear

 append using ModifiedData/EMOP_Depenses_2013 ModifiedData/EMOP_Depenses_2014 ///
			ModifiedData/EMOP_Depenses_2015 ModifiedData/EMOP_Depenses_2016 ///
				 ModifiedData/EMOP_Depenses_2017
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
	lait_achat_`x' + lait_autocons_`x' + lait_cadeau_`x' + alcool_achat_`x' + ///
	cloth_achat_`x' + logement_achat_`x' + meuble_achat_`x' + sante_achat_`x' + transport_achat_`x' +communication_achat_`x'+ loisirs_achat_`x' + ///
	education_achat_`x' +restaurant_achat_`x' +bien_autre_achat_`x'
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

save  ModifiedData/EMOP_Depenses_passage_2011_2019, replace


********************************************************************************
********************************************************************************
********************************************************************************
*** Merging all the data

*/

use "${input}/emop_menage_2011_2019.dta", clear
duplicates drop idmenage year, force

order idmenage grappe menage region cercle commune commune_name arrond milieu se idse W1 year

	merge 1:1 idmenage year using "${input}/EMOP_hhcharact_2011_2019"
	
	keep if _merge==3 //225 observations deleted
	drop _merge

	merge 1:1 idmenage year using "${input}/input2/emop_despenses_2011_2019_cl"

	keep if _merge==3 //467 observations deleted
	drop _merge



. replace commune_name = "Commune VI" if commune_name == "Commune Vi"


. replace commune_name = "Commune VI" if commune_name == "Commune-Vi"



. replace commune_name = "Commune II" if commune_name == "Commune Ii"


. replace commune_name = "Commune III" if commune_name == "Commune Iii"


. replace commune_name = "Commune IV" if commune_name == "Commune Iv"

. replace commune_name = "Commune IV" if commune_name == "Commune-Iv"

. replace commune_name = "Commune V" if commune_name == "Commune-V"


. replace commune_name = "Commune I" if commune_name == "Commune-I"


. replace commune_name = "Commune II" if commune_name == "Commune-Ii"

. replace commune_name = "Commune III" if commune_name == "Commune-Iii"

. replace commune_name = "Bougouni" if commune_name == "Bougouni Commune"


. replace commune_name = "Adjelhoc" if commune_name == "Aguel-Hoc"

. replace commune_name = "Toridaga-Ko" if commune_name == "Toridaga Ko"


. replace commune_name = "Adarmalane" if commune_name == "D'Adarmalane"


. replace commune_name = "Dangol Bore" if commune_name == "Dangol-Bore"

replace commune_name = "Derrary" if commune_name == "Derary"

replace commune_name = "Dindanko" if commune_name == "Dangol-Bore"
replace commune_name = "Diedougou-Dio" if commune_name == "Diedougo"
replace commune_name = "Diedougou-Dio" if commune_name == "Diedougou" & region == 2

replace commune_name = "Diedougou-Seg" if commune_name == "Diedougou" & region == 4


replace commune_name = "Diedougou-Kou" if commune_name == "Diedougou" & region == 3



replace commune_name = "Dinandougou-Kou" if commune_name == "Dinandougou"
replace commune_name = "Dinangourou-Kor" if commune_name == "Dinangourou"
replace commune_name = "Diondori" if commune_name == "Diondiori"
replace commune_name = "Dogofry-Nio" if commune_name == "Dogofry"
replace commune_name = "Dougoutene II" if commune_name == "Dougoutene Ii"
replace commune_name = "Fakala Dje" if commune_name == "Fakala"

replace commune_name = "Farako-Kol" if commune_name == "Farako" & region == 3
replace commune_name = "Farako-Seg" if commune_name == "Farako" & region == 4
replace commune_name = "Fassou Debe" if commune_name == "Fassoudebe"
replace commune_name = "Fitounga" if commune_name == "Fittouga"
replace commune_name = "Gao" if commune_name == "Gao Commune"
replace commune_name = "Goudie Sougouna" if commune_name == "Gouadjie Sougouna"
replace commune_name = "Guidimakan Keri Kafo" if commune_name == "Guidimakan Keri Kaffo"
replace commune_name = "Hamzak" if commune_name == "Guidimakan Keri Kaffo"
replace commune_name = "Kayes Commune" if commune_name == "Kayes"
replace commune_name = "Kita Commune" if commune_name == "Kita"
replace commune_name = "Koula-Tom" if commune_name == "Koula" & region == 4
replace commune_name = "Koula-Kol" if commune_name == "Koula" & region == 2
replace commune_name = "Hawa Dembaya" if commune_name == "Hawa De Mbaya"
replace commune_name = "Kani Bozon" if commune_name == "Kani-Bonzoni"
replace commune_name = "Kapala-Sik" if commune_name == "Kapala" & region == 3

replace commune_name = "Kati" if commune_name == "Kati Commune"
replace commune_name = "Kouniana" if commune_name == "Kouniakary" & region == 3
replace commune_name = "Koutiala" if commune_name == "Koutiala Commune"
replace commune_name = "Liberte Dembaya" if commune_name == "Liberte De Mbaya"
replace commune_name = "Marekaffo" if commune_name == "Marekafo"
replace commune_name = "Mopti" if commune_name == "Mopti Commune"
replace commune_name = "Liberte Dembaya" if commune_name == "Liberte De Mbaya"
replace commune_name = "N'Gabacoro Droit" if commune_name == "N'Gabacoro"
replace commune_name = "N'Gabacoro Droit" if commune_name == "N'Gabacoro"
replace commune_name = "Nema Badenyakafo" if commune_name == "Nema-Badenyakafo"
replace commune_name = "Niamana-Nar" if commune_name == "Niamana" & region == 2
replace commune_name = "Niamana-San" if commune_name == "Niamana" & region == 4
replace commune_name = "San" if commune_name == "San Commune"
replace commune_name = "Segou" if commune_name == "Segou Commune"
replace commune_name = "Segou" if commune_name == "Segou Commune"
replace commune_name = "Sere Moussa Ani Samou" if commune_name == "Sere Moussa Ani Samo"
replace commune_name = "Sikasso" if commune_name == "Sikasso Commune"
replace commune_name = "Sitakily" if commune_name == "Sitakilly"
replace commune_name = "Somo-Bar" if commune_name == "Somo"
replace commune_name = "Tin-Essako" if commune_name == "Tin Essako"
replace commune_name = "Toguere Coumbe" if commune_name == "Toguere-Coumbe"
replace commune_name = "Tombouctou" if commune_name == "Tombouctou Commune"
replace commune_name = "Bamba-Bou" if commune_name == "Bamba" & region== 7
replace commune_name = "Bamba-Kor" if commune_name == "Bamba" & region== 5
replace commune_name = "Banikane Narhawa" if commune_name == "Banikane" 
replace commune_name = "Baye-Ban" if commune_name == "Baye" & region== 5
replace commune_name = "Baye-Ken" if commune_name == "Baye" & region== 1
replace commune_name = "Benkadi-Dio" if commune_name == "Benkadi" & region== 2
replace commune_name = "Bougoula-Kat" if commune_name == "Bougoula" & region== 2
replace commune_name = "Bougoula-Kol" if commune_name == "Bougoula" & region== 3
replace commune_name = "Dimbal Habe" if commune_name == "Dimbal Habbe"
replace commune_name = "Fakala-Dje" if commune_name == "Fakala Dje"
replace commune_name = "Faraba-Kat" if commune_name == "Faraba" & region == 2
replace commune_name = "Faraba-Ken" if commune_name == "Faraba" & region == 1
replace commune_name = "Koulikoro Commune" if commune_name == "Koulikoro" 
replace commune_name = "Koniakary" if commune_name == "Kouniakary" 
replace commune_name = "Nioro" if commune_name == "Nioro Commune" 



gen size_hh1 = size_hh if inlist(year,2011,2013,2014,2015,2016,2017) 
		
replace size_hh1 = taille_men if inlist(year,2018,2019) 
drop size_hh
rename size_hh1 size_hh






 















	
	
save  "${output}/EMOP_All_firstcleaned_passage_2011_2019_f", replace
save  "${Tasks}/Producing_Half_Year_Consumption/Input/EMOP_All_firstcleaned_passage_2011_2019_f", replace
	
	
	
	
