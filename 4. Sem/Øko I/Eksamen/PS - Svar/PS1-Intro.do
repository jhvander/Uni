
*PROBLEM SET 1
clear all
cd ""

*QUESTION 1: READ THE DATA FILE 'OPG1' INTO STATA
use opg1.dta

*QUESTION 2: EXAMINE DATA
describe
summarize
list if xmcloth>0 & xwcloth>0
count if xmcloth>0 & xwcloth>0

*QUESTIONS 3+4: CONSTRUCT RELEVANT VARIABLES
generate xtot=xfath+xrest+xhhop+xwcloth+xmcloth+xtran+xrecr+xtob+xalc+xcare+xcaruse	
generate wfath = xfath/xtot  
generate wwcloth = xwcloth/xtot  
generate wmcloth = xmcloth/xtot
generate walc = xalc/xtot
 
summarize xtot wfath wwcloth wmcloth walc 

*QUESTION 5: SCATTER PLOTS
*MEN
scatter wfath xtot if dmale==1, name(men1, replace) title("FOOD") xtitle("") ytitle("MEN, EXPENDITURE SHARE")
scatter wmcloth xtot if dmale==1, name(men2, replace) title("CLOTHES") xtitle("") ytitle("")
scatter walc xtot if dmale==1, name(men3, replace) title("ALCOHOL") xtitle("") ytitle("")

*WOMEN
scatter wfath xtot if dmale==0, name(women1, replace) title("FOOD") xtitle("") ytitle("WOMEN, EXPENDITURE SHARE")
scatter wwcloth xtot if dmale==0, name(women2, replace) title("CLOTHES") xtitle("") ytitle("")
scatter walc xtot if dmale==0, name(women3, replace) title("ALCOHOL") xtitle("") ytitle("")

graph combine men1 men2 men3 women1 women2 women3

*NOTE: SCATTER PLOTS CAN BE SAVED USING GRAPH EXPORT
*TYPE "HELP GRAPH EXPORT" FOR MORE INFORMATION

*QUESTION 6: DESCRIPTIVE STATISTICS
bysort dmale: summarize xtot wfath wwcloth wmcloth walc 

*SAVE DATA
save engel.dta, replace
