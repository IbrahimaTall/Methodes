/*##############################################################################
###### Ibrahima TALL, ingénieur statisticien économiste ########################
################################################################################
## Plan de travail:                                                         ####
##	1. Préparation de la base de l'EHCVM                                ####
##	2. Préparation de la base du recensement                            ####
##	3. Test d'égalité de distribution des variables explicatives        ####
##	4. Calcul de la pauvreté au sens de l'EHCVM                         ####
##	5. Estimation de la pauvreté avec sae                               ####
##	6. Cartographie des résultats                                       ####
##	7. Considérant la base de recensement comme un sondage              ####
##############################################################################*/

cd "C:/Users/IBRAHIMA TALL/Documents/PERSONNAL/Pauvrete/SAE TALL"
clear

*-------------------------------------------------------------------------------
*------------- 1. Préparation de la base de l'EHCVM ----------------------------
*-------------------------------------------------------------------------------
* Chargement de la base individus
use ehcvm_individu_SEN2018, clear

* Prise en compte du département
quietly {
    keep hhid region departement milieu
    duplicates drop hhid, force
}

* Fusion avec la base welfare portant sur l'analyse de la Pauvreté
merge 1:1 hhid using ehcvm_welfare_SEN2018, nogenerate nolabel ///
 keepusing(grappe hhweight hhsize zref pcexp)

* Fusion avec la base menage portant sur l'analyse de la Pauvreté
merge 1:1 hhid using ehcvm_menage_SEN2018, nogenerate nolabel ///
 keepusing(logem mur toit sol toilet elec_ac cuisin tv frigo ordin fer car)

* Définition de la Variable indiquant la pauvreté
label define pauv 0 "Non Pauvre" 1 Pauvre
generate pauv:pauv = pcexp < zref
label variable pauv "Indicatrice de pauvreté"

* Calcul du poids des individus et total population
global ndr = 17164 // Nombre total de DR
quietly {
    generate poids = hhweight * hhsize
    total poids
    global TOT = r(table)[1,1]
    generate pop = $TOT
    generate ndr = $ndr
}

* Le code : 1rrDdmmmm
generate menid = (1000 + departement) * 10000 + _n, after(hhid)
format menid %8.0f
generate depid = 1000 + departement, after(menid)

