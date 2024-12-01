/*******************************************************************************
********************************* UGESEDDEL 5 **********************************
*******************************************************************************/
clear all
cd "" /* Indsæt din egen sti */

*SPØRGSMÅL 1: Indlæs data
use pwt.dta

drop if grade=="D"

list country if sh==.
drop if sh==.

generate lny60=ln(y60)
generate strucK=log(sk)-log(n+0.075)
generate strucH=log(sh)-log(n+0.075)

summarize 


*SPØRGSMÅL 2: Estimer den udvidede Solowmodel (1)
regress gy lny60 strucK strucH

* Den multiple regressionsmodel fra spm. 7 i ugeseddel 3:
regress gy lny60 strucK


*SPØRGSMÅL 3: Modellens samlede signifikans
display invFtail(3,73,0.05)


*SPØRGSMÅL 4: De individuelle forklarende variables signifikans
display invnormal(0.025)
display invnormal(0.975)

display invttail(77,0.025)


*SPØRGSMÅL 5: En-sidet t-test
display invnormal(0.05)
display invnormal(0.95)

display invttail(77,0.95)


*SPØRGSMÅL 6: F-test af de strukturelle karakteristika

* i: Manuel udregning af F-teststørrelse 
regress gy lny60
generate SSR_r=e(rss)

regress gy lny60 strucK strucH
generate SSR_ur=e(rss)

generate Ftest=((SSR_r-SSR_ur)/2)/(SSR_ur/(77-3-1))
su Ftest

display invFtail(2,73,0.05)


* ii: Med STATA
regress gy lny60 strucK strucH
test strucK strucH

display invFtail(2,73,0.05)


*SPØRGSMÅL 7: Estimation i mata

mata 
// ii.
y = st_data(.,"gy")
x = st_data(.,"lny60 strucK strucH")
x

// iii.
cons = J(rows(x),1,1)

// iv.
X = (x,cons)
X

// v.
beta_hat=(invsym(X'*X))*(X'*y)

// vi.
u_hat=y-X*beta_hat
s2=(1/(rows(X)-cols(X)))*(u_hat'*u_hat)
V_ols=s2*invsym(X'*X)
se_ols=sqrt(diagonal(V_ols))

// vii.
ttest=beta_hat:/se_ols

// RESULTATER //
(beta_hat, se_ols, ttest)
end




