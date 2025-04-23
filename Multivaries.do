/* Les Méthodes abordées ici sont:
  1. Analyse des correspondances
    i.  Correspndance simple
    ii. Correspondance multiples
  2. Analyse factorielle (Factor analysis)
  3. Analyse des composantes principales
  4. Analyse discriminantes
  5. Classification (cluster analysis)
*/
use effectdata.dta, clear
*################### 1. Analyse des composantyes ######################################################################################
*------------- i. Analyse simple des correspondances: Similarité et associationn entre deux variables catégoriuelles *
tabulate SITMAT TYPSEM, freq chi2
* dimensions(). The maximum number is min(nr − 1; nc − 1)
ca TYPSEM (mycol: SITMAT EDU), compact plot dimensions(2)
screeplot e(Sv) // Valeur singulière
/* La méthode de normalisation utilisée permet d'interpréter la 
similitude des modalités de ligne et de colonne et la relation 
d'association entre les variables de ligne et de colonne */
ca, norowpoint nocolpoint plot
*------------- ii. Analyse multiple des correspondances
mca SITMAT TYPSEM EDU, method(burt) supplementary(FORM CRED) dimensions(2) normalize(standard) report(variables) points(SITMAT EDU)
mca SITMAT TYPSEM EDU, method((indicator) supplementary(FORM CRED) dimensions(2) normalize((principal) report(crossed) points(SITMAT EDU)
mca SITMAT TYPSEM EDU, method(((joint) supplementary(FORM CRED) dimensions(2) normalize((principal) report(all) points(SITMAT EDU)
mcaplot SITMAT TYPSEM, overlay origin normalize(standard) dimensions(2 1)
mcaprojection SITMAT TYPSEM, normalize(standard) dimensions(2 1)
estat coordinates SITMAT TYPSEM, normalize(principal) stats
estat subinertia //Méthode Joint seulement
estat summarize, crossed labels
screeplot, mean
*#################### 2. Analyse factorielle (Factor analysis)
*#################### 3. Analyse des composantes principales
*#################### 4. Analyse discriminantes
*##################### Discriminant analysis ###############################################################################################
discrim knn PROD SEM REV, group(TYPSEM) k(3) priors(proportional) ties(nearest) measure(absolute)
estat classtable, class priors(proportional) ties(random) title("Discrimination")
estat errorrate, class priors(proportional) pp(stratified) ties(random) title("Discrimination") //count
estat grsummarize, n(%9.1f) mean(%9.1f) median(%9.1f) sd(%9.1f) cv(%9.1f) semean(%9.1f) min(%9.1f) max(%9.1) transpose
estat list, misclassified classification(noclass) probabilities(loopr) varlist(last) id(varname format(%9.1f)) separator(5)
estat summarize, labels noheader noweights
*#################### 5. Cluster analysis (classification ailleurs = analyse discriminante) #################################################
/*-----------------------------------------------------------------------------------------------------------------------------------------
La classification est une procédure statistique qui permet de regrouper des observations en groupes. 
Elles peut hierarchique ou non suivant la procedure
-----------------------------------------------------------------------------------------------------------------------------------------*/
*-------------------- i. Classification non hierarchique 
cluster kmeans PROD SEM REV TYPSEM SITMAT, k(5) name(kmeancl) start(krandom(385617)) measure(Gower) keepcenter iterate(10000)
cluster kmedians PROD SEM REV TYPSEM SITMAT, k(5) name(kmediancl) start(krandom(385617)) measure(Gower) keepcenter iterate(10000)
*--------------------  ii. Classification hierarchique 
cluster simplelinkage PROD SEM REV TYPSEM SITMAT, name(simplelink) measure(L2)
cluster averagelinkage PROD SEM REV TYPSEM SITMAT, name(averagelink) measure(L2)
cluster completelinkage PROD SEM REV TYPSEM SITMAT, name(completelink) measure(L2)
cluster waveragelinkage PROD SEM REV TYPSEM SITMAT, name(waveragelink) measure(L2)
cluster medianlinkage PROD SEM REV TYPSEM SITMAT, name(medianlink) measure(L2squared)
cluster centroidlinkage PROD SEM REV TYPSEM SITMAT, name(centroidlink) measure(L2squared)
cluster wardslinkage PROD SEM REV TYPSEM SITMAT, name(wardslink) measure(L2squared)
*--------------------  iii. Opérations sur les classes 
cluster generate group = groups(3/5), name(kmeancl)
cluster dendrogram kmeancl if group1 == 3, cutnumber(4) showcount vertical
*--------------------  iv. Utilités sur les procédures 
cluster notes kmeancl : La mesure de Gower prend en compte les variables continues et discretes
cluster notes kmeancl : Les variables catégorielles n'ont pas besoins du prefixe i.
cluster notes kmediancl : Les médianes centrales
cluster notes kmeancl
cluster notes drop in 2
cluster dir // La liste des classes existente
cluster list kmeancl, notes type method // Le détail 
cluster rename kmeancl clkmean
cluster use clkmean
cluster drop kmediancl
