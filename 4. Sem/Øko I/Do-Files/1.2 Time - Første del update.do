cls
clear all 
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "opg1.dta"

egen xtot = rowtotal(x*)
gen xcloth = xwcloth + xmcloth
foreach var of varlist x* {
gen w`var' = `var' / xtot
}
