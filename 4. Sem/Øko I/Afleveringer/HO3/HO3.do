//Hjemmeopgave 3 - Jacob og Jeppe
//Housekeeping
clear all
set more off
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Afleveringer/HO3"
use "Groupdata6.dta"
cap log close
log using HO3-dofile, replace text
cls

//Starter 
gen FP=((fodaar==1940)|(fodaar==1939 & fodmaaned>6))
gen kvindepen=kvinde*pension66
gen kvindeFP=kvinde*FP
gen logind=log(indkomst)

generate faglaert = 0
replace faglaert = 1 if udd_kat==2

generate kortudd = 0
replace kortudd = 1 if udd_kat==3

generate mludd = 0
replace mludd = 1 if udd_kat==4

//Opgave 1a
eststo destab: qui estpost sum dod70 pension66 indkomst fodaar kvinde faglaert kortudd mludd


forvalue i=0/1 {
 eststo destab`i': qui estpost sum  dod70 pension66 indkomst fodaar kvinde faglaert kortudd mludd
}

estout destab0 destab1 destab, replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. obs"))  ///
    label  mlabels("pens. alder 67" "pens. alder 65"  "Alle")

estout destab0 destab1  destab using 1a.tex, replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("pens. alder 67" "pens. alder 65"  "Alle") style(tex)

	
//Opgave 1.c 
regress dod70 pension66 logind kvinde faglaert kortudd mludd, robust
eststo dodOLS
//Opgave 2.a

regress pension66 FP logind  kvinde faglaert kortudd mludd, robust
test FP
predict ehat, res


//Opgave 2.b
regress dod70 pension66 logind kvinde faglaert kortudd mludd ehat, robust
eststo dod_test

//Opgave 2.c
ivregress 2sls dod70 (pension66=FP) logind  kvinde faglaert kortudd mludd, robust
eststo dodIV
predict phat,xb
sum phat, detail
twoway (hist phat if kvinde==1, fcol(red) width(0.01) ) (hist phat if kvinde==0, fcol(blue) width(0.01)), legend (row(1) lab(1 "Kvinder") lab(2 "Mænd"))  xline(0)
graph export phat.png, replace


//Opgave 3.a 
regress laege70 pension66 logind kvinde faglaert kortudd mludd, robust 
ivregress 2sls laege70 (pension66=FP) logind kvinde faglaert kortudd mludd, robust 
eststo laegeIV

//Opgave 3.b 
test faglaert kortudd mludd

//Opgave 3.c 
ivregress 2sls laege70 (pension66 kvindepen=FP kvindeFP) logind kvinde faglaert kortudd mludd, first robust
eststo laegeIV2


estout dodOLS dodIV dod_test laegeIV laegeIV2, cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" )) 


estout dodOLS dodIV dod_test laegeIV laegeIV2 using 3c.tex, replace cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" ))  style(tex)

//5.a & b
clear all 


program lpmdata, rclass
	drop _all
	set obs 500
	*Genrererer data
	generate x = 2+rnormal()
	generate u = rnormal()
	generate ystar = 3-2*x+u
	generate y =(ystar>0)
	*Beregner momenter 
	regress y x
	return scalar b_ols=_b[x]
	return scalar se_ols=_se[x]
	regress y x, robust
	return scalar ser_ols=_se[x]
end

simulate beta_ols=r(b_ols) se_ols=r(se_ols) ser_ols=r(ser_ols), seed (117) reps(1000) nodots:lpmdata
eststo sim: qui estpost sum beta_ols se_ols ser_ols

label var beta_ols "OLS estimat"
label var se_ols "SE OLS"
label var ser_ols"RSE OLS"

estout sim , replace cells("mean(fmt(4)) sd(fmt(4)) min(fmt(3)) max(fmt(3))") stats(N, fmt(0) labels(" No. replications"))  label   

estout sim using simu.tex, replace cells("mean(fmt(4)) sd(fmt(4)) min(fmt(3)) max(fmt(3)) ") stats(N, fmt(0) labels(" No. replications"))  label style(tex)  

twoway (hist beta_ols, fcol(red)  ) , legend (row(1) lab(1 "OLS") ) 
graph export simugram.png, replace 


/* 5.c */
//ssh for y=1 når x=1
display "Teoretisk sandsynlighed for y=1 når x=1   " 1-normal(-1)
display "Teoretisk sandsynlighed for y=1 når x=0   " 1-normal(-3)
display "Forskellen                                " -normal(-1)+normal(-3)

