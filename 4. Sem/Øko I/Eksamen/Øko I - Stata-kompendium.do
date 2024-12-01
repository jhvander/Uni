//Start med housekeeping 
clear all
set more off
cd ""
use ""
cap log close
log using "filnavn", replace text
cls

//Deskriptiv Statistik
summarize
describe
tabstat x1 x2 x3, stat(n mean sd median min max skewness kurtosis) columns(stat)format(%8.1f)  
bysort: 

//Generer
gen x = ""
predict yhat, xb 
predict uhat, residuals


 
//Diagrammer 
graph twoway (lfit wfath xtot ) (scatter wfath xtot), name(Mad_mod_pris, replace) title("FOOD") xtitle("") ytitle("WOMEN, EXPENDITURE SHARE")

graph combine



//Test 
test K=H=0
//Modeltest - Dummyvariable
test Dummy1 dummy2 dummy3
//F-test
display invFtail(3,73,0.05)
//t-test
display invttail(77,0.95)
//Breush-Pagan tester for Hetero
essstst, rhs iid
//White's test tester for hetero
esstat "y og y^hat", idd
//Robuste standardfejl kan bruges ved Hetero
//Beregn bias
correlate y x1, covariance
correlate y x1,
//Chow-test(Se PS6 og 6.1)


//Estimationer 
//Standard
regress
regress, r
//IVregress 
regress workm morekids boy1stkid boy2ndkid agem agem1stkid black hisp other
regress workm morekids boy1stkid boy2ndkid agem agem1stkid black hisp other, r
//2SLS
ivregress 2sls y x1 (x2=z) x3
ivregress 2sls y x1 (x2=z) x3, first 
ivregress 2sls y x1 (x2=z) x3, robust  
//WLS-regression
regress y x1 x2 x3 [aw=x1^2/2]

//LaTeX
graph export "Navn", replace

//Ekstra funktioner 
//Residuals plottet against fitted variables
rvfplot
//Disp-funktioner 
display _N
display -2+2
display sqrt(.399489)
display .0156729*0.5324*(.6320516/1.061958)
//Hvis-funktioner
count if 
list if 
drop if grade == "D"
if "Variabel"!=.

//Paneldata:
xtset observ time
//FD - Brug noconstant på FD-regressioner
d.variabel
//Nocons bruges på FD-regressioner
reg dy dx, nocons
//FE-regression 
xtreg y x, fe 
//FD og FE er ens ved to tidsperiode(t=2)


//Tidsrækker
//Angiver tidsrækker
tsset tid
//FD
d.variabel
//Lag
l.variabel
//Autokorrelations-test
estat bgodfrey, lags(1 4)
//Heteroskedasticitetstest 
foreach var in DF DlogKP DlogPCP DlogYD_HPCP {
gen `var'sq=`var'^2

}
estat hettest DF l.DF l2.DF l3.DF l.DlogKP l2.DlogKP l3.DlogKP ////
           DlogPCP  l1.DlogPCP l2.DlogPCP l3.DlogPCP ////
		   DlogYD_HPCP l.DlogYD_HPCP l2.DlogYD_HPCP l3.DlogYD_HPCP ////
		   DFsq l.DFsq l2.DFsq l3.DFsq l.DlogKPsq l2.DlogKPsq l3.DlogKPsq ////
           DlogPCPsq  l.DlogPCPsq l2.DlogPCPsq l3.DlogPCPsq  ////
		   DlogYD_HPCPsq l.DlogYD_HPCPsq l2.DlogYD_HPCPsq l3.DlogYD_HPCPsq, rhs iid
//Funktionelformtest 
estat ovtest		 
//Normalfordeltstandard   
sktest uhat
//Regressions med lags 
newey dloglna inflation d.ledighed l.ledighed l.komp d.logmaxtid, lag(4)

//Monte-Carlo
//Et eksempel
program programnavn, rclass
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
programnavn

//Kører tusind gange
simulate betaols1=r(betahat1) sehat1=r(se1) reject1=r(reject1) ///
         betaols2=r(betahat2) sehat2=r(se2) reject2=r(reject2) ///
		 betawls=r(betahat3) sehatwls=r(se3) rejectwls=r(reject3) ///
		 , seed(117) reps(1000) nodots:programnavn
