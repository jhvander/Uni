. clear all

. input y

             y
  1. 1
  2. 0
  3. 1
  4. end

. g y1 = y==1

. g y0 = y==0

. sum y0

    Variable |        Obs        Mean    Std. dev.
>        Min        Max
-------------+------------------------------------
> ---------------------
          y0 |          3    .3333333    .5773503 
>          0          1

. clear all

. input y

             y
  1. 1
  2. 1
  3. 0
  4. 0
  5. 0
  6. 1
  7. 1
  8. 1
  9. 0
 10. 1
 11. 1
 12. 1
 13. 0
 14. 0
 15. 1
 16. 1
 17. 0
 18. end

. g y1 = y==1

. g y0 = y==0

. sum y0

    Variable |        Obs        Mean    Std. dev.
>        Min        Max
-------------+------------------------------------
> ---------------------
          y0 |         17    .4117647    .5072997 
>          0          1

. scalar f0 = r(sum)/_N

. sum y1

    Variable |        Obs        Mean    Std. dev.
>        Min        Max
-------------+------------------------------------
> ---------------------
          y1 |         17    .5882353    .5072997 
>          0          1

. scalar fq = r(sum)/_N

. scalar f1 = r(sum)/_N

. disp "f1="f1 " f0=" f0
f1=.58823529 f0=.41176471

. cumul y0, g(y0_cum)

. cumul y1, g(y1_cum)

. hist y1 
(bin=4, start=0, width=.25)

. hist y0
(bin=4, start=0, width=.25)

. sum y0 y1

    Variable |        Obs        Mean    Std. dev.
>        Min        Max
-------------+------------------------------------
> ---------------------
          y0 |         17    .4117647    .5072997 
>          0          1
          y1 |         17    .5882353    .5072997 
>          0          1

. g y_alt = y+1

. sum y_alt

    Variable |        Obs        Mean    Std. dev.
>        Min        Max
-------------+------------------------------------
> ---------------------
       y_alt |         17    1.588235    .5072997 
>          1          2

. sum y, detail

                              y
---------------------------------------------------
> ----------
      Percentiles      Smallest
 1%            0              0
 5%            0              0
10%            0              0       Obs          
>         17
25%            0              0       Sum of wgt.  
>         17

50%            1                      Mean         
>   .5882353
                        Largest       Std. dev.    
>   .5072997
75%            1              1
90%            1              1       Variance     
>   .2573529
95%            1              1       Skewness     
>  -.3585686
99%            1              1       Kurtosis     
>   1.128571

. clear all

. use "/Users/Japee/Desktop/data/sand_spskema2021.d
> ta"

. use sand_spskema2021,replace

. hist gns_gym, name(hist_gns, replace)
(bin=12, start=4.8, width=.70833333)

. hist gns_gym if (gns_gym>=7 & gns_gym<13), width(
> 1) name(hist_gns, replace)
(bin=6, start=7, width=1)

. sum studietimer, detail 

       Hvor mange timer bruger du ca. i gennemsnit 
> på
                      studier om ugen?
---------------------------------------------------
> ----------
      Percentiles      Smallest
 1%            4              0
 5%           10              4
10%           12              6       Obs          
>        144
25%           25              7       Sum of wgt.  
>        144

50%           35                      Mean         
>    31.8125
                        Largest       Std. dev.    
>   11.77111
75%           40             50
90%           45             50       Variance     
>    138.559
95%           50             55       Skewness     
>  -.6900361
99%           55             55       Kurtosis     
>   2.788538

. hist studietimer, name(studietimer, replace)
(bin=12, start=0, width=4.5833333)

. corr gns_gym studietimer, cov
(obs=144)

             |  gns_gym studie~r
-------------+------------------
     gns_gym |  2.59065
 studietimer |  1.21558  138.559


. corr gns_gym studietimer, cov
(obs=144)

             |  gns_gym studie~r
-------------+------------------
     gns_gym |  2.59065
 studietimer |  1.21558  138.559


. corr gns_gym studietimer,cov
(obs=144)

             |  gns_gym studie~r
-------------+------------------
     gns_gym |  2.59065
 studietimer |  1.21558  138.559


. corr gns_gym studietimer 
(obs=144)

             |  gns_gym studie~r
-------------+------------------
     gns_gym |   1.0000
 studietimer |   0.0642   1.0000


.  corr gns_gym studietimer,sig
option sig not allowed
r(198);

.  pwcorr gns_gym studietimer,sig

             |  gns_gym studie~r
-------------+------------------
     gns_gym |   1.0000 
             |
             |
 studietimer |   0.0642   1.0000 
             |   0.4449
             |

. scatter gns_gym studietimer

. reg gns_gym studietimer, robust 

Linear regression                               Num
> ber of obs     =        144
                                                F(1
> , 142)         =       0.50
                                                Pro
> b > F          =     0.4822
                                                R-s
> quared         =     0.0041
                                                Roo
> t MSE          =     1.6119

---------------------------------------------------
> ---------------------------
             |               Robust
     gns_gym | Coefficient  std. err.      t    P>|
> t|                                               
>        [95% con                                  
>                f. interval]
-------------+-------------------------------------
> ---------------------------
 studietimer |    .008773   .0124502     0.70   0.4
> 82                                               
>       -.0158388                                  
>                    .0333848
       _cons |    9.60934   .4345543    22.11   0.0
> 00                                               
>        8.750308                                  
>                    10.46837
---------------------------------------------------
> ---------------------------

