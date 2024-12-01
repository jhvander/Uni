
*PROBLEM SET 2
clear all
cd ""

*QUESTION 1: BEGIN STATA LOG FILE
cap log close
log using PS2, replace text

*READ IN DATA FROM LAST WEEK
use engel

*QUESTION 2: ESTIMATE SIMPLE ENGLE CURVE REGRESSION MODEL
regress xfath xtot if dmale==1
predict yhat if e(sample)==1, xb
predict uhat if e(sample)==1, residuals

*SCATTER PLOT WITH FITTED REGRESSION LINE
twoway (scatter xfath xtot if dmale==1) (lfit xfath xtot if dmale==1)
graph export PS2_lfit.eps, replace

*SCATTER PLOTS OF RESIDUALS, PREDICTED VALUES AND THE EXPLANATORY VARIABLE
scatter uhat xtot, name(fig1, replace)
scatter uhat yhat, name(fig2, replace)
graph combine fig1 fig2
graph export PS2_resplot.eps, replace

*CORRELATIONS AMONG RESIDUALS, PREDICTED VALUES AND THE EXPLANATORY VARIABLE
*ARE THEY CONSISTENT WITH THE OLS ESTIMATOR'S MECHANICAL PROPERTIES?
correlate uhat xtot
correlate uhat yhat
correlate yhat xtot

*QUESTION 3: CONSTRUCT NEW VARIABLES
generate wcloth=(xwcloth+xmcloth)/xtot
generate lnrxtot=log(xtot/price)

*QUESTION 4: ESTIMATE ENGEL CURVE MODELS IN EXPENDITURE SHARES
regress wfath lnrxtot if dmale==1
outreg2 lnrxtot using results, replace excel

regress wcloth lnrxtot if dmale==1
outreg2 lnrxtot using results, append excel 

regress walc lnrxtot if dmale==1
outreg2 lnrxtot using results, append excel 

regress wfath lnrxtot if dmale==0
outreg2 lnrxtot using results, append excel 

regress wcloth lnrxtot if dmale==0
outreg2 lnrxtot using results, append excel 

regress walc lnrxtot if dmale==0
outreg2 lnrxtot using results, append excel 

*CLOSE STATA LOG FILE
log close

*CLOSE ALL GRAPHS
window manage close graph _all
