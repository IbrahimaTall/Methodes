*####################  Cluster analysis (classification ailleurs = analyse discriminante) ##################################################
use effectdata.dta, clear
/*------------------------------------------------------------------------
La classification est une procédure statistique qui permet de regrouper des observations en groupes. Elles peut hierarchique ou non suivant
la procedure
*/
*#################### 1. Classification non hierarchique ###################################################################################
* Les moyennes centraux (k-means) et les médianes centraux (k-medians) *
luster kmeans PROD SEM REV TYPSEM SITMAT, k(5) name(macl1) start(krandom(385617)) measure(Gower) keepcenter iterate(10000) //generate(group)
luster kmedians PROD SEM REV TYPSEM SITMAT, k(5) name(macl2) start(krandom(385617)) measure(Gower) keepcenter iterate(10000) //generate(group)
cluster generate group = groups(3/5), name(macl)
cluster dendrogram macl if group1 == 3, cutnumber(4) showcount vertical
