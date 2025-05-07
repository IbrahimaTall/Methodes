/* Le modèle linéaire est un support pour plusieurs modèles économétriques.
* La compréhension de ce modèle est essentiel en termes de fonctionnement et de conditions de validité.
* Ce tutoriel permet de mettre en pratique le modèle linéaire multiple sur tous ses aspects
* En appliquant les tests paramétriques, les contraintes et la prévision.*/
use effectdata.dta, clear
regress PROD SEM REV AGE MAT CRED
estimates store mymodel
*############## 1. Valeurs inhabituelles ##############################################################
graph matrix PROD SEM REV AGE
scatter PROD SEM, scheme(white_tableau)
set scheme white_tableau
scatter PROD REV
scatter PROD AGE, mlabel(ID)
predict prod_rstd, rstudent
stem prod_rstd
search hilo
sort prod_rstd
summarize prod_rstd
hilo prod_rstd ID if abs(prod_rstd) >= 2
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
predict prod_r, residual
kdensity prod_r, normal
* standardized normal probability (P-P) plot (sensitive to non normality to the middle range of data)
pnorm prod_r
* quantiles of a variable against the quantiles of a normal (sensitive near the tails)
qnorm prod_r
search iqr
iqr prod_r
* Shapiro-Wilk W test for normality
swilk prod_r
*############## 3 Checking Homoscedasticity of Residuals ##############################################
* residuals versus fitted (predicted) values
rvfplot, yline(0)
* IM test
estat imtest
* Breush-pegan test
estat hettest
*############## 4 Checking for Multicollinearity #######################################################
* vif (variance inflation factor) for multicollinearity: VIF and tolerance (1/VIF)
vif
search collin 
collin SEM REV AGE MAT CRED
*############# 5 Checking Linearity ####################################################################
twoway (scatter PROD SEM) (lfit PROD SEM) (lowess PROD SEM)
foreach v of varlist SEM REV AGE MAT CRED {
  acprplot `v', lowess lsopts(bwidth(1))
}
*############## 6 Model Specification ###################################################################
* _hat doit être significative et non pas _hatsq
linktest
* mitted variables test
ovtest
*############# 7 Issues of Independence #################################################################
* dwstat test de correlation pour serie temporelle.
*############# 8 Les catégorielles ######################################################################
* La comparaison par rapport à la modalité de base
regress PROD SEM REV AGE MAT CRED i.SITMAT
regress PROD SEM REV AGE MAT CRED ib(2).SITMAT
regress PROD SEM REV AGE MAT CRED ib(last).SITMAT
* Backward Difference Coding for prior adjacent level.
regress PROD SEM REV AGE MAT CRED b.SITMAT
* Helmert Coding for comparing with the sum for the reste
regress PROD SEM REV AGE MAT CRED h.SITMAT
* Reverse Helmert Coding for comparing with the sum for the previous
regress PROD SEM REV AGE MAT CRED r.SITMAT
* Deviation Coding compare for the all levels of the variable
regress PROD SEM REV AGE MAT CRED e.SITMAT
*Orthogonal Polynomial Coding for ordinal variable
regress PROD SEM REV AGE MAT CRED o.SITMAT
*User Defined Coding
char race[user] (1 0 -1 0  -.5 1 0 -.5  .5 .5 -.5 -.5)
regress PROD SEM REV AGE MAT CRED u.SITMAT
