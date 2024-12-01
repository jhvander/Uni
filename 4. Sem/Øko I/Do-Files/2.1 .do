clear all 
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "opg1.dta"
//Opgave 2
// Konstruer model 1. 

//2.i
egen xtot = rowtotal(x*)
regress xfath xtot if dmale==1
// 2.vi
twoway (scatter xfath xtot if dmale==1) (lfit xfath xtot if dmale==1)
//2.vii
regress xfath xtot if dmale==1
predict yhat if e(sample)==1, xb 
predict uhat if e(sample)==1, residuals

scatter uhat yhat if dmale==1, name(Variable, replace)
scatter xtot uhat if dmale==1, name(xtot_Kontrax , replace)
scatter xtot yhat if dmale==1, name(xtot_Kontray, replace)
//Opgave 3
// Konstruer model 2 
gen RealInd = log(xtot/price)
gen AndelMad = (xfath/xtot)
gen AndelWtoj = (xwcloth/xtot)
gen AndelMtoj = (xmcloth/xtot)
gen AndelAlc = (xalc/xtot)

//Finder OLS for AndelMad, toj og Alk
regress AndelMad RealInd if dmale==1
regress AndelMad RealInd if dmale==0
regress AndelAlc RealInd if dmale==1
regress AndelAlc RealInd if dmale==0
regress AndelMtoj RealInd if dmale==1
regress AndelWtoj RealInd if dmale==0
