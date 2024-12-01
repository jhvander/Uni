clear all
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "pwt.dta"
//Q1 - Investigate the dataset. 
describe
sum, detail // Look at min and max
//Q2 
list country if grade == "D"
drop if grade == "D"
//Q3
gen log60 = log(y60)
twoway (scatter gy log60) (lfit gy log60), name(Tabel_a, replace)
regress gy log60
//Q5
gen abs60 = 31691 * y60
gen logabs60 =log(abs60)
regress gy logabs60
twoway (scatter gy logabs60) (lfit gy logabs60), name(Tabel_b, replace)
