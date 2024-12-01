
*PROBLEM SET 7
clear all
cd "z:\underv01\økonometriI\holdundervisning\PS7"
cap log close
log using PS7, replace text

*QUESTION 1: LOAD DATA AND DESCRIPTIVE STATISTICS
use cphapts
describe
su

*DEFINE VARIABLES
gen logprice=log(price)
gen m2price=price/m2
gen sqm2=m2*m2/1000
replace price=price/1000000

gen KbhK=1 if location=="KBH K"
replace KbhK=0 if KbhK==.

gen KbhN=1 if location=="KBH N"
replace KbhN=0 if KbhN==.

gen KbhV=1 if location=="KBH V"
replace KbhV=0 if KbhV==.

*QUESTION 1: ESTIMATE (2). CALCULATE RESIDUALS AND PREDICTED VALUES
regress price KbhK KbhN KbhV m2 sqm2 rooms toilets 
predict uhat, residuals
predict yhat, xb
gen uhat2=uhat*uhat
label variable uhat2 "Squared residuals"

*QUESTION 2: PLOTS
scatter uhat yhat, name(fig1, replace)
scatter uhat m2, , name(fig2, replace)
scatter uhat2 yhat, name(fig3, replace)
scatter uhat2 m2, , name(fig4, replace)

graph combine fig1 fig2 fig3 fig4
*graph export PS7.png, replace

*QUESTION 3: BP TEST Two ways of doing this 
* Approach 1 (Question 3)
estat hettest , rhs iid

*(Question 4)
estat hettest m2, iid

* Approach 2
regress uhat2 KbhK KbhN KbhV m2 sqm2 rooms toilets 
gen BP=e(N)*e(r2)
gen c=invchi2tail(7,0.05)
su BP c
drop BP c

*QUESTION 4: SPECIFIC-BP TEST
regress uhat2 m2
gen BP=e(N)*e(r2)
gen c=invchi2tail(1,0.05)
su BP c
drop BP c

*QUESTION 5: WLS
regress price KbhK KbhN KbhV m2 sqm2 rooms toilets [aweight=1/m2]

*QUESTION 6: MANUEL WLS
gen w=1/sqrt(m2)

foreach x in price KbhK KbhN KbhV m2 sqm2 rooms toilets {
  gen `x'star=`x'*w
}

reg pricestar KbhKstar KbhNstar KbhVstar m2star sqm2star ///
	          roomsstar toiletsstar w, nocon

drop yhat uhat uhat2 

*QUESTION 7: ROBUST INFERENCE
regress price KbhK KbhN KbhV m2 sqm2 rooms toilets, robust
test rooms toilets

*QUESTION 8: ESTIMATE (1). CALCULATE RESIDUALS 
regress logprice KbhK KbhN KbhV m2 sqm2 rooms toilets 
predict uhat, residuals
gen uhat2=uhat*uhat

*QUESTION 8: BP TEST
* Approach 1
estat hettest, rhs iid
*Approach 2
regress uhat2 KbhK KbhN KbhV m2 sqm2 rooms toilets 
gen BP=e(N)*e(r2)
gen c=invchi2tail(7,0.05)
su BP c
drop BP c

log close
			 
