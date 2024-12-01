cls
clear all
cd "C:\Users\wxz578\Dropbox\Teaching\U Copenhagen\Metrics I 2019 Spring\Exam\"
cap log close

log using "X2019S_takehome.log", replace text
use groupdata1

/*** OPGAVE 1 ***/
gen logY=log(Y)
gen logP=log(P)
gen logA=log(A)

su Y logY T P logP A logA pTi pTa N
quietly estpost summarize Y logY T P logP A logA pTi pTa N, de
esttab using T1.tex, replace cells("mean(fmt(a3)) p50 min max") nomtitle nonumber title(Summary Statistics)

twoway (scatter N T, saving(Fig1.gph)) (lfit N T), legend(off)
twoway (scatter N logY, saving(Fig2.gph)) (lfit N logY), legend(off)
graph combine Fig1.gph Fig2.gph, ycommon
graph export Fig1.pdf, replace
erase Fig1.gph
erase Fig2.gph
graph close

reg N T, robust
reg N logY, robust

/*** OPGAVE 2.1+2.4 ***/
reg logY T logP logA, robust
eststo olsrobust
reg logY T logP logA
eststo ols
predict uhat, residuals
predict yhat, xb
local R2r=e(r2)
local tstat=_b[T]/_se[T]
local p = ttail(125-4,`tstat')
display "P-værdi for ensidet alternativ: p = 0`p'"
display "Kristisk værdi for ensidet alternativ: c = " invt(121,0.95)

/*** OPGAVE 2.2 ***/
gen uhat2=uhat*uhat
reg uhat2 T logP logA
eststo BP
di "BP-test LM = 125*R2 = " 125*e(r2)

/*** OPGAVE 2.3 ***/
gen yhat2=yhat*yhat
gen yhat3=yhat*yhat*yhat

reg logY T logP logA yhat2 yhat3
eststo reset
local R2ur=e(r2)
test yhat2 yhat3
drop uhat* yhat*

di "Korrekt F-stat = " ((`R2ur'-`R2r')/2)/((1-`R2ur')/(125-5-1))
di "Approx F-stat = "((0.086-0.052)/2)/((1-0.086)/(125-5-1))

/*** OPGAVE 3.1 ***/
regress T pTi logP logA
eststo first1
predict e1, residual

regress T pTa logP logA
eststo first2
predict e2, residual

ivregress 2sls logY (T=pTi) logP logA, small
eststo iv1

ivregress 2sls logY (T=pTa) logP logA, small
eststo iv2

ivregress 2sls logY (T=pTi pTa) logP logA, small first
reg T pTi pTa logP logA

/*** OPGAVE 3.2 ***/
regress logY T logP logA e1
eststo exo1
regress logY T logP logA e2
eststo exo2

esttab olsrobust ols BP reset using T2.tex, replace title(OLS-resultater) ///
mtitles("OLS-HCSE" "OLS" "BP-test" "RESET" ) se star(* 0.05) r2 noomit

esttab  first1 first2 iv1 iv2 exo1 exo2 using T3.tex, replace title(IV-resultater) ///
mtitles("1st" "1st" "IV1" "IV2" "Exo,pTi" "Exo,pTa") se star(* 0.05) r2 noomit

/*** OPGAVE 5 ***/
clear all
set seed 117

*GLOBAL VARIABLES
global numobs = 200
global my1=2
global my2=2
global my3=2
global var1=3
global var2=1
global var3=1
global cov12=1.25
global cov13=0.75
global cov23=0.6
global beta0=1
global beta1=0.5
global beta2=-0.75
global beta3=1.25

*DEFINE PROGRAM THAT SPECIFIES THE DGP
program simdata, rclass
	drop _all
	
	*SET NUMBER OF CURRENT OBSERVATIONS 
	*set obs $numobs
	
	*DATA GENERATING PROCESS
	matrix my=($my1 ,$my2 ,$my3)
	matrix cov=($var1 ,$cov12 , $cov13 \ $cov12 , $var2 , $cov23 \ $cov13 , $cov23 , $var3 )
	drawnorm x1 x2 x3, n($numobs) means(my) cov(cov)
	
	generate u = rnormal()
	generate y = $betao +$beta1 *x1 + $beta2 *x2 +$beta3 *x3+u
	
	*CALCULATE OLS ESTIMATES AND SAVE RESULTS 
	regress y x1
	return scalar betahats= _b[x1]
	
	regress y x1 x2
	return scalar betahatm= _b[x1]
	
	regress y x1 x2 x3
	return scalar betahatl= _b[x1]
	
	regress x3 x1 x2 
	return scalar deltahat1= _b[x1]
	return scalar deltahat2= _b[x2]
	
	regress x3 x1
	return scalar ols31= _b[x1]
end

*RUN PROGRAM ONCE
qui simdata
cls
pwcorr

*EXPERIMENT 1: BASELINE
simulate olsshort=r(betahats) olsmedium=r(betahatm) olslong=r(betahatl) ///
		 olsdelta1=r(deltahat1) olsdelta2=r(deltahat2) ols31=r(ols31), ///
		 seed(117) reps(1000) nodots:simdata
		 
di "Expected OLS-M1: " $beta1+($beta2*$cov12+$beta3*$cov13)/$var1
di "Expected OLS-M2: " $beta1+$beta3*($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
di "Simple OVB: " $beta1+$cov13/$var1
di "Expected OLS-M3: " $beta1
di "Expected OLS-delta1:  " ($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
su

*EXPERIMENT 2: SET COV13=0
global cov13=0

simulate olsshort=r(betahats) olsmedium=r(betahatm) olslong=r(betahatl) ///
		 olsdelta1=r(deltahat1) olsdelta2=r(deltahat2) ols31=r(ols31), ///
		 seed(117) reps(1000) nodots:simdata
		 
di "Expected OLS-M1: " $beta1+($beta2*$cov12+$beta3*$cov13)/$var1
di "Expected OLS-M2: " $beta1+$beta3*($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
di "Simple OVB: " $beta1+$cov13/$var1
di "Expected OLS-M3: " $beta1
di "Expected OLS-delta1:  " ($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
su

*EXPERIMENT 3: SET COV23=0
global cov13=0.75
global cov23=0

simulate olsshort=r(betahats) olsmedium=r(betahatm) olslong=r(betahatl) ///
		 olsdelta1=r(deltahat1) olsdelta2=r(deltahat2) ols31=r(ols31), ///
		 seed(117) reps(1000) nodots:simdata
		 
di "Expected OLS-M1: " $beta1+($beta2*$cov12+$beta3*$cov13)/$var1
di "Expected OLS-M2: " $beta1+$beta3*($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
di "Simple OVB: " $beta1+$cov13/$var1
di "Expected OLS-M3: " $beta1
di "Expected OLS-delta1:  " ($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
su

*EXPERIMENT 4: SET COV12=0
global cov23=0.6
global cov12=0

simulate olsshort=r(betahats) olsmedium=r(betahatm) olslong=r(betahatl) ///
		 olsdelta1=r(deltahat1) olsdelta2=r(deltahat2) ols31=r(ols31), ///
		 seed(117) reps(1000) nodots:simdata
		 
di "Expected OLS-M1: " $beta1+($beta2*$cov12+$beta3*$cov13)/$var1
di "Expected OLS-M2: " $beta1+$beta3*($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
di "Simple OVB: " $beta1+$cov13/$var1
di "Expected OLS-M3: " $beta1
di "Expected OLS-delta1:  " ($cov13*$var2-$cov12*$cov23)/($var1*$var2-$cov12^2)
su

*di c(current_time)`
log close
