 cd "/Users/Japee/Desktop/data"
 import excel "NYSEdata.xlsx", sheet("Sheet1") firstrow clear
*Opg 7.1 
gen y = 0.1*CitiGroup + 0.25*CocaCola + 0.35*Universal + 0.3*WaltDisney
sum y, detail 
sum CitiGroup, detail
sum CocaCola, detail 
sum Universal, detail 
sum WaltDisney, detail 
xtile y_pct=y, n(100)
*Opg 7.3
*Opg 7.4 
gen x =1*NYSEComposite
sum x, detail
*Opg 7.5 
sort y
g alpha = (_n-1)/(_N-1)
sum y if alpha<.1
sum y if y_pct/100==.1
scalar VaR1 = r(max)
sum y if y_pct/100==.05
scalar VaR05 = r(max)
sum y if y_pct/100==.01
scalar VaR01 = r(max)
disp "VaR_0.1=" VaR1 " VaR_0.05=" VaR05 " VaR_0.01=" VaR01
*Opg 7.6
sum x, detail
