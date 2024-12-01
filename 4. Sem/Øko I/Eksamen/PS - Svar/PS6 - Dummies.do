
*PROBLEM SET 6
clear all
cd ""
cap log close
log using PS6, replace text

*QUESTION 1: LOAD DATA AND DESCRIPTIVE STATISTICS
use cphapts
describe
su

*DEFINE VARIABLES
gen logprice=log(price)
gen m2price=price/m2
gen sqm2=m2*m2/1000

ta location
tabstat m2price price m2 rooms, by(location) stat(mean)
tabstat m2price price m2 room, by(location) stat(median)

*QUESTION 2: ESTIMATE MODEL (1)
regress logprice m2 rooms toilets

*QUESTION 3: CHOW TEST
regress logprice m2 rooms toilets if location=="KBH K"
gen SSR_1=e(rss)

regress logprice m2 rooms toilets if location=="KBH V"
gen SSR_2=e(rss)

regress logprice m2 rooms toilets if location=="KBH O"
gen SSR_3=e(rss)

regress logprice m2 rooms toilets if location=="KBH N"
gen SSR_4=e(rss)

regress logprice m2 rooms toilets 
gen SSR_p=e(rss)

*CHOW TEST
gen chow=(SSR_p-(SSR_1+SSR_2+SSR_3+SSR_4))/(SSR_1+SSR_2+SSR_3+SSR_4)*((988-4*4)/(3*4))

*CRITICAL VALUE
gen c=invFtail(12,988-4*4,0.05)
su chow c
drop SSR* chow c

*IMPLEMENTING CHOW TEST USING INTERACTION TERMS
gen KbhK=1 if location=="KBH K"
replace KbhK=0 if KbhK==.

gen KbhN=1 if location=="KBH N"
replace KbhN=0 if KbhN==.

gen KbhV=1 if location=="KBH V"
replace KbhV=0 if KbhV==.

foreach x in KbhK KbhN KbhV {
  gen `x'm2=`x'*m2
  gen `x'rooms=`x'*rooms
  gen `x'toilets=`x'*toilets
  gen `x'sqm2=`x'*sqm2
}

regress logprice m2 rooms toilets KbhK KbhN KbhV KbhKm2 KbhNm2 KbhVm2 KbhKrooms KbhNrooms KbhVrooms KbhKtoilets KbhNtoilets KbhVtoilets

*ALTERNATIVE CHOW TEST
test KbhK KbhN KbhV KbhKm2 KbhNm2 KbhVm2 KbhKrooms KbhNrooms KbhVrooms KbhKtoilets KbhNtoilets KbhVtoilets

*T1: TEST IF ALL INTERACTION TERMS=0
test KbhKm2 KbhNm2 KbhVm2 KbhKrooms KbhNrooms KbhVrooms KbhKtoilets KbhNtoilets KbhVtoilets

*T2: TEST IF INTERACTION TERMS FOR ROOMS AND TOILETS=0
test KbhKrooms KbhNrooms KbhVrooms KbhKtoilets KbhNtoilets KbhVtoilets

*QUESTION 4: MODEL WITH LEVEL-DUMMIES INCLUDED
regress logprice m2 rooms toilets KbhK KbhN KbhV
*IS THIS PREFERRED OVER FULL MODEL? NO. IN THE FULL MODEL, WE REJECT
*THAT ALL INTERACTION TERMS ARE ZER0, SEE T1-TEST ABOVE
test KbhK KbhN KbhV

*QUESTION 5: MODEL WITH LOCATION-M2 INTERACTION TERMS
regress logprice m2 rooms toilets KbhK KbhN KbhV KbhKm2 KbhNm2 KbhVm2 
*IS THIS PREFERRED OVER FULL MODEL? BORDERLINE. WE ARE VERY CLOSE TO 
*NOT REJECT THE NULL HYPOTHESIS THAT THE INTERACTION TERMS WITH
*ROOMS AND TOILETS ARE ZERO, SEE T2-TEST ABOVE
test KbhKm2 KbhNm2 KbhVm2 

*QUESTION 6: INCLUDING SQUARED M2 AND ADDITIONAL INTERACTION TERMS
regress logprice m2 sqm2 rooms toilets KbhK KbhN KbhV KbhKm2 KbhNm2 KbhVm2 KbhKsqm2 KbhNsqm2 KbhVsqm2 
test KbhKm2 KbhNm2 KbhVm2 KbhKsqm2 KbhNsqm2 KbhVsqm2

*PREFERRED MODEL
regress logprice m2 sqm2 rooms toilets KbhK KbhN KbhV
regress logprice m2 sqm2 KbhK KbhN KbhV

log close
