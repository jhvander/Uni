clear all 
cls
// Sætter globale værdier
global numobs = 50
global numrho = 1
//Opstiller et program :)
program olsdata, rclass
drop _all
set obs $numobs
gen rho = $numrho
gen beta0 = 1
gen beta1 = 2 
gen beta2 = -3 

gen x1 = 25+5*rnormal()
gen u = -50 + 100*runiform()
gen x2s=10+20*runiform()
gen x2 = rho*x1+x2s
gen y = beta0+beta1*x1+beta2*x2+u 

//Regressionsmodellen
regress y x1 
return scalar b1_slr = _b[x1] //SLR
regress y x1 x2
return scalar b1_mlr = _b[x1] //MLR 
end

simulate betahat_slr=r(b1_slr) betahat_mlr=r(b1_mlr), seed(1479) reps(1000) nodots:olsdata
summarize



