clear all 
set more off
cls 
cd "/Users/Japee/Documents/University/4. Sem/Øko I/Afleveringer/HO1"
use "kommune.dta"

summarize

//Opgave 2 - Opstiller modellen. 
gen ltaxrev = log(taxrev)
gen ltaxrate = log(taxrate)
