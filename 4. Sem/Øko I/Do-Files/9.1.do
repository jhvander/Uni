//Housekeeping
clear all
set more off
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "MONAdata.dta"
cls

tsset tid  

//Opgave 1
gen Dlna = d.lna
twoway line lna tid 
//1.b 
twoway line Dlna tid
//1.c 
twoway line ledighed tid, name(a, replace) 
twoway line inflation tid, name(b, replace) 
twoway line komp tid, name(c, replace)
twoway line maxtid2 tid, name(d, replace)  
graph combine a b c d, name(Combined, replace)
//Konstruerer variable 
gen lled = l.ledighed 
gen lko = l.komp 
gen larb = l.maxtid2 
gen linf = l.inflation
//Opgave 2 - Generer flere variable
gen loglna = ln(lna)
gen logarb = ln(maxtid2)
gen dlogarb = d.logarb
gen dloglna = d.loglna
gen dled = d.ledighed 
//2a
reg dloglna inflation lled dled dlogarb lko
estat bgodfrey, lags(1 4)
//2b 
reg dloglna inflation l.ledighed d.ledighed dlogarb l.komp
estat bgodfrey, lags(1 4)
//2d 
newey dloglna inflation l.ledighed d.ledighed dlogarb l.komp, lag(4)
//2.e 
//2.f 


 
