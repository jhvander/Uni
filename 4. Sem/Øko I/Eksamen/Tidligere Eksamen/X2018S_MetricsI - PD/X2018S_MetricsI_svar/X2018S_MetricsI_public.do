cls
clear all
*cap cd "C:\..."
*cap cd "/Users/..."

cap log close
cap log using "X2018S_statalog.log", text replace

use groupdata0
sort id d2
su

/*** PROBLEM 1 ***/
su prmres besk alder hovedstad barn1son famceo nborn if d2==0
su prmres besk alder hovedstad barn1son famceo nborn if d2==1
su prmres besk alder hovedstad barn1son famceo nborn if d2==1 & famceo==1
su prmres besk alder hovedstad barn1son famceo nborn if d2==1 & famceo==0

/*** PROBLEM 2.1 ***/
gen lprmres=log(prmres)
gen lbesk=log(besk)
gen aldersq=alder*alder

reg lprmres d2 famceo lbesk hovedstad alder aldersq, robust

/*** PROBLEM 2.2 ***/
by id: gen dlprmres=lprmres[_n]-lprmres[_n-1]
by id: gen dlbesk=lbesk[_n]-lbesk[_n-1]
by id: gen dalder=alder[_n]-alder[_n-1]
by id: gen daldersq=aldersq[_n]-aldersq[_n-1]

/*** TRICK: RENAME FD-VARIABLE TO ORIGINAL VARIABLE NAMES ***/
/***        TO MAKE TABLES EASIER TO READ                 ***/

foreach var in lprmres d2 famceo lbesk hovedstad alder aldersq {
	rename `var' `var'0
	by id: gen `var'=`var'0[_n]-`var'0[_n-1]
}

reg dlprmres d2 famceo dlbesk dalder daldersq, robust
test dlbesk=daldersq=0

reg lprmres d2 famceo lbesk hovedstad alder aldersq, robust
reg lprmres famceo lbesk aldersq, robust
test lbesk=aldersq=0

/*** PROBLEM 2.3 ***/
reg lprmres famceo, robust

/*** PROBLEM 3.1 ***/ 
reg famceo barn1son lbesk aldersq, robust 

/*** PROBLEM 3.2 ***/
ivregress 2sls lprmres (famceo=barn1son) lbesk aldersq, robust 

reg lprmres famceo lbesk aldersq if barn1son!=.

/*** PROBLEM 3.3 ***/
reg famceo  barn1son nborn lbesk aldersq

ivregress 2sls lprmres (famceo=barn1son nborn) lbesk aldersq
predict uhat, residual

reg uhat barn1son nborn lbesk aldersq
di e(N)*e(r2)

clear all
global numobs = 500
set seed 117
set sortseed 1479
global rho1 = -1
global rho2 = +1

program dgp, rclass
	drop _all
	
	*SET NUMBER OF CURRENT OBSERVATIONS 
	set obs $numobs
	gen i=_n
	expand 2
	bysort i: gen t=_n
	sort i t
	
	*DATA GENERATING PROCESS
	gen u=6*(runiform()-0.5)
	by i: gen u1=u[_n-1] if t==2
		
	gen alpha=2*rnormal() if t==1
	by i: replace alpha=alpha[_n-1] if t==2
	
	gen epsilon=4*(runiform()-0.5)
	
	gen program=0 if t==1
	replace program=(($rho1 *u1+$rho2 *alpha+epsilon)>0) if t==2
	ta t program
	
	gen y=1+1*t-3*program+alpha+u
	
	*CALCULATE OLS and FD ESTIMATES
	by i: gen dy=y[_n]-y[_n-1] if t==2
	
	reg y program if t==2
	return scalar betahat1= _b[program]
	
	reg dy program
	return scalar betahat2= _b[program]
	
	reg u1 program if t==2
	return scalar temp1= _b[program]
	
	reg alpha program if t==2
	return scalar temp2= _b[program]
	
	count if program==1
	return scalar nprog=r(N)
end

*RUN PROGRAM ONCE
dgp

*SIMULATION EXPERIMENTS 
global rho1 = 0
global rho2 = 0
simulate OLS=r(betahat1) FD=r(betahat2) nprog=r(nprog) temp1=r(temp1) temp2=r(temp2), seed(117) reps(1000) nodots:dgp
su

global rho1 = -1
global rho2 = 0
simulate OLS=r(betahat1) FD=r(betahat2) nprog=r(nprog) temp1=r(temp1) temp2=r(temp2), seed(117) reps(1000) nodots:dgp
su

global rho1 = 0
global rho2 = +1
simulate OLS=r(betahat1) FD=r(betahat2) nprog=r(nprog) temp1=r(temp1) temp2=r(temp2), seed(117) reps(1000) nodots:dgp
su

global rho1 = -1
global rho2 = +1
simulate OLS=r(betahat1) FD=r(betahat2) nprog=r(nprog) temp1=r(temp1) temp2=r(temp2), seed(117) reps(1000) nodots:dgp
su

cap log close
