/*******************************************************************************
********************************* UGESEDDEL 3 **********************************
*******************************************************************************/
clear all
cd " " /* Indsæt din egen sti */


*SPØRGSMÅL 1: Indlæs data
use pwt.dta

describe
summarize


*SPØRGSMÅL 2: Fjern observationer med dårlig datakvalitet
summarize if grade == "D"

drop if grade == "D"


*SPØRGSMÅL 3: Dan figur (a)
generate lny60=ln(y60)

graph twoway (scatter gy lny60 ), ytitle("Vækst i BNP pr. capita, 1960-2003") xtitle("log(BNP pr. capita) i 1960") name(figur_a, replace)
graph export figur_a.png, replace

*Med linært fit:
graph twoway (scatter gy lny60) (lfit gy lny60), name(figur_a_fit, replace)


*SPØRGSMÅL 4: Estimer simpel regressionsmodel
regress gy lny60


*SPØRGSMÅL 5: Specificer absolut indkomst og estimér modellen igen 
generate lny60abs=ln(y60*31691)
regress gy lny60abs


*SPØRGSMÅL 7: Estimer multipel regressionsmodel
generate struc=ln(sk)-ln(n+0.075)
regress gy lny60 struc


*SPØRGSMÅL 8: Udeladt variabelbias

* Beregn bias med hjælp fra formel:
correlate lny60 struc, covariance
correlate lny60 struc

display sqrt(1.12775)

display sqrt(.399489)


display .0156729*0.5324*(.6320516/1.061958)
display .0156729*(.35737/1.12775)

* Forskel på estimater af beta_1:
display - .0005696 +.0055361
