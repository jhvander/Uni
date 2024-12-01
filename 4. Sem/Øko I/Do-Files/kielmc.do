
clear all

cap cd "C:\undervisning\data"
cap log close


use Kielmc

*LECTURE 24. Eksempel med huspriser og forbrænding.



forvalue i=0/1 {
 forvalue j=0/1 {
 eststo destab`i'`j': qui estpost sum  rprice  age area land rooms baths intst if y81==`i' & nearinc==`j'  
}
}

estout destab00 destab01 , replace cells("mean(fmt(1)) sd(fmt(1)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("1978 far" "1978 near" )
	
	
estout destab10 destab11 , replace cells("mean(fmt(1)) sd(fmt(1)) ") stats(N, fmt(0) labels(" No. obs"))  ///
	label  mlabels("1981 far" "1981 near" )
	
reg rprice nearinc if y81==0  , robust
eststo model78
	
reg rprice nearinc if y81==1, robust
eststo model81

reg rprice y81 nearinc y81nrinc , robust
eststo modelI

gen beta=_b[y81]
gen alpha=_b[nearinc]+_b[_cons]

reg rprice y81 nearinc y81nrinc age agesq , robust
eststo modelII



reg rprice y81 nearinc y81nrinc age agesq  area land rooms baths intst, robust
eststo modelIII

estout model* ,cells("b(fmt(3) star)" "se(par fmt(3))"  ) ////
   label    varlabel(_cons "Constant" ) stats(N r2, fmt(0 3) labels("Obs" "Rsq" )) 


 /* en nem måde at lave grafer på med difference in difference */
 
 binscatter rprice year, by(near)
 
   

  collapse rprice beta alpha, by(year nearinc)
  
  twoway (line rprice year if near==0, lcolor(blue) lwidth(0.8)) (line rprice year if near==1, lcolor(red) lwidth(0.8)), ///
 legend(on order(1 "Langt fra forbrændingsanlæg" 2 "Tæt på forbrændingsanlæg")) xtitle("år") ytitle("prisen i $1978")
 graph export did.eps, replace 
 
 gen hypot=alpha if near==1
 
 replace hypot=alpha+beta  if near==1 & year==1981
 
 
 twoway (line rprice year if near==0, lcolor(blue) lwidth(0.8)) (line rprice year if near==1, lcolor(red) lwidth(0.8)) (line hypot year if near==1, lcolor(red) lwidth(0.5) lp("--")), ///
 legend(on order(1 "Langt fra forbrændingsanlæg" 2 "Tæt på forbrændingsanlæg")) xtitle("år") ytitle("prisen i $1978")
 graph export  did1.eps, replace 
 
