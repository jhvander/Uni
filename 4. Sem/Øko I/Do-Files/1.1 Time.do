// How To Stata - Problemset 1
cls
clear all 
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Stata-Files"
use "opg1.dta"
sum
count if xmcloth>0 & xwcloth>0
count if xmcloth>0
count if xwcloth>0
count if xmcloth==0 & xwcloth==0
sum year
display _N
//Opstiller en variabel for den samlede udgift.
generate xtot = xalc + xcare + xcaruse + xfath + xhhop + xmcloth + xrecr + xrest + xtob + xtran + xwcloth
//Generer en samlet variabel for tøj
gen xcloth = xmcloth + xwcloth 
//Opstiller omkostningandele for de forskellige udgiftskategorier
gen walc = xalc/xtot
gen wcare = xcare/xtot
gen wcaruse = xcaruse/xtot
gen wfath = xfath/xtot
gen whhop = xhhop/xtot
gen wmcloth = xmcloth/xtot
gen wrecr = xrecr/xtot
gen wrest = xrest/xtot
gen wtob = xtob/xtot
gen wtran = xtran/xtot
gen wwcloth = xwcloth/xtot
gen wcloth = xcloth/xtot
//Opstiller et scatterplot ved budgetandele kontra samlet expenditure for hhv mænd og kvinder
scatter wfath xtot if dmale==1
scatter wwcloth xtot if dmale==0
scatter walc xtot if dmale==1
//Scatter mad for alle husholdningerne. Dette ses ved ikke at skrive "if dmale==x"
scatter wfath xtot 
//Scatter tøf for alle husholdninger
scatter wcloth xtot
//brief description analysis. Bysort betyder sorter efter køn. Fx dmale==1 er mænd og dmale==0 er kvinder
bysort dmale: sum xfath wfath, detail
bysort dmale: sum xwcloth xcloth, detail 
bysort dmale: sum cxalc walc, detail 
//Er medianen ikke lig middelværdien, så fordelingen højre eller venstreskæv.
//Finder en regressionslinje. 
graph twoway (lfit wcloth xtot) (scatter wcloth xtot), name(Tøj_mod_pris, replace) 
graph twoway (lfit wfath xtot ) (scatter wfath xtot), name(Mad_mod_pris, replace) 


