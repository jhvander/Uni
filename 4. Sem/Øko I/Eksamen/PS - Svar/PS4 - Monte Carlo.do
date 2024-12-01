/*******************************************************************************
********************************* UGESEDDEL 4 **********************************
*******************************************************************************/
clear all

*STATA-PROGRAM TIL MONTE CAROLO EKSPERIMENT

program olsdata, rclass
	drop _all
	
	*SÆT ANTALLET AF OBSERVATIONER 
	set obs 50
	
	gen rho = 0.5
	gen beta0 = 1
	gen beta1 = 2
	gen beta2 = -3
	
	*DATAGENERERENDE PROCES
	generate x1 = 25+5*rnormal()
	generate u = -50 + 100*runiform()
	generate x2 = rho*x1+(10+20*runiform())
	generate y = beta0+beta1*x1+beta2*x2+u
	
	*ESTIMER OLS ESTIMATER
	regress y x1
	return scalar b1_slr=_b[x1]
	regress y x1 x2
	return scalar b1_mlr=_b[x1]
end

*KØR PROGRAM ÉN GANG
olsdata

*SIMULER PROGRAM 1000 GANGE
simulate betahat_slr=r(b1_slr) betahat_mlr=r(b1_mlr), seed(1479) reps(10000) nodots:olsdata

summarize

*EKSTRA OPGAVE: Lav histogrammer
twoway (hist betahat_slr, color(navy)) (hist betahat_mlr, color(gs10)),  legend (row(1) lab(1 "SLR") lab(2 "MLR"))

twoway (hist betahat_slr, color(navy)) (hist betahat_mlr, color(gs10)), name(plot, replace) xtitle("β_1") legend (row(1) lab(1 "SLR") lab(2 "MLR"))
*graph export spm2.png, replace

