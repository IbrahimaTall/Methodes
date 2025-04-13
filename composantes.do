**** Analyse simple des composantyes *****************************
* Similarité et associationn entre deux variables catégoriuelles *
use effectdata.dta, clear
tabulate SITMAT TYPESEM, freq chi2
* dimensions(). The maximum number is min(nr − 1; nc − 1)
ca TYPESEM (mycol: SITMAT EDU), compact plot dimensions(2)
screeplot e(Sv) // Valeur singulière
