
clear all
cd "h:\underv01\økonometriI\F2020\eksamen\data"
global pathdata "h:\underv01\økonometriI\F2020\eksamen\data"
global pathout "h:\underv01\økonometriI\F2020\eksamen\program"


use groupdata0
/* generer variable */
gen d2017=(aar==2017)


/* opgave 1 */
*1.a Deskriptiv tabel
eststo destab: qui estpost sum krimrate ledighed_1524 ledighed_2529 studentrate koen_balance 


forvalue i=0/1 {
 eststo destab`i': qui estpost sum krimrate ledighed_1524 ledighed_2529 studentrate koen_balance  if d2017==`i'   
}


estout destab0 destab1  destab , replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("2012" "2017"  "Alle")

	
estout destab0 destab1  destab using $pathout\destab.tex, replace  cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("2012" "2017"  "Alle") style(tex)
	

*1.b Estimerer modellen med OLS

reg krimrate ledighed_1524 ledighed_2529 studentrate koen_balance storby d2017, robust
eststo OLS
 
*1.c Estimer modellen med WLS
generate w=(pop_mand1529)
reg krimrate ledighed_1524 ledighed_2529 studentrate koen_balance storby d2017 [aw=w]
eststo WLS


/* opgave 2 */

xtset kom_nr d2017


preserve

foreach var in krimrate ledighed_1524 ledighed_2529 koen_balance studentrate {
gen D`var'=d.`var'
drop `var'
gen `var'=D`var'
}
*2.a First difference
* FD uden vægte
reg krimrate ledighed_1524 ledighed_2529 koen_balance studentrate d2017, nocons robust
eststo FD
*2.b FD med vægte
* FD med vægte
reg krimrate ledighed_1524 ledighed_2529 koen_balance studentrate d2017 [aweight=w], nocons
eststo FD_W
*2.c test af hypotese 
test koen_balance ledighed_2529 studentrate

reg krimrate ledighed_1524  d2017 [aweight=w], nocons
eststo FD_Ws
predict krimratehat, xb
*2.d
* Lave en graf over ændringer i krimrate og ledighed 15-24
twoway (scatter krimrate ledighed_1524) (line krimratehat ledighed_1524, clwidth(0.6)) ///
  ,  xtitle("Ændringer i ledighed") ytitle("Ændringer i kriminalitetsrate") ///
  legend(on order(1 "Data" 2 "Prædiktioner fra FD-model")) graphregion(color(white))
graph export $pathout\scatter.png, replace

/* Opgave 3 IV estimation */
*3.a IV estimation + tjek validt instrument
ivregress 2sls krimrate (ledighed_1524=Dz )  d2017, nocons first robust
eststo FD_IV

*3.b
/* endogenitetstest */
regress ledighed_1524 Dz d2017, nocons robust
test Dz
eststo FS_IV
predict ehat, residual
regress krimrate ledighed_1524 d2017 ehat , robust 


*3.c FD-IV estimation med vægte

ivregress 2sls krimrate (ledighed_1524=Dz )  d2017 [aweight=w], nocons first 
eststo FD_IV_W
restore



estout OLS WLS FD FD_W FD_Ws FD_IV FD_IV_W , cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" )) 

   estout OLS WLS FD FD_W FD_Ws FD_IV FD_IV_W using $pathout\esttab.tex, replace cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label collabels(none)   varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels(" Obs" " Rsq" )) style(tex)


clear all

global numobs = 100
global rho=-0.2 
global delta=-0.7
global theta=0.5

*DEFINE PROGRAM THAT SPECIFIES THE DGP
program olsdata, rclass
	drop _all
	
	*SET NUMBER OF CURRENT OBSERVATIONS 
	set obs $numobs
	
	*DATA GENERATING PROCESS
	generate a = rnormal()
	gen id=_n
	expand 2
	bysort id: gen t=_n
	sort id t
	xtset id t
	generate xstar = 4+ 2*rnormal()
	generate u = rnormal()
	generate x = xstar+ $rho*u+$delta*a
	generate y = 3+1*x+a+u
	generate z = -0.5*xstar+$theta*a
	
	generate dx=d.x
	generate dy=d.y
	
	*CALCULATE OLS ESTIMATES AND SAVE RESULTS 
	regress y x
	return scalar betaOLS= _b[x]
	return scalar se_OLS = _se[x]

	regress dy dx, nocons
	return scalar betaFD= _b[dx]
	return scalar se_FD = _se[dx]

	ivregress 2sls y (x=z)
	return scalar betaIV = _b[x]
	return scalar se_IV  = _se[x]
	
	
	ivreg dy (dx=z), nocons
	return scalar betaFDIV= _b[dx]
	return scalar se_FDIV  = _se[dx]
	
end


*RUN PROGRAM ONCE
olsdata
return list

*5.a
*NOW RUN PROGRAM 1000 TIMES USING SIMULATE
simulate betaOLS=r(betaOLS) se_OLS=r(se_OLS) betaFD=r(betaFD) se_FD=r(se_FD) betaIV=r(betaIV) se_IV=r(se_IV)  ///
         betaFDIV=r(betaFDIV) se_FDIV=r(se_FDIV), ///
         		 seed(117) reps(1000) nodots:olsdata
				 
*5.b
gen biasOLS=betaOLS-1
gen biasIV=betaIV-1

sum biasOLS biasIV
display "OLS asymptotisk bias     "  ($delta+$rho)/(4+($rho)^2+($delta)^2)
display "IV asymptotisk bias       "  $theta/(-2+$theta*$delta)  	


*5.c

*SUMMARIZE ALL 1000 OLS ESTIMATES

foreach x in OLS FD IV FDIV{
preserve
gen betahat=beta`x'
gen sehat=se_`x'
eststo sim`x': qui estpost sum betahat sehat
drop betahat sehat
restore
}

 
estout simOLS simFD simIV simFDIV , replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. repl"))  label   
estout simOLS simFD simIV simFDIV using $pathout\simtab.tex, replace cells("mean(fmt(3)) sd(fmt(3)) ") stats(N, fmt(0) labels(" No. repl"))  label style(tex)  

/* Historgram */

twoway hist betaOLS, xline(1) xlab(0.5(0.1)1.5) xtitle("") width(0.01) saving(hist1, replace) title("OLS") graphregion(color(white))
twoway  hist betaIV, xline(1) xlab(0.5(0.1)1.5) xtitle("") width(0.01) saving(hist2, replace) title("IV") graphregion(color(white))
twoway  hist betaFD, xline(1) xlab(0.5(0.1)1.5) xtitle("") width(0.01) saving(hist3, replace) title("FD") graphregion(color(white))

twoway  hist betaFDIV, xline(1) xlab(0.0(0.5)2.5) xtitle("") width(0.01) saving(hist4, replace) title("FDIV") graphregion(color(white))

graph combine hist1.gph hist2.gph hist3.gph hist4.gph, col(2) row(2)   graphregion(color(white))
graph export $pathout\hist.png, replace
 

