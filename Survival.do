* This is a model for survival analysis : fsum, univar, unitab
webuse cancer, clear
describe
* Déclaration des données
stset studytim , failure(died) 
/*
studytim: temps de traitement des patients avant décès
survenance du décès = 1
*/
describe _* // Les variables générées crée des va_st _d _t _t0
* Statistiques 
stsum, by(drug)

ltable studytime died, survival // défautes
ltable studytime died, failure
ltable studytime died, hazard
ltable studytime died, graph notable
