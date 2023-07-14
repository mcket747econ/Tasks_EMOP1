
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
	global tasks "C:/Users/mcket/OneDrive/Documents/Tasks_EMOP"
	global project "${Tasks}/Cleaning_Consumption_2011_2017"
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



foreach z in 2011 2013 2014 2015 2016 {

	use ${input}/EMOP_Depenses_`z', clear
	
	rename Idmenage idmenage

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


// drop Codeprod Fonction Freqachat Modeacq Depenses Dep_mod2

duplicates drop idmenage, force


gen year=`z'

save ${output}/EMOP_Depenses_`z', replace
save ${tasks}/Final_Cleaning_2011_2017/Input/EMOP_Depenses_`z', replace

}
********************* 
********************* 
*** append expenditure data

