clear all
set more off
cls
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "pwt.dta"
// Dropping insufficient data
list country if grade == "D"
drop if grade == "D"
drop if missing(sh)
//Creating variables
gen K = ln(sk)-ln(n+0.075)
gen H = ln(sh)-ln(n+0.075)
gen Ln60 = log(y60)
//Creating OLS
regress gy Ln60 K H 
//2.3
display invFtail(3,73,0.05)
//Dette bliver 2,73 

//Opgave 2.4 
display invttail(75,0.05)
regress gy Ln60
regress gy K
regress gy H

//Opgave 2.6
regress gy Ln60 K H 
test K=H=0

//Opgave 2.7

//Opgave 5.7.

mata

y = st_data(.,"gy") //Y-matricen
x = st_data(., "Ln60 K H") //X-matricen uden konstantled
//Viser x-matrixen
x
//Viser y-matricen
y
cons = J(rows(x),1,1)
X = (x,cons) //Konstruerer den rigtige x-matrix med konstantled, dog med konstanten til sidst, men nu står det i rigtig rækkefølge ift. stata-outputtet ved regression.
//Viser x-matricen med konstantled i 4. søjle.
X
//Laver beta-estimat-vektoren
beta_hat = (invsym(X'*X)*X'*y)
beta_hat
//Finder standardfejlene
u_hat = y-X*beta_hat
//Finder sigma^2
s2 = (1/(rows(X)-cols(X)))*u_hat'*u_hat
//Finder variansen af OLS:
V_ols = s2*(invsym(X'*X))
//Finder nu standardafvigelsen (som står i diagonalen i V_ols)
se_ols = sqrt(diagonal(V_ols))
//Beregner t-teststørrelserne
ttest = beta_hat:/se_ols
//Resultater
(beta_hat, se_ols, ttest)
s2
end
//For sammenligning
regress gy Ln60 K H

 






