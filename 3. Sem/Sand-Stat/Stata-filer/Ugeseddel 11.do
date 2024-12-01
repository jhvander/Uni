use sand_spskema2021.dta, clear
gen ryger = inlist(rygning,1,2)
tabulate ryger
count if rygning ==1 | rygning ==2
gen hjelm  = inlist(cykelhjelm,1,2)
reg hjelm ryger 
