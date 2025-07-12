* This is a model for survival analysis : fsum, univar, unitab
webuse cancer, clear
describe
* Déclaration des données
stset studytim , failure(died) 
/*
studytim: temps de traitement des patients avant décès
survenance du décè
*/
describe _* // Les variables générées _st _d _t _t0

* Statistiques des patients
stsum, by(drug)

*--------------------------- Estimation des fonctions Hazard et de survie
* Tables de survie
ltable studytime died, survival // par défaut
ltable studytime died, failure
ltable studytime died, hazard
ltable studytime died, graph notable

* Table de fonction de survie 
sts list, survival
sts list, failure
sts list, hazard
sts list, by(drug) compare

* Graph des fonctions de survie 
sts graph, survival
sts graph, cumhaz
sts graph, na // idem que precedemment
sts graph, by(drug)

* Test 
sts test drug, logrank
sts test drug, wilcoxon

* Création de variables
sts generate survie = s // Kalpan Meier Survival function
sts generate failure = f // Kalpan Meier Failure function
sts generate hazard = h // Hazard component = risque
sts generate cumhg = na, by(drug) // Nelson Aalen Cumulative Hazard function

*--------------------------- Modèle paramétric et de cox en temps continue
streg drug age, distribution(weibull) nolog nohr //no hazard ratios
stcurv, hazard at(sex=(0 1) age=50) kernel(gauss) yscale(log) range(1 39)
stcox drug age, nohr base(s0) basech(ch0)
stcox, hr

*--------------------------- Modèle à temps discret
/* Fonctions hazard et de survie: méthode de Kaplan-Meier product-limit et table de vie */
generate ID = _n
label variable ID "Identifiant de la variable"
* Reconnder la variable drug
codebook drug
recode drug 1=0 2/3=1  
label define drug 0 placebo 1 drug
label values drug drug
expand studytim
bysort id: generate j = _n
lab var j "Les mois écoulés"
bysort id: generate dead = died==1 & _n==_N
label variable dead "Variable binaire pour le modèle de risque discret"
