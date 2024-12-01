cd "C:\Users\zpn160\Dropbox\Econometrics I\Eksamen\2021E"
use Exam2022data.dta, clear

label variable dlogbnp "$\Delta \log(BNP_{t})$"
label variable uilaan "$\left(\frac{\text{udlan}}{\text{indlan}}\right)_{it}$"
label variable bankno "Bank id nr"
label variable aar "\AA r"
label variable uvaekst "$\Delta\log(\text{udl\aa n}_{it})$"
label variable cibor1 "$ CIBOR_{t}$"
label variable dcibor1 "$\Delta CIBOR_{t}$"
label variable logbnp "$\log(BNP_{t})$"

********************************************************************************
* Opgave 1.1
********************************************************************************

eststo destab: qui estpost sum 
estout destab  using tableopg11.tex, replace cells("mean(fmt(4)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") ///
       stats(N, fmt(0) labels(" No. obs")) mlabels(, none )	style(tex) label

********************************************************************************
* Opgave 1.2
********************************************************************************

xtset bankno aar

binscatter logbnp aar, discrete line(connect) name(logbnp)
binscatter dlogbnp aar, discrete line(connect) name(dlogbnp)
graph combine logbnp dlogbnp
graph export figopg12bnp.png, replace
binscatter cibor1 aar, discrete line(connect) name(cibor1)
binscatter dcibor1 aar, discrete line(connect) name(dcibor1)
graph combine cibor1 dcibor1
graph export figopg12cibor1.png, replace

********************************************************************************
* Opgave 2.1
********************************************************************************

gen lagdcibor1=l.dcibor1
gen lagdlogbnp=l.dlogbnp
gen laguilaan=l.uilaan

label variable lagdcibor1 "$\Delta CIBOR_{t-1}$"
label variable lagdlogbnp "$\Delta \log(BNP_{t-1})$"
label variable laguilaan "$\left(\frac{\text{udl\aa n}}{\text{indl\aa n}}\right)_{it-1}$"

eststo clear
reg uvaekst lagdcibor1 lagdlogbnp laguilaan
eststo, title("2.1 OLS")

********************************************************************************
* Opgave 2.2
********************************************************************************

reg uvaekst lagdcibor1 lagdlogbnp laguilaan
estat hettest, rhs iid
predict uhat, res
gen uhatsq=uhat^2
reg uhatsq lagdcibor1 lagdlogbnp laguilaan
ereturn list
scalar R2=e(r2)
scalar LM=R2*e(N)
scalar pvalue=chi2tail(3,LM)
display "LM test-statistics  " LM 
display "p-value             " pvalue

reg uvaekst lagdcibor1 lagdlogbnp laguilaan, robust
eststo, title("2.2 OLS robust")

********************************************************************************
* Opgave 2.3
********************************************************************************

xtreg uvaekst lagdcibor1 lagdlogbnp laguilaan, fe i(bankno) robust
eststo, title("2.3 FE")

********************************************************************************
* Opgave 2.4
********************************************************************************

gen lagdcibor1laguilaan=lagdcibor1*laguilaan
label variable lagdcibor1laguilaan "$\Delta CIBOR_{t-1}\times\left(\frac{\text{udlan}}{\text{indlan}}\right)_{it-1}$"

reg uvaekst lagdcibor1 lagdlogbnp laguilaan lagdcibor1laguilaan, robust
eststo, title("2.4 OLS interaktion")

su laguilaan
di "Effekt i gns. af laguilaan: " _b[lagdcibor1]+r(mean)*_b[lagdcibor1laguilaan] 

estout using tablesopg2.tex, cells("b(fmt(3) star)" "se(par fmt(3))") label collabels(none) ///
       varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels("Obs" "Rsq" )) style(tex) replace

********************************************************************************
* Opgave 3.1
********************************************************************************

xi i.aar*laguilaan

gen gammahat=.
reg uvaekst lagdlogbnp lagdcibor1 _IaarXlag_*, robust

forvalues ii=1993/2015 {
	replace gammahat=_b[_IaarXlag_`ii'] if aar==`ii'
}
label variable gammahat "$\hat{\gamma}$"

collapse gammahat lagdlogbnp lagdcibor1, by(aar)

tsset aar

graph twoway connected gammahat aar, name(gammahat)

label variable lagdcibor1 "$\Delta CIBOR_{t-1}$"
label variable lagdlogbnp "$\Delta \log(BNP_{t-1})$"

reg gammahat aar
predict detrendgammahat, res
graph twoway connected detrendgammahat aar, name(detrendgammahat)
graph combine gammahat detrendgammahat
graph export figopg31.png, replace

********************************************************************************
* Opgave 3.2
********************************************************************************

eststo clear
reg gammahat lagdcibor1 lagdlogbnp
eststo, title("3.2 2nd step")
estat bgodfrey, lags(1)

reg gammahat lagdcibor1 lagdlogbnp aar
eststo, title("3.2 2nd step time-trend")
estat bgodfrey, lags(1)

estout using tablesopg3.tex, cells("b(fmt(3) star)" "se(par fmt(3))") label collabels(none) ///
       varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels("Obs" "Rsq" )) style(tex) replace 

********************************************************************************
* Opgave 5
********************************************************************************
	   
clear all

cd "C:\Users\zpn160\Dropbox\Econometrics I\Eksamen\2021E"

global rho=0.4
global theta=0.3
global beta0=1
global beta1=2
global T=300
set seed 117

program mc_timeseries, rclass
	drop _all
	*Data genererende proces
	set obs $T
	gen v=sqrt(2)*rnormal()
	gen u=0 if _n==1
	replace u=$rho*u[_n-1]+v if _n>1
	gen zeta=sqrt(0.5)*rnormal()
	gen x=0 if _n==1
	replace x=$theta*x[_n-1]+zeta if _n>1
	gen y=$beta0+$beta1*x+u
	gen tid=_n
	* Opgave 5 (a)
	tsset tid
	reg y x
	return scalar bols=_b[x]
	return scalar seols=_se[x]
	return scalar rejectols=((abs(_b[x]-$beta1)/_se[x])>1.96)
	* Opgave 5 (b)
	newey y x, lag(1)
	return scalar bnewey=_b[x]
	return scalar senewey=_se[x]
	return scalar rejectnewey=((abs(_b[x]-$beta1)/_se[x])>1.96)
	* Opgave 5 (c)
	reg y l.y x l.x
	return scalar badl=_b[x]
	return scalar seadl=_se[x]
	return scalar rejectadl=((abs(_b[x]-$beta1)/_se[x])>1.96)
end

simulate bols=r(bols) seols=r(seols) rejectols=r(rejectols) ///
		 bnewey=r(bnewey) senewey=r(senewey) rejectnewey=r(rejectnewey) ///
         badl=r(badl) seadl=r(seadl) rejectadl=r(rejectadl), ///
		 seed(117) reps(1000): mc_timeseries

eststo destab: qui estpost sum 
estout destab  using tableopg5.tex, replace cells("mean(fmt(4)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") ///
       stats(N, fmt(0) labels(" No. obs")) mlabels(, none )	style(tex)
