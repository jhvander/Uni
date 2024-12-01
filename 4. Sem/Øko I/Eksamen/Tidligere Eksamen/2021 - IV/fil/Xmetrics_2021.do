
clear all
cd "h:\underv01\økonometriI\F2021\eksamen"
global pathdata "h:\underv01\økonometriI\F2021\eksamen\data_final"
global pathout "h:\underv01\økonometriI\F2021\eksamen\output"

use $pathdata\Groupdata7, clear

describe

/* Konstruktion af variable */
gen FP=0
replace FP=1 if fodaar==1940|(fodaar==1939 & fodmaaned>6)
tab udd_kat, gen(dudd)
gen logind=log(indkomst)
gen kvindexpen=kvinde*pension66
gen kvindexFP=kvinde*FP

/* opgave 1 */
*1.a Deskriptiv tabel specielt fokus på indkomst fordelingen
eststo destab: qui estpost sum dod70 pension66  indkomst fodaar  kvinde dudd*


forvalue i=0/1 {
 eststo destab`i': qui estpost sum  dod70 pension66  indkomst fodaar kvinde dudd*  if FP==`i'   
}


estout destab0 destab1  destab , replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("pens. alder 67" "pens. alder 65"  "Alle")


estout destab0 destab1  destab using $pathout\desc.tex , replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("pens. alder 67" "pens. alder 65"  "Alle") style(tex)

/* 1.c OLS regression */
/* fortolkning + antagelser*/

regress dod70 pension66 logind  kvinde dudd2-dudd4, robust
eststo dodOLS

/* opgave 2 */
/* 2.a First stage+ diskussion af instrument*/
regress pension66 FP logind  kvinde dudd2-dudd4, robust
test FP
predict ehat, res

/* 2.b exogenitets test */
regress dod70 pension66 logind  kvinde dudd2-dudd4 ehat, robust
eststo dod_extest

/* 2.c Undersøg om modellen er velspecificeret */
ivregress 2sls dod70 (pension66=FP) logind  kvinde dudd2-dudd4, robust
eststo dodIV
predict phat,xb
sum phat, detail

twoway (hist phat if kvinde==1, fcol(red) width(0.01) ) (hist phat if kvinde==0, fcol(blue) width(0.01)), legend (row(1) lab(1 "Kvinder") lab(2 "Mænd"))  xline(0)
graph export $pathout\phat.png, replace
 
/* opgave 3 */
/* 3a */

regress laege70 pension66 logind  kvinde dudd2-dudd4, robust

ivregress 2sls laege70 (pension66=FP) logind  kvinde dudd2-dudd4, robust
eststo laegeIV

/* 3.b test for uddannelse */

test dudd4 dudd2 dudd3



/* 3.c heterogene effekter*/

ivregress 2sls laege70 (pension66 kvindexpen=FP kvindexFP) logind  kvinde dudd2-dudd4, first robust
eststo laegeIV_h


estout dodOLS dodIV dod_extest  laegeIV laegeIV_h, cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" )) 


estout dodOLS dodIV dod_extest  laegeIV laegeIV_h using $pathout\esttab.tex, replace cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" ))  style(tex)


/* Oppgave 5 */

/* Simulationsstudie */

clear all


*DEFINE PROGRAM THAT SPECIFIES THE DGP
program lpmdata, rclass
	drop _all
	
	*SET NUMBER OF CURRENT OBSERVATIONS 
	set obs 500
	
	*DATA GENERATING PROCESS
	* true process
	generate x = 2+rnormal()
	generate u = rnormal()
	generate ystar = 3-2*x+u
	generate y =(ystar>0)
	*CALCULATE OLS ESTIMATES AND OLS SLOPE IN B1
	regress y x
	return scalar b_ols=_b[x]
	return scalar se_ols=_se[x]
	regress y x, robust
	return scalar ser_ols=_se[x]
end

*SIMULATE PROGRAM 10000 TIMES
simulate  beta_ols=r(b_ols) se_ols=r(se_ols) ser_ols=r(ser_ols), seed(117) reps(1000) nodots:lpmdata

eststo sim: qui estpost sum beta_ols se_ols ser_ols

label var beta_ols "OLS estimat"
label var se_ols "Std. fejl af OLS"
label var ser_ols"Robus Std. fejl af OLS"
      
estout sim , replace cells("mean(fmt(4)) sd(fmt(4)) min(fmt(3)) max(fmt(3))") stats(N, fmt(0) labels(" No. replikationer"))  label   

estout sim using $pathout\simtab.tex, replace cells("mean(fmt(4)) sd(fmt(4)) min(fmt(3)) max(fmt(3)) ") stats(N, fmt(0) labels(" No. replikationer"))  label style(tex)  

twoway (hist beta_ols, fcol(red)  ) , legend (row(1) lab(1 "OLS") ) 
graph export $pathout\simhist.png, replace 

/* 5.c */
/* sandsynligheden for y=1 når x=1 */
display "Teoretisk sandsynlighed for y=1 når x=1   " 1-normal(-1)
display "Teoretisk sandsynlighed for y=1 når x=0   " 1-normal(-3)
display "Forskellen                                " -normal(-1)+normal(-3)






