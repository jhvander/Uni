//Hjemmeopgave 2 - Jacob og Jeppe
//Housekeeping
clear all
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Afleveringer/HO2"
use "groupdata3.dta"
cap log close
log using HO2-dofile, replace text


//Opgave 1a - Deskriptiv analyse & dummy-variabler
generate ankomst2014 = 0
replace ankomst2014 = 1 if ankomstaar==2014

generate ankomst2015 = 0
replace ankomst2015 = 1 if ankomstaar==2015

generate ankomst2016 = 0
replace ankomst2016 = 1 if ankomstaar==2016

summarize if mand==1 & aar==2017
summarize if mand==0 & aar==2017
summarize if mand==1 & aar==2018
summarize if mand==0 & aar==2018

//Opgave 1b - Konstruer modellen
generate logaarslon = log(aarslon)
generate ysm = aar-ankomstaar
regress logaarslon alder ysm if aar==2017
outreg2 using 1b, tex


//Opgave 1c - Sum af Beta_1 og Beta_2
generate ysmalder = ysm-alder
regress logaarslon alder ysmalder if aar==2017
outreg2 using 1c, tex

//Opgave 2.a
regress logaarslon alder ysm ankomstaar
outreg2 using 2a, tex


//Opgave 3a 
gen alder2 = alder^2
gen ysm2 = ysm^2
gen kohorte15 = ankomst2015
gen kohorte16 = ankomst2016
regress logaarslon alder alder2 ysm ysm2 kohorte15 kohorte16
outreg2 using 3a, tex

regress logaarslon alder alder2 ysm ysm2 kohorte15 kohorte16

//Opgave 3b
eststo: regress logaarslon alder alder2 ysm ysm2 kohorte15 kohorte16 if mand==1
esttab using tmand.tex
eststo clear 
eststo: regress logaarslon alder alder2 ysm ysm2 kohorte15 kohorte16 if mand==0
esttab using tkvinde.tex
eststo clear 
display invttail(3806,0.025)
display invttail(982,0.025)

//Opgave 3c
regress logaarslon alder alder2 ysm ysm2 kohorte15 kohorte16 if mand==1
rvfplot

//Opgave 5a
// Sætter globale værdier
global numobs = 50
//Opstiller et program :)
program hetdata, rclass
    drop _all
	set obs $numobs
	gen beta0 = 2
	gen beta1 = 3 
	gen beta2 = -1
	gen beta3 = -1

	gen x1 = 1+rnormal()*4
	gen x2 = 1+rnormal()*4
	gen x3 = 1+rnormal()*4
	gen u = rnormal()*(0.25*x1^4)
	gen y = beta0+beta1*x1+beta2*x2+beta3*x3+u

//Regressionsmodellerne
	regress y x1 x2 x3 
	return scalar betahat1= _b[x1]
	return scalar se1     = _se[x1]
	return scalar tstat1  = (_b[x1]-3)/_se[x1]
	return scalar pvalue1 = 2*ttail($numobs-4, abs(return(tstat1)))
	return scalar reject1 = abs(return(tstat1)) > invttail($numobs-4,.025)
	
	regress y x1 x2 x3, robust
	return scalar betahat2= _b[x1]
	return scalar se2     = _se[x1]
	return scalar tstat2  = (_b[x1]-3)/_se[x1]
	return scalar pvalue2 = 2*ttail($numobs-4, abs(return(tstat2)))
	return scalar reject2 = abs(return(tstat2)) > invttail($numobs-4,.025)
	
	regress y x1 x2 x3 [aw=x1^2/2]
	return scalar betahat3= _b[x1]
	return scalar se3     = _se[x1]
	return scalar tstat3  = (_b[x1]-3)/_se[x1]
	return scalar pvalue3 = 2*ttail($numobs-4, abs(return(tstat3)))
	return scalar reject3 = abs(return(tstat3)) > invttail($numobs-4,.025)
end
//Kører en gang 
hetdata

//Kører tusind gange
simulate betaols1=r(betahat1) sehat1=r(se1) reject1=r(reject1) ///
         betaols2=r(betahat2) sehat2=r(se2) reject2=r(reject2) ///
		 betawls=r(betahat3) sehatwls=r(se3) rejectwls=r(reject3) ///
		 , seed(117) reps(1000) nodots:hetdata

*Summerer alle resultater 
summarize beta* se* rej*

eststo sumtab: estpost sum betaols1 betaols2 betawls sehat1 sehat2 sehatwls reject1 reject2 rejectwls
estout sumtab using sim_50.tex , replace style(tex) cells("mean(fmt(3)) sd(fmt(3)) min(fmt(2)) max(fmt(2))") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels(, none )









