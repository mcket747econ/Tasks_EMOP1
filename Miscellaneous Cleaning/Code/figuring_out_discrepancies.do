
. use "C:\Users\mcket\OneDrive\Documents\Tasks_EMOP\Producing_Half_Year_Consumpt
> ion\Output\emop_halfyear_cons_for_regressions.dta" 

. gen consom_added = consom_food + consom_nonfood
(836 missing values generated)

. gen consom_diff = consom_total - consom_added
(836 missing values generated)

. preserve

. keep if consom_diff != 0
(78,034 observations deleted)

. order consom_total, before(consom_added)

. format consom_total %8.6f

. format consom_total %9.0f

. format consom_total %8.26f
invalid %format
r(120);

. format consom_total %9.2f

. format consom_total %9.3f

. format consom_total %9.2f

. format consom_total %9.1f

. 
. format consom_total %8.1f

. format consom_total %8.2f

. format consom_total %9.1f

. format consom_total %10.2f

. format consom_total %11.2f

. format consom_total %11.3f

. format %10.3f consom_total

. format %10.3f consom_added

. gen sd_diff sd consom_diff
variable consom_diff already defined
r(110);

. gen sd_diff = sd consom_diff
sd not found
r(111);

. sum consom_diff

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
 consom_diff |     16,116    .0001257    .0308705         -1          1

. sum consom_total

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
consom_total |     16,116    267727.1    243602.4   7836.111   1.16e+07

. codebook years
variable years not found
r(111);

. codebook year

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
year                                                                                                                                                                 (unlabeled)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                  Type: Numeric (double)

                 Range: [2011,2019]                   Units: 1
         Unique values: 7                         Missing .: 0/16,952

            Tabulation: Freq.  Value
                        3,003  2011
                        2,215  2013
                        2,508  2014
                        2,322  2015
                        2,521  2016
                        2,203  2018
                        2,180  2019

. restore

. 
