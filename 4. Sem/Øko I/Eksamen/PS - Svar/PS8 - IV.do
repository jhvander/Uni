/*******************************************************************************
********************************* UGESEDDEL 8 **********************************
*******************************************************************************/
clear all
cd "" /* Indsæt din egen sti */

*Indlæs data
use AngristEvans.dta


*SPØRGSMÅL 1: Deskriptiv statistik
bysort samesex: su
quietly: bysort samesex: outreg2 using deskriptiv, sum(log) eqkeep(N mean) replace excel /* Excel-format */
quietly: bysort samesex: outreg2 using deskriptiv, sum(log) eqkeep(N mean) replace /* Latex-format */


*SPØRGSMÅL 2: Estimation af model (1) med OLS
regress workm morekids boy1stkid boy2ndkid agem agem1stkid black hisp other, robust
outreg2 using ols, replace excel
outreg2 using ols, replace tex
 

*SPØRGSMÅL 3: Estimation af model (1) med IV
ivregress 2sls workm (morekids=samesex) boy1stkid boy2ndkid agem agem1stkid black hisp other, robust
outreg2 using iv, replace excel
outreg2 using iv, replace tex

* Er samesex et relevant instrument?
regress morekids samesex boy1stkid boy2ndkid agem agem1stkid black hisp other, robust


*SPØRGSMÅL 4+5: Estimation af model (1) med to instrumenter og OI-test
ivregress 2sls workm (morekids=twoboys twogirls) boy1stkid agem agem1stkid black hisp other, robust
predict workm_uhat, residual

regress workm_uhat twoboys twogirls boy1stkid agem agem1stkid black hisp other
gen oiworkm=e(N)*e(r2)

outreg2 using oi_test, replace addstat("OI test", oiworkm) excel
outreg2 using oi_test, replace addstat("OI test", oiworkm) tex


*SPØRGSMÅL 6: Lav spørgsmål 2 og 3 igen med fire mål for arbejdsudbud
* Spørgsmål 2:
gen lfaminc = log(faminc)
foreach x in weekm hourm lincm lfaminc {
regress `x' morekids boy1stkid boy2ndkid agem agem1stkid black hisp other, robust
outreg2 using ols, append tex
}

* Spørgsmål 3: 
foreach x in weekm hourm lincm lfaminc {
ivregress 2sls `x' (morekids=samesex) boy1stkid boy2ndkid agem agem1stkid black hisp other, robust
outreg2 using iv, append tex
}


* Hvis I vil lave spørgsmål 4 og 5 med fire mål for arbejdsudbud
foreach x in weekm hourm lincm lfaminc {
quietly: ivregress 2sls `x' (morekids=twoboys twogirls) boy1stkid agem agem1stkid black hisp other
predict `x'_uhat, residual

quietly: regress `x'_uhat twoboys twogirls boy1stkid agem agem1stkid black hisp other
gen oi`x' = e(N)*e(r2)
}

* Lav tabel med regressionsoutput og OI-teststørrelse
foreach x in weekm hourm lincm lfaminc {
ivregress 2sls `x' (morekids=twoboys twogirls) boy1stkid agem agem1stkid black hisp other, robust
outreg2 using oi_test, append addstat("OI test", oi`x') tex
}


*TEORIOPGAVE: IV estimation i mata
drop if lfaminc==. /* Mata kan ikke anvende missing-værdier */

* Kun med workm som y-variabel
mata 
// Input data //
y = st_data(.,"workm")

x = st_data(.,"morekids boy1stkid boy2ndkid agem agem1stkid black hisp other")

morekids 	= st_data(.,"morekids")
boy1stkid  	= st_data(.,"boy1stkid")
boy2ndkid  	= st_data(.,"boy2ndkid")
agem  		= st_data(.,"agem")
agem1stkid  = st_data(.,"agem1stkid")
black  		= st_data(.,"black")
hisp  		= st_data(.,"hisp")
other 		= st_data(.,"other")

samesex = st_data(.,"samesex")

// Definer konstant, X og Y matrix//
cons = J(rows(morekids),1,1)

X = (cons,x) 
Z = (cons,samesex,boy1stkid,boy2ndkid,agem,agem1stkid,black,hisp,other)


// OLS estimater //
beta_ols=(invsym(X'*X))*(X'*y)

// IV estimater //
beta_iv_general= qrinv((X'*Z)*invsym(Z'*Z)*(Z'*X))*(X'*Z)*invsym(Z'*Z)*(Z'*y)
beta_iv_simple = qrinv(Z'*X)*(Z'*y)

// Print resultater //
(beta_ols) 
(beta_iv_general) 
(beta_iv_simple)
end


* Med alle fem mål for arbejdsudbud
mata 
// Input data //
y = st_data(.,"workm weekm hourm lincm lfaminc")

x = st_data(.,"morekids boy1stkid boy2ndkid agem agem1stkid black hisp other")

morekids 	= st_data(.,"morekids")
boy1stkid  	= st_data(.,"boy1stkid")
boy2ndkid  	= st_data(.,"boy2ndkid")
agem  		= st_data(.,"agem")
agem1stkid  = st_data(.,"agem1stkid")
black  		= st_data(.,"black")
hisp  		= st_data(.,"hisp")
other 		= st_data(.,"other")

samesex = st_data(.,"samesex")

// Definer konstant, X og Y matrix//
cons = J(rows(morekids),1,1)

X = (cons,x) 
Z = (cons,samesex,boy1stkid,boy2ndkid,agem,agem1stkid,black,hisp,other)


// OLS estimater //
beta_ols=(invsym(X'*X))*(X'*y)

// IV estimater //
beta_iv_general= qrinv((X'*Z)*invsym(Z'*Z)*(Z'*X))*(X'*Z)*invsym(Z'*Z)*(Z'*y)
beta_iv_simple = qrinv(Z'*X)*(Z'*y)

// Print resultater //
(beta_ols) 
(beta_iv_general) 
(beta_iv_simple)
end
