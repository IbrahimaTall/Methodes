*####################  Cluster analysis (classification ailleurs = analyse discriminante) ##################################################
use effectdata.dta, clear
/*-----------------------------------------------------------------------------------------------------------------------------------------
La classification est une procédure statistique qui permet de regrouper des observations en groupes. Elles peut hierarchique ou non suivant
la procedure
-----------------------------------------------------------------------------------------------------------------------------------------*/
*#################### 1. Classification non hierarchique ###################################################################################
*--------------------- Les moyennes centraux (k-means) ------------------------------------------------------------------------------------
luster kmeans PROD SEM REV TYPSEM SITMAT, k(5) name(kmeancl) start(krandom(385617)) measure(Gower) keepcenter iterate(10000)
*--------------------- Les médianes centrales (k-medians) ---------------------------------------------------------------------------------
luster kmedians PROD SEM REV TYPSEM SITMAT, k(5) name(kmediancl) start(krandom(385617)) measure(Gower) keepcenter iterate(10000)
*--------------------- Les notes sur la méthodes ------------------------------------------------------------------------------------------
cluster notes kmeancl : La mesure de Gower prend en compte les variables continues et discretes
cluster notes kmeancl : Les variables catégorielles n'ont pas besoins du prefixe i.
cluster notes kmediancl : Les médianes centrales
cluster notes kmeancl
cluster notes drop in 2
*-------------------- Les groupes ou classes ----------------------------------------------------------------------------------------------
cluster generate group = groups(3/5), name(kmeancl)
cluster dendrogram kmeancl if group1 == 3, cutnumber(4) showcount vertical
*-------------------- Les utilités sur les clusters ---------------------------------------------------------------------------------------
