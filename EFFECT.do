* Base de données sur le don de semences agricoles (en Tonnes)
use effectdata.dta, clear
* Description des variables de la base
describe
* Structure des semences reçu par les ménages par région et par campagne
table (REG)(CAMP) if inlist(REG,6,7,8,9,11,12,14) & CAMP > 2021, statistic(mean SEM) nformat(%9.0fc)

*##############################################################################
*################ Double différences ##########################################
* Impact des dons en semences
didregress (PROD PARC MAT CRED AGE i.TYPSEM i.TYPSEM)(SEM, continuous), group(REG) time(CAMP)

* Variable de traitement de type binaire
generate PROG = SEM != 0
label variable PROG "Identification des bénéficiaires"

* Impact des dons en semences
didregress (PROD PARC MAT CRED AGE i.TYPSEM i.TYPSEM)(PROG), group(REG) time(CAMP)

* Diagnostic des tendences parallèles
estat trendplots, title("")
qui graph export grdid1.png, as(png) replace

* Test de tendence parallèles
estat ptrends

* Causalité du programme sur la production
estat granger

* Illustration de la causalité
estat grangerplot
qui graph export grdid2.png, as(png) replace

*###############################################################################
*################ Régression sur discontinuité #################################
* Vérifions que PROG = 1 si REV < 250
assert PROG == (REV < 250)

* Continuité de PROD par rapport à REV à c0 = 250
twoway (scatter PROD REV if !PROG, sort msize(vsmall) msymbol(circle_hollow)) ///
 (scatter PROD REV if PROG, sort mcolor(blue) msize(vsmall) msymbol(circle_hollow)) ///
 (lfit PROD REV if !PROG, lcolor(red) msize(small) lwidth(medthin) lpattern(solid)) ///
 (lfit PROD REV if PROG, lcolor(dknavy) msize(small) lwidth(medthin) lpattern(solid)), ///
 xtitle(Revenu du ménage) xline(250) legend(off) 
graph export rdd.png, as(png) replace

* RDD avec variables explicatives
teffects ra (PROD REV PARC MAT CRED AGE i.SITMAT i.TYPSEM, poisson noconstant)(PROG), atet nolog

quietly {
    * Contrefactuel d'un participant    
    reg PROD REV PARC MAT CRED AGE i.SITMAT i.TYPSEM if !PROG
    predict w1 if PROG
    summarize w1
    local pw1 = r(mean) 
    
    * Production total des participants
    summarize PROD if PROG
    local pwt = r(mean)
}
display as txt "ATET = " as res `pwt' - `pw1'

*###############################################################################
*################## Variables intrumentales ####################################
* Le Model et l'ATET
quietly eregress PROD PARC MAT CRED i.TYPSEM, entreat(PROG = AGE i.SITMAT) vce(robust) nolog
estat teffects, atet

* Estimation par double moindres carrée
ivregress 2sls PROD PARC MAT CRED i.TYPSEM (PROG = AGE i.SITMAT), noheader

* Estimation de l'ATET
margins, dydx(PROG)

*###############################################################################
*####################### Inverse des propensions ###############################
teffects ipw (PROD)(PROG PARC MAT CRED AGE i.SITMAT i.TYPSEM, logit noconstant), atet

* Qualité des propensions
tebalance density AGE, kernel(epanechnikov)
graph export gripw2.png, as(png) replace

* Test de bonne qualité des propensions
tebalance overid, nolog // sauf nnmatch et psmatch

* Support communs
teoverlap, kernel(epanechnikov)
graph export gripw1.png, as(png) replace

*###############################################################################
*######### Méthode augmentée Pondération par inverse des propensions ###########
* Estimation de l'ATE
teffects aipw (PROD PARC MAT CRED i.TYPSEM, poisson noconstant)(PROG AGE i.SITMAT, logit noconstant), ate nolog

* Qualité des propensions sur l'âge
tebalance density AGE, line1opts(lcolor(red)) line2opts(lcolor(yellow))
graph export graipw2w.png, as(png) replace

* Qalité globale
tebalance overid, nolog // sauf nnmatch et psmatch

* Support commun
teoverlap, kernel(epanechnikov) line1opts(lcolor(red)) line2opts(lcolor(yellow))
graph export graipw1.png, as(png) replace

*###############################################################################
*###### Pondération par inverse des propensions et régression augmentée ########
* Esimation de l'éffet moyen
teffects ipwra (PROD PARC MAT CRED, poisson noconstant)(PROG AGE i.TYPSEM i.TYPSEM, logit noconstant), atet nolog

* Qualité des propensions
tebalance density AGE, line1opts(lcolor(red)) line2opts(lcolor(green))
graph export gripwra2.png, as(png) replace

* Qualité globale
tebalance overid, nolog // sauf nnmatch et psmatch

* Support commun
teoverlap, kernel(epanechnikov) line1opts(lcolor(red)) line2opts(lcolor(green))
graph export gripwra1.png, as(png) replace

*###############################################################################
*################## Plus Proche voisin #########################################
teffects nnmatch (PROD PARC MAT CRED AGE i.TYPSEM i.TYPSEM)(PROG), nneighbor(5) atet

tebalance density AGE, line1opts(lcolor(blue)) line2opts(lcolor(green))
graph export grnnmatch1.png, as(png) replace

tebalance box AGE, box(1, color(blue)) box(2, color(green)) // Uniquement nnmatch et psmatch
graph export grnnmatch2w.png, as(png) replace

*###############################################################################
*##################### Score de propensions ####################################
* ATET par le score de propension
teffects psmatch (PROD) (PROG PARC MAT CRED AGE i.TYPSEM i.TYPSEM, logit), nneighbor(5) atet

* Qualité de l'appariement sur l'âge
tebalance box AGE, box(1, color(blue)) box(2, color(yellow))
graph export grpsmatch3.png, as(png) replace

* Qualité de l'appariement
tebalance density, line1opts(lcolor(blue)) line2opts(lcolor(yellow))
graph export grpsmatch2w.png, as(png) replace

* Spport commun
teoverlap, kernel(epanechnikov) line1opts(lcolor(blue)) line2opts(lcolor(yellow))
graph export grpsmatch1.png, as(png) replace
