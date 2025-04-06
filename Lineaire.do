* Le modèle linéaire est un support pour plusieurs modèles économétriques.
* La compréhension de ce modèle est essentiel en termes de fonctionnement et de conditions de validité.
* Ce tutoriel permet de mettre en pratique le modèle linéaire multiple sur tous ses aspects
* En appliquant les tests paramétriques, les contraintes et la prévision.
sysuse auto.dta, clear
* Le modèle
regress price mpg weight foreign
estimates store model
*1. VALEURS ABERRANTES
