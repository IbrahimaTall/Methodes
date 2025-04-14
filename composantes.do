*#### 1. Analyse simple des composantyes ###################################
* Similarité et associationn entre deux variables catégoriuelles *
use effectdata.dta, clear
tabulate SITMAT TYPESEM, freq chi2
* dimensions(). The maximum number is min(nr − 1; nc − 1)
ca TYPESEM (mycol: SITMAT EDU), compact plot dimensions(2)
screeplot e(Sv) // Valeur singulière
/* La méthode de normalisation utilisée permet d'interpréter la 
similitude des modalités de ligne et de colonne et la relation 
d'association entre les variables de ligne et de colonne
*/
ca, norowpoint nocolpoint plot
*#### 2. Cluster analysis (classification ailleurs = analyse discriminante) #
