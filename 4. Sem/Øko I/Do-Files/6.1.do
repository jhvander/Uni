clear all
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "cphapts.dta"



//Opgave 1
replace location = "KBH O" if location != "KBH K" & location != "KBH N" & location != "KBH V"

tabstat price m2 if location =="KBH K", stat(n mean sd median min max skewness kurtosis) columns(stat)format(%8.1f)  
tabstat price m2 if location =="KBH V", stat(n mean sd median min max skewness kurtosis) columns(stat)format(%8.1f) 
tabstat price m2 if location =="KBH N", stat(n mean sd median min max skewness kurtosis) columns(stat)format(%8.1f)  
tabstat price m2 if location =="KBH O", stat(n mean sd median min max skewness kurtosis) columns(stat)format(%8.1f)

//Opgave 2 
gen lnp = log(price)
regress lnp m2 rooms toilets
//Opgave 3
qui regress lnp m2 rooms toilets 
scalar SSRp =e(rss)
scalar n = e(n)

qui regress lnp m2 rooms toilets if location == "KBH V"
scalar SSR1 = e(rss)

qui regress lnp m2 rooms toilets if location == "KBH N"
scalar SSR2 = e(rss)

qui regress lnp m2 rooms toilets if location == "KBH K"
scalar SSR3 = e(rss)

qui regress lnp m2 rooms toilets if location == "KBH O"
scalar SSR4 = e(rss)

scalar k = 3
scalar g = 4
display (SSRp - (SSR1 + SSR2 + SSR3 + SSR4))/(SSR1 + SSR2 + SSR3 + SSR4)*((988-g*(k+1))/((k+1)*(g-1)))
invFtail(12,972,0.05)

//Opgave 4 




