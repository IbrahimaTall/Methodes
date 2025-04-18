*################### Analyse simple des composantyes ######################################################################################
* Similarité et associationn entre deux variables catégoriuelles *
use effectdata.dta, clear
tabulate SITMAT TYPESEM, freq chi2
* dimensions(). The maximum number is min(nr − 1; nc − 1)
ca TYPESEM (mycol: SITMAT EDU), compact plot dimensions(2)
screeplot e(Sv) // Valeur singulière
/* La méthode de normalisation utilisée permet d'interpréter la 
similitude des modalités de ligne et de colonne et la relation 
d'association entre les variables de ligne et de colonne */
ca, norowpoint nocolpoint plot

*####################  Cluster analysis (classification ailleurs = analyse discriminante) #################################################
use effectdata.dta, clear
/*-----------------------------------------------------------------------------------------------------------------------------------------
La classification est une procédure statistique qui permet de regrouper des observations en groupes. 
Elles peut hierarchique ou non suivant la procedure
-----------------------------------------------------------------------------------------------------------------------------------------*/
*-------------------- 1. Classification non hierarchique 
*--------------------- Les moyennes centraux (k-means) 
luster kmeans PROD SEM REV TYPSEM SITMAT, k(5) name(kmeancl) start(krandom(385617)) measure(Gower) keepcenter iterate(10000)
*--------------------- Les médianes centrales (k-medians) 
luster kmedians PROD SEM REV TYPSEM SITMAT, k(5) name(kmediancl) start(krandom(385617)) measure(Gower) keepcenter iterate(10000)
*--------------------  2. Classification hierarchique 
*--------------------- Assamblage simple 
luster simplelinkage PROD SEM REV TYPSEM SITMAT, name(simplelink) measure(L2)
*--------------------- Assamblage moyen 
luster averagelinkage PROD SEM REV TYPSEM SITMAT, name(averagelink) measure(L2)
*--------------------- Assamblage complet 
luster completelinkage PROD SEM REV TYPSEM SITMAT, name(completelink) measure(L2)
*--------------------- Assamblage pondéré 
luster waveragelinkage PROD SEM REV TYPSEM SITMAT, name(waveragelink) measure(L2)
*--------------------- Assamblage médian 
luster medianlinkage PROD SEM REV TYPSEM SITMAT, name(medianlink) measure(L2squared)
*--------------------- Assamblage centré 
luster centroidlinkage PROD SEM REV TYPSEM SITMAT, name(centroidlink) measure(L2squared)
*--------------------- Assamblage de ward 
luster wardslinkage PROD SEM REV TYPSEM SITMAT, name(wardslink) measure(L2squared)
*--------------------  3. Opérations sur les classes 
*-------------------- Les groupes ou classes 
cluster generate group = groups(3/5), name(kmeancl)
cluster dendrogram kmeancl if group1 == 3, cutnumber(4) showcount vertical
*--------------------  4. Utilités sur les procédures 
*--------------------- Les notes sur la méthodes 
cluster notes kmeancl : La mesure de Gower prend en compte les variables continues et discretes
cluster notes kmeancl : Les variables catégorielles n'ont pas besoins du prefixe i.
cluster notes kmediancl : Les médianes centrales
cluster notes kmeancl
cluster notes drop in 2
*-------------------- Les utilités sur les clusters 
cluster dir // La liste des classes existente
cluster list kmeancl, notes type method // Le détail 
cluster rename kmeancl clkmean
cluster use clkmean
cluster drop kmediancl
