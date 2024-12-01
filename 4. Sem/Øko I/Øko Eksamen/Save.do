//Starter med housekeeping 
clear all
set more off
cd "/Users/Japee/Documents/Øko Eksamen"
use "Groupdata2.dta"
cap log close
log using "222_225_226", replace text
cls

xtset id month 
//Gen variable
gen agesq = age*age
gen high = 0 
replace high =1 if edu==2
gen kudd = 0 
replace kudd =1 if edu==3
gen ludd = 0 
replace ludd =1 if edu==4
gen indpost = ind_shut*post
//Opgave 1 
*1.1
bysort early: outreg2 using 1a.tex, replace sum(detail) sortvar(female age edu hours post ind_shut) keep(female age edu hours post ind_shut) eqkeep(mean sd min max) dec(3) title(Tabel 1)
*1.2
binscatter hours month, by(early) line(connect) discrete 
graph export 1b.png, replace
*1.3
gen epost = early*post
reg hours early post epost, r
outreg2 using 1c.tex, replace keep(early post epost age agesq female high kudd ludd ind_shut indpost) eqkeep(coef) ctitle(OLS_1c) title(Tabel 2)

//Opgave 2
*2.1
reg hours early post epost age agesq female high kudd ludd ind_shut indpost 
outreg2 using 1c.tex, append keep(early post epost age agesq female high kudd ludd ind_shut indpost) eqkeep(coef) ctitle(OLS_2a) title(Tabel 2)
//Laver en Breusch-Pagan test
estat hettest, rhs iid 
disp invchi2tail(60342,0.05)

*2.2
xtreg hours early post epost age agesq female high kudd ludd ind_shut indpost, re r 
outreg2 using 1c.tex, append keep(early post epost age agesq female  high kudd ludd ind_shut indpost) eqkeep(coef) ctitle(RE_2b) title(Tabel 2)
xtreg hours post epost age agesq female ind_shut indpost, fe r
outreg2 using 1c.tex, append keep(early post epost age agesq female  high kudd ludd ind_shut indpost) eqkeep(coef) ctitle(FE_2b) title(Tabel 2)
*2.3
winsor2 hours, replace cut(5 95) trim
reg hours early post epost age agesq female high kudd ludd ind_shut indpost 
outreg2 using 1c.tex, append keep(early post epost age agesq female high kudd ludd ind_shut indpost) eqkeep(coef) ctitle(OLS_2c) title(Tabel 2)


//Opgave 3
*3.1 
reg notworking early post epost age agesq female high kudd ludd ind_shut indpost
outreg2 using 1c.tex, append keep(early post epost age agesq female high kudd ludd ind_shut indpost) eqkeep(coef) ctitle(OLS_3a) title(Tabel 2)
estat ovtest	 
display invFtail(2,60339,0.05)
*3.2
gen sudd = high+kudd+ludd 
reg notworking early post epost age agesq female sudd ind_shut indpost
*3.3 
count if month==1
count if month==2
count if month==3
count if month==4
count if month==5
outreg2 using 3c.tex if replies==1, replace sum(detail) sortvar(female age edu hours) keep(female age edu hours) eqkeep(mean) dec(3) ctitle("Replies 1") title(Tabel 4)
outreg2 using 3c.tex if replies==4, append sum(detail) sortvar(female age edu hours) keep(female age edu hours) eqkeep(mean) dec(3) ctitle("Replies 4") title(Tabel 4) 

//Opgave 5
*5.1
set seed 117
set sortseed 117

program dgp, rclass
	drop _all
	
	*Fra opgavebeskrivelsen
	set obs 400
	gen alpha=rnormal()*sqrt(2)
	gen id=_n
	expand 2
	bysort id: gen t=_n
	xtset id t
	
	*Variable
	gen rho=-0.2
	gen u=rnormal()
    gen xstar= 2+2*rnormal()
	gen x=xstar +rho*alpha
	
	gen y=1+2*x+alpha+u
	
//Laver estimationerne 
	*OLS
	reg y x
	return scalar betaols= _b[x]
	return scalar seols= _se[x]
	
	*FE
	xtreg y x, fe
	return scalar betafe=_b[x]
	return scalar sefe= _se[x]
	
end
*Kører once
dgp

*Simulation
simulate OLSbeta=r(betaols) OLSse=r(seols) FEbeta=r(betafe) FEse=r(sefe), seed(117) reps(1000) nodots:dgp
outreg2 using 5a, replace tex sum(detail) sortvar(OLSbeta OLSse FEbeta FEse) keep(OLSbeta OLSse FEbeta FEse) eqkeep(mean sd min max) dec(4) title(Tabel 5)  

program adgp, rclass
	drop _all
	
	*Fra opgavebeskrivelsen
	set obs 400
	gen alpha=rnormal()*sqrt(2)
	gen d=(alpha<0.5)
	gen id=_n
	expand 2
	bysort id: gen t=_n
	xtset id t
	
	*Variable
	gen rho=-0.2
	gen u=rnormal()
    gen xstar= 2+2*rnormal()
	gen x=xstar +rho*d
	
	gen y=1+2*x+d+u if d==1
	
//Laver estimationerne
	*OLS
	reg y x
	return scalar dbetaols= _b[x]
	return scalar dseols= _se[x]
	
	*FE
	xtreg y x, fe
	return scalar dbetafe=_b[x]
	return scalar dsefe= _se[x]
end

*Kører once
adgp

*Simulation
simulate dOLSbeta=r(dbetaols) dOLSse=r(dseols) dFEbeta=r(dbetafe) dFEse=r(dsefe) , seed(117) reps(1000) nodots:adgp
outreg2 using 5b, replace tex sum(detail) sortvar(dOLSbeta dOLSse dFEbeta dFEse) keep(dOLSbeta dOLSse dFEbeta dFEse) eqkeep(mean sd min max) dec(4) title(Tabel 6)  

