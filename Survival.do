* This is a model for survival analysis : fsum, univar, unitab
webuse cancer, clear
describe
* Déclaration des données
stset studytim , failure(died) 
/*
studytim: temps de traitement des patients avant décès
survenance du décès = 1
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
