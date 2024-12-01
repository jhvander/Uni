clear all
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "AngristEvans.dta"

//Opgave 1 
tabstat workm weekm hourm lincm faminc nkids if samesex==0, stat(mean sd min max) columns(stat)format(%8.1f) 
tabstat workm weekm hourm lincm faminc nkids if samesex==1, stat(mean sd min max) columns(stat)format(%8.1f) 

//Opgave 2
regress workm morekids boy1stkid boy2ndkid agem agem1stkid black hisp other, r 

//Opgave 3 
ivregress 2sls workm (morekids=samesex) boy1stkid boy2ndkid agem agem1stkid black hisp other, r 

//Opgave 4 
ivregress 2sls workm (morekids=twoboys twogirls) boy1stkid agem agem1stkid black hisp other, r


