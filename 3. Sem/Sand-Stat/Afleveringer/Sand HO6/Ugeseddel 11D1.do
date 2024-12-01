clear all 
set obs 50000
set seed 3500
gen y = 5 + rnormal()
mean y if _n<=100
mean y if _n<=500
mean y if _n<=1000
mean y if _n<=5000
mean y if _n<=10000
mean y if _n<=50000
