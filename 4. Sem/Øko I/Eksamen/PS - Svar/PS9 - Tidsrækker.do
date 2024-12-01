/*******************************************************************************
********************************* UGESEDDEL 9 **********************************
*******************************************************************************/
clear all
cd " " /* Indsæt din egen sti */

*Indlæs data
use MONAdata.dta

*Angiver, at vi har et tidsrækkedatasæt
tsset tid

*SPØRGSMÅL 1: Grafisk analyse
gen loglna=ln(lna)
gen Dloglna=d.loglna


*SPØRGSMÅL 1.a: Lønindekset over tid
twoway (line lna tid, clwidth(0.8) lc(navy)), title("Lønudviklingen 1975-2018") ////
   ytitle("Nominelt lønindeks") graphregion(fc(white)) saving(loglna.gph, replace)
   
   
*SPØRGSMÅL 1.b: Nominelle lønstigninger over tid 
twoway (line Dloglna tid, clwidth(0.8) lc(navy)), title("Nominel lønstigning 1975-2018") ////
  ytitle("Nominelle kvartalsvise lønstigninger") graphregion(fc(white)) saving(dloglna.gph, replace)   

 graph combine loglna.gph Dloglna.gph, col(1) xcommon graphregion(fc(white)) 
 graph export Figur1b.png, replace
  
  
*SPØRGSMÅL 1.c: Alle forklarende variable  
twoway (line ledighed tid, clwidth(0.5) lc(navy)), title("Ledigheden") ////
   ytitle(" ") graphregion(fc(white)) nodraw saving(ledighed.gph, replace)
   
twoway (line komp tid, clwidth(0.5) lc(navy)), title("Kompensationsgrad") ////
   ytitle(" ") graphregion(fc(white)) nodraw saving(komp.gph, replace)

twoway (line maxtid2 tid, clwidth(0.5) lc(navy)), title("Aftalt arbejdstid") ////
   ytitle(" ") graphregion(fc(white)) nodraw saving(arbejdstid.gph, replace)
   
twoway (line inflation tid, clwidth(0.5) lc(navy)), title("Inflation") ////
   ytitle(" ") graphregion(fc(white)) nodraw saving(infl.gph, replace)

 graph combine infl.gph ledighed.gph komp.gph arbejdstid.gph, col(2) row(2) xcommon  graphregion(fc(white))   
 graph export Figur1c.png, replace
 
* Konstruer variable i modellen:
gen dloglna=d.loglna
gen dledighed=d.ledighed
gen lledighed=l.ledighed
gen logmaxtid=ln(maxtid)
gen dlogmaxtid=d.logmaxtid
gen lkomp=l.komp


*SPØRGSMÅL 2: Estimation af model (1)

*SPØRGSMÅL 2.a: OLS med konstruerede variable
reg dloglna inflation dledighed lledighed l.komp dlogmaxtid


*SPØRGSMÅL 2.b: OLS med tidsrækkefunktioner
reg d.loglna inflation d.ledighed l.ledighed l.komp d.logmaxtid


*SPØRGSMÅL 2.c: Test for autokorrelation
estat bgodfrey, lags(1 4)

* Kritiske værdier
dis invchi2tail(1, 0.05)
dis invchi2tail(4, 0.05)


*SPØRGMÅL 2.d: Robuste standardfejl
newey dloglna inflation d.ledighed l.ledighed l.komp d.logmaxtid, lag(4)


*SPØRGSMÅL 2.e: Test om modellen kan reduceres til den simple Phillips kurve
test inflation d.ledighed l.komp d.logmaxtid


*SPØRGSMÅL 2.f: 
newey d.loglna inflation l.ledighed  d.ledighed d.logmaxtid l.komp, lag(4) 
predict yhat, xb

twoway (line dloglna tid, clwidth(0.5) lc(navy)) (line yhat tid, clwidth(0.5) lc(gs10)), ////
     title("Nominelle lønstigninger 1975-2018") ////
   ytitle("Lønraten") nodraw legend( order(1 "Faktisk" 2 "Estimeret")) graphregion(fc(white)) saving(prediction.gph, replace)


twoway (line dloglna tid if tid>tq(1994q4), clwidth(0.5) lc(navy)) (line yhat tid if tid>tq(1994q4) , clwidth(0.5) lc(gs10)), ////
     title("Nominelle lønstigninger 1995-2018") ////
   ytitle("Lønraten") nodraw legend( order(1 "Faktisk" 2 "Estimeret")) graphregion(fc(white)) saving(prediction95.gph, replace)
 

 graph combine prediction.gph prediction95.gph, col(2) row(1)  graphregion(fc(white))   
 graph export Figur2f.png, replace
 
