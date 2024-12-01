clear all
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "cphapts.dta"


replace location = "KBH O" if location != "KBH K" & location != "KBH N" & location != "KBH V"
//Q1 - Estimerer model 2 
// Først omskrives prisen til mio. 
// Bruger København Ø som baseline
gen pris = price/1000000
gen KBN = 0 
replace KBN =1 if location=="KBH N"
gen KBV = 0 
replace KBV =1 if location=="KBH V"
gen KBK = 0 
replace KBK =1 if location=="KBH K"

gen m2sq = m2^2
regress pris KBK KBN KBV m2 m2sq rooms toilets 
outreg2 using 1b, tex 
predict uhat, residuals 
predict yhat, xb

tabstat uhat yhat, stat(mean sd min max) columns(stat)format(%8.1f)

//Q2 
gen uhatsq = uhat^2

twoway (scatter uhat m2) (lfit uhat m2), name(Tabel_a, replace)
twoway (scatter uhat yhat) (lfit uhat yhat), name(Tabel_b, replace)
twoway (scatter uhatsq m2) (lfit uhatsq m2), name(Tabel_c, replace)
twoway (scatter uhatsq yhat) (lfit uhatsq yhat), name(Tabel_d, replace)
graph combine Tabel_a Tabel_b Tabel_c Tabel_d 

//Q3
regress uhatsq KBK KBN KBV m2 m2sq rooms toilets
test KBK KBN KBV m2 m2sq rooms toilets

//Q4
regress uhatsq m2
outreg2 using 4, tex

//Q5 
regress pris KBK KBN KBV m2 m2sq rooms toilets [aweight=1/m2]
outreg2 using 5, tex

//Q6 
gen weight = 1/(m2^0.5)

gen apris = pris*weight
gen aKBN = KBN*weight
gen aKBV = KBV*weight
gen aKBK = KBK*weight
gen am2 = m2*weight
gen am2sq = m2sq*weight
gen arooms = rooms*weight 
gen atoilets = toilets*weight

regress apris aKBN aKBK aKBV am2 am2sq arooms atoilets weight, noconstant
outreg2 using 6, tex

//Q7
regress pris KBK KBN KBV m2 m2sq rooms toilets, robust 
test KBV = 0 
test rooms = toilets = 0 

//Q8
gen lnpris = ln(price) 
regress lnpris KBK KBN KBV m2 m2sq rooms toilets
predict uhat2, residuals 

gen uhat2sq = uhat2^2

regress uhat2sq KBK KBN KBV m2 m2sq rooms toilets 

estat hettest, rhs iid
 
