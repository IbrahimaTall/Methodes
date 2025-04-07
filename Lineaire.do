* Le modèle linéaire est un support pour plusieurs modèles économétriques.
* La compréhension de ce modèle est essentiel en termes de fonctionnement et de conditions de validité.
* Ce tutoriel permet de mettre en pratique le modèle linéaire multiple sur tous ses aspects
* En appliquant les tests paramétriques, les contraintes et la prévision.
sysuse auto.dta, clear
* Le modèle
regress price mpg weight foreign
estimates store model
*############## 1. Valeurs inhabituelles ##############################################################
use "C:\Users\IBRAHIMA TALL\Documents\COURS\Regression\effectdata.dta"
regress PROD SEM REV AGE MAT CRED
estimates store mymodel
graph matrix PROD SEM REV AGE
scatter PROD SEM, scheme(white_tableau)
set scheme white_tableau
scatter PROD REV
scatter PROD AGE, mlabel(ID)
predict prod_r, rstudent
stem prod_r
search hilo
sort prod_r
summarize prod_r
hilo prod_r ID if abs(prod_r) >= 2
predict prod_lev, leverage
stem prod_lev
hilo prod_lev ID, show(5) high
* Point with leverage greater than (2k+2)/n should be carefully examined
list ID PROD SEM REV AGE if prod_lev > (2*10+2)/_N
* leverage versus residual squared plot
lvr2plot, mlabel(ID)
* overall measures of influence Cook's D and DFITS 4/n
predict prod_d, cooksd
list ID PROD SEM REV AGE if prod_d > 4/_N
* cut-off point for DFITS is 2*sqrt(k/n)
predict prod_dfit, dfits
list ID PROD SEM REV AGE if abs(prod_dfit) >= 2*sqrt(10/_N)
* Influence individuelles 2*sqrt(n)
dfbeta, stub(df_)
list ID PROD SEM REV AGE if abs(df_1) >= 2/sqrt(_N)
* added-variable plot ou partial-regression plot useful in identifying influential points.
avplot SEM, mlabel(ID)
avplots, mlabel(ID)
*############## 2 Checking Normality of Residuals #####################################################
