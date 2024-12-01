clear all

cd "C:\Users\zpn160\Dropbox\Econometrics I\Eksamen\2020"

use exam2020

global x nord alder kvinde
global dx dalder dkvinde

label variable besk_ejkomp "Besk, ejkomp"
label variable besk_komp "Besk, komp"
label variable robot "Robot"
label variable nord "Nord"
label variable alder "Alder"
label variable kvinde "Kvinde"

********************************************************************************
* Spm. 1.1                                                                     *
********************************************************************************

eststo clear
forvalues ii=1995(10)2015 {
 eststo destab`ii': qui estpost sum besk_ejkomp besk_komp robot nord alder kvinde if aar==`ii' 
}
estout destab1995 destab2005 destab2015 using spm1_1.txt, cells("mean(fmt(3)) sd(fmt(3)) ") ///
	stats(N, fmt(0) labels(" No. obs")) label  mlabels("1995" "2005" "2015" "All") ///
	style(tex) replace

********************************************************************************
* Spm. 1.2                                                                     *
********************************************************************************

preserve
collapse (sum) besk_ejkomp (sum) besk_komp, by(aar)
replace besk_ejkomp=besk_ejkomp/1e6
replace besk_komp=besk_komp/1e6
list
graph twoway (connected besk_ejkomp aar) (connected besk_komp aar), ytitle("Mio. personer") name(binscatterp, replace)
restore
graph export spm1_2.png, replace

********************************************************************************
* Spm. 2.1                                                                     *
********************************************************************************

gen aar1995=(aar==1995)
gen aar2005=(aar==2005)
gen logbesk_ejkomp=log(besk_ejkomp)
gen logbesk_komp=log(besk_komp)


eststo clear

reg logbesk_ejkomp robot $x aar1995 aar2005, robust
eststo e2, title("Ejkomp. udd, multipel")
test robot
reg logbesk_komp robot $x aar1995 aar2005, robust
eststo k2, title("Komp. udd, multipel")
test robot=0

********************************************************************************
* Spm. 2.2                                                                     *
********************************************************************************

reg logbesk_ejkomp robot, robust
eststo e1, title("Ejkomp. udd, simpel")
reg logbesk_komp robot, robust
eststo k1, title("Komp. udd, simpel")
test robot=0

estout using spm2_1.txt,cells("b(fmt(3) star)" "se(par fmt(3))"  ) ///
   label varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels("Obs" "Rsq" )) ///
   style(tex) replace  

reg logbesk_ejkomp robot $x aar1995 aar2005, robust
test nord=alder=kvinde=aar1995=aar2005=0
reg logbesk_komp robot $x aar1995 aar2005, robust   
test nord=alder=kvinde=aar1995=aar2005=0   
********************************************************************************
* Spm. 2.3                                                                     *
********************************************************************************

reg logbesk_ejkomp robot $x aar1995 aar2005
predict logbesk_ejkomphat, xb
estat hettest, rhs iid
gen u_ejkomphat2=(logbesk_ejkomp-logbesk_ejkomphat)^2
graph twoway scatter u_ejkomphat2 robot, name(fige1)
graph twoway scatter u_ejkomphat2 nord, name(fige2)
graph twoway scatter u_ejkomphat2 alder, name(fige3)
graph twoway scatter u_ejkomphat2 kvinde, name(fige4)
graph twoway scatter u_ejkomphat2 aar1995, name(fige5)
graph twoway scatter u_ejkomphat2 aar2005, name(fige6)

graph combine fige1 fige2 fige3 fige4 fige5 fige6
graph export spm2_3e.png, replace

reg logbesk_komp robot $x aar1995 aar2005
predict logbesk_komphat, xb
gen u_komphat2=(logbesk_komp-logbesk_komphat)^2
estat hettest, rhs iid
graph twoway scatter u_komphat2 robot, name(figk1)
graph twoway scatter u_komphat2 nord, name(figk2)
graph twoway scatter u_komphat2 alder, name(figk3)
graph twoway scatter u_komphat2 kvinde, name(figk4)
graph twoway scatter u_komphat2 aar1995, name(figk5)
graph twoway scatter u_komphat2 aar2005, name(figk6)

graph combine figk1 figk2 figk3 figk4 figk5 figk6
graph export spm2_3k.png, replace

graph drop fige1 fige2 fige3 fige4 fige5 fige6 figk1 figk2 figk3 figk4 figk5 figk6

*reg u_ejkomphat2 robot $x aar1995 aar2005
*reg u_komphat2 robot $x aar1995 aar2005

********************************************************************************
* Spm. 3.1                                                                     *
********************************************************************************

eststo clear

gen t=1*(aar==1995)+2*(aar==2005)+3*(aar==2015)
xtset region t
gen dlogbesk_ejkomp=d.logbesk_ejkomp
gen dlogbesk_komp=d.logbesk_komp
gen drobot=d.robot
gen dalder=d.alder
gen dkvinde=d.kvinde

label variable drobot "Delta Robot"
label variable dalder "Delta Alder"
label variable dkvinde "Delta Kvinde"

reg dlogbesk_ejkomp drobot $dx aar2005, robust
eststo spm3_1e, title("Spm 3.1, ejkomp.")
reg dlogbesk_komp drobot $dx aar2005, robust
eststo spm3_1k, title("Spm 3.1, komp.")

********************************************************************************
* Spm. 3.2                                                                     *
********************************************************************************

forvalues ii=1/8 {
	gen sg_`ii'=branche`ii'*udlandrobot`ii'
}

egen shiftshare=rowtotal(sg_*)

reg drobot shiftshare $dx aar2005, robust
eststo spm3_2f, title("Spm 3.2, first stage")
ivregress 2sls dlogbesk_ejkomp $dx aar2005 (drobot=shiftshare), robust
eststo spm3_2e, title("Spm 3.2, ejkomp.")
ivregress 2sls dlogbesk_komp $dx aar2005 (drobot=shiftshare), robust
eststo spm3_2k, title("Spm 3.2, komp.")
*ivregress 2sls dlogbesk_ejkomp $x aar2005 (drobot=s_*)

estout using spm3_12.txt,cells("b(fmt(3) star)" "se(par fmt(3))"  ) ///
   label varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels("Obs" "Rsq" )) ///
   style(tex) replace   
   
********************************************************************************
* Spm. 3.3                                                                     *
********************************************************************************

eststo clear

reg drobot shiftshare $dx aar2005, robust
predict drobothat, xb
gen epshat=drobot-drobothat
reg dlogbesk_ejkomp $dx aar2005 drobot epshat, robust
eststo spm3_3e, title("Spm 3.3, ejkomp.")
reg dlogbesk_komp $dx aar2005 drobot epshat, robust
eststo spm3_3k, title("Spm 3.3, komp.")

estout using spm3_3.txt,cells("b(fmt(3) star)" "se(par fmt(3))"  ) ///
   label varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels("Obs" "Rsq" )) ///
   style(tex) replace

********************************************************************************
* Spm. 5.1+5.2                                                                 *
********************************************************************************  
   
clear all

global N=1000
set seed 117

program shiftshare, rclass
	drop _all
	
	*SET NUMBER OF CURRENT OBSERVATIONS 
	set obs $N
	
	*DATA GENERATING PROCESS
	forvalues j=1/$J {
		gen q`j'=runiform()
	}
	egen naevner=rowtotal(q*)
	forvalues j=1/$J {
		gen s`j'=q`j'/naevner
	}
	forvalues j=1/$J {
		gen g`j'=`j'/$J
		gen sg`j'=s`j'*g`j'
	}
	egen z=rowtotal(sg*)
	drop sg*
	gen u=rnormal()
	gen x=1+1.5*z+0.2*u
	gen y=1+2*x+u

	reg y x
	return scalar ols=_b[x]
	ivregress 2sls y (x=z), first robust
	return scalar iv1=_b[x]
	ivregress 2sls y (x=s*), first robust
	return scalar iv2=_b[x]
end

global J=2

simulate ols=r(ols) iv1=r(iv1) iv2=r(iv2), ///
		 seed(117) reps(500) dots:shiftshare

label variable ols "OLS"
label variable iv1 "IV shift-share"
label variable iv2 "IV shares"
		 
eststo clear
eststo destab$J: qui estpost sum ols iv1 iv2
graph twoway hist ols, legend(label(1 "OLS")) blcolor(red) bfcolor(red) ///
          || hist iv1, legend(label(2 "IV shift-share")) blcolor(blue) bfcolor(blue) ///
          || hist iv2, legend(label(3 "IV shares")) blcolor(green) bfcolor(green)  xline(2)
graph export spm5_J${J}.png, replace

********************************************************************************
* Spm. 5.3                                                                     *
********************************************************************************

global J=5

simulate ols=r(ols) iv1=r(iv1) iv2=r(iv2), ///
		 seed(117) reps(500) dots:shiftshare

label variable ols "OLS"
label variable iv1 "IV shift-share"
label variable iv2 "IV shares"		 
		 
eststo destab$J: qui estpost sum ols iv1 iv2
graph twoway hist ols, legend(label(1 "OLS")) blcolor(red) bfcolor(red) ///
          || hist iv1, legend(label(2 "IV shift-share")) blcolor(blue) bfcolor(blue) ///
          || hist iv2, legend(label(3 "IV shares")) blcolor(green) bfcolor(green) xline(2) name(spm5_5)
graph export spm5_J${J}.png, replace

estout destab2 destab5 using spm5_123.txt, cells("mean(fmt(3)) sd(fmt(3)) ") ///
	stats(N, fmt(0) labels(" No. simulations")) label  mlabels("2 brancher" "5 brancher") ///
	style(tex) replace
