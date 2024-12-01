
*PROBLEM SET 10
clear all

cd "H:\underv01\økonometriI\holdundervisning\ps10"

cap log close
log using PS10, replace text

use tbpanel

*QUESTION 1: SUMMARY STATISTICS
summarize
summarize if d2002==0
summarize if d2002==1

*QUESTION 2: POOLED OLS
generate kvindeXpension=kvinde*pension

regress tbalder enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde kvindeXpension, robust
eststo OLS
test kvindeXpension=0
test pension+kvindeXpension=0
predict ehat, residuals
generate SSR=e(rss)

*MANUAL TEST FOR QUESTION 2.B
generate x = kvindeXpension-pension
regress tbalder enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde x, robust

*QUESTION 3: FD
sort lbnr d2002
xtset lbnr d2002
by lbnr: generate diftbalder=tbalder[_n]-tbalder[_n-1]
generate Dtbalder=d.tbalder

foreach var in enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde kvindeXpension {
	by lbnr: generate dif`var'=`var'[_n]-`var'[_n-1]
	generate D`var'=d.`var'
}

summarize dif*
summarize D*

regress diftbalder difenlig difhelbred difdudd1 difdudd2 diferfar difpension difkpenbelob difd2002 difkvinde difkvindeXpension, robust
test difkvindeXpension=0
test difpension+difkvindeXpension=0


*QUESTION 4: FE
foreach var in tbalder enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde kvindeXpension {
	by lbnr: egen m_`var'=mean(`var')
	generate wt_`var'=`var'-m_`var'

}

regress wt_tbalder wt_enlig wt_helbred wt_dudd1 wt_dudd2 wt_erfar wt_pension wt_kpenbelob wt_d2002 wt_kvinde wt_kvindeXpension

xtset lbnr d2002
xtreg tbalder enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde kvindeXpension, fe
eststo FE

foreach var in tbalder enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde kvindeXpension {
	drop `var'
	rename D`var' `var'
}
reg tbalder enlig helbred dudd1 dudd2 erfar pension kpenbelob d2002 kvinde kvindeXpension
eststo FD


estout OLS FD FE, cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons " Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" )) 

log close
