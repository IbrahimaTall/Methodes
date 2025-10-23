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
\\\\\\\\\\\\\\\\\\\\\\\\\
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

* Déclaration du plan de sondage de l'EHCVM
svyset grappe, strata(milieu) fpc(ndr) || _n [pw = poids], fpc(pop)

* Données d'enquête EHCVM 2018
save mysurvey, replace

*-------------------------------------------------------------------------------
*------------- 2. Préparation de la base du recensement ------------------------
*-------------------------------------------------------------------------------
* Importation de la base RGPHAE 2013 (partie Habitat)
import spss using "spss_habitat_10eme_dr v2.sav", clear
* Identification des variables explicatives
rename (A01 A02 E13_2 E13_4 E13_12 E13_16 E14_1)(region departement tv ///
 frigo ordin fer car)

quietly{
    recode E03 (1 2 = 1)(3 4 5 = 2)(6 7 8 = 3), generate(logem)
    generate mur = E05 > 5
    generate toit = inlist(E06, 1,2,3)
    generate sol = inlist(E07, 1,2,5,6,7)
    generate toilet = E08 < 22
    generate elec_ac = E11 == 1
    generate cuisin = inlist(E12, 3, 4)
}

* Identification des départements et des ménages
keep region departement logem mur toit sol toilet elec_ac cuisin tv ///
 frigo ordin fer car
replace departement = 10 * region + departement if departement < 10

* Le code du ménage : 1rrDmmmm
generate menid = (1000 + departement) * 10000 + _n, before(region) 
format menid %8.0f

* Le code du département : 1rrD
generate depid = 1000 + departement, after(menid) 

* Déclaration du plan de sondage de l'EHCVM
svyset grappe, strata(milieu) fpc(ndr) || _n [pw = poids], fpc(pop)

* Données d'enquête EHCVM 2018
save mysurvey, replace

* Total par département dans la base EHCVM
quietly {
    generate un = 1
    collect clear
    collect create deptabEHCVM
    collect: svy: total un, over(departement)
    collect style cell, nformat(%5.2f)
    collect style showbase off
    collect layout (colname) (result)
}

*-------------------------------------------------------------------------------
*------------- 2. Préparation de la base du recensement ------------------------
*-------------------------------------------------------------------------------
* Importation de la base RGPHAE 2013 (partie Habitat)
import spss using "spss_habitat_10eme_dr v2.sav", clear

* Identification des variables explicatives
rename (A01 A02 E13_2 E13_4 E13_12 E13_16 E14_1)(region departement tv ///
 frigo ordin fer car)

* Organisation des modalités
quietly{
    recode E03 (1 2 = 1)(3 4 5 = 2)(6 7 8 = 3), generate(logem)
    generate mur = E05 > 5
    generate toit = inlist(E06, 1,2,3)
    generate sol = inlist(E07, 1,2,5,6,7)
    generate toilet = E08 < 22
    generate elec_ac = E11 == 1
    generate cuisin = inlist(E12, 3, 4)
}

* Identification des départements et des ménages
keep region departement logem mur toit sol toilet elec_ac cuisin tv ///
 frigo ordin fer car
replace departement = 10 * region + departement if departement < 10

* Le code du ménage : 1rrDmmmm
generate menid = (1000 + departement) * 10000 + _n, before(region) 
format menid %8.0f

* Le code du département : 1rrD
generate depid = 1000 + departement, after(menid) 

quietly {
    * Total par département dans le recensement
    gen un = 1
    capture collect drop deptableRGPH
    collect create deptableRGPH
    collect: total un, over(departement)
    * Sauvegarde pour les taux par département
    collect style cell, nformat(%5.2f)
    collect style showbase off
    collect layout (colname) (result)
    collect export tabledep.xlsx, name(deptabEHCVM) ///
	 sheet(data, replace) cell(A1) noopen replace
    collect export tabledep.xlsx, name(deptableRGPH) ///
	 sheet(data) cell(R1) noopen modify
}

/* 
Taille ajustée à partir des totaux ci-haut pour avoir la population toale
dans la base du recensement car seul 10% de celle-ci est disponible
*/
quietly {
    generate hhsize = 54.9942667918747 if departement == 11
    replace hhsize = 103.187849774122 if departement == 12
    replace hhsize = 128.630119195873 if departement == 13
    replace hhsize = 76.2447266569908 if departement == 14
    replace hhsize = 106.83469526728 if departement == 21
    replace hhsize = 30.5789587852495 if departement == 22
    replace hhsize = 101.258156260216 if departement == 23
    replace hhsize = 118.665685868214 if departement == 31
    replace hhsize = 152.23106918239 if departement == 32
    replace hhsize = 120.384178976665 if departement == 33
    replace hhsize = 110.785114777618 if departement == 41
    replace hhsize = 102.559646910467 if departement == 42
    replace hhsize = 100.49852675887 if departement == 43
    replace hhsize = 192.932699619772 if departement == 51
    replace hhsize = 118.765745501285 if departement == 52
    replace hhsize = 111.993256880734 if departement == 53
    replace hhsize = 125.359247397918 if departement == 54
    replace hhsize = 120.426728586171 if departement == 61
    replace hhsize = 154.901992882562 if departement == 62
    replace hhsize = 116.724681684623 if departement == 63
    replace hhsize = 112.551715550636 if departement == 71
    replace hhsize = 113.914192546584 if departement == 72
    replace hhsize = 132.452371442836 if departement == 73
    replace hhsize = 127.189338089576 if departement == 81
    replace hhsize = 115.465793304221 if departement == 82
    replace hhsize = 105.674993053626 if departement == 83
    replace hhsize = 135.596266184884 if departement == 91
    replace hhsize = 122.68607907743 if departement == 92
    replace hhsize = 123.855120828539 if departement == 93
    replace hhsize = 145.121541010771 if departement == 101
    replace hhsize = 102.14512195122 if departement == 102
    replace hhsize = 120.978630136986 if departement == 103
    replace hhsize = 144.749469964664 if departement == 111
    replace hhsize = 160.489064261556 if departement == 112
    replace hhsize = 61.9497663551402 if departement == 113
    replace hhsize = 163.079672501412 if departement == 121
    replace hhsize = 149.023888888889 if departement == 122
    replace hhsize = 122.576704169424 if departement == 123
    replace hhsize = 104.536477987421 if departement == 124
    replace hhsize = 110.052674066599 if departement == 131
    replace hhsize = 64.4136774193548 if departement == 132
    replace hhsize = 114.314135667396 if departement == 133
    replace hhsize = 132.708393866021 if departement == 141
    replace hhsize = 170.319464720195 if departement == 142
    replace hhsize = 136.392431561997 if departement == 143
    
    replace hhsize = floor(hhsize + 0.5)
    save rgphae.dta, replace
}

*-------------------------------------------------------------------------------
*------------- 3. Test d'égalité de distribution des variables explicatives ----
*-------------------------------------------------------------------------------
* Regroupement des deux pour observer les distributions
use mysurvey.dta, clear

* Identifiant pour supperposer les deux bases
label define origine 1 EHCVM 2 RGPHAE
gen origine:origine = 1

* Supperposition des deux bases
append using rgphae.dta
replace origine = 2 if missing(origine)

* Les variables du modèles
global hhmodel sol elec_ac toilet fer frigo cuisin ordin car

/* Test d'égalité de distributions:
	distributions égales pour sol, elec_ac et fer */
foreach v of varlist $hhmodel {
    ksmirnov `v', by(origine)
}

*-------------------------------------------------------------------------------
*------------- 4. Calcul de la pauvreté au sens de l'EHCVM ---------------------
*-------------------------------------------------------------------------------
* Base d'enquêtes pour les estimations directes
use mysurvey, clear

* Taux de pauvreté national: taux national = 37,8% avec CV = 3,6% < 20,0%
svy: mean pauv, noheader cformat(%9.4f)
estat cv

* Evaluation du taux de pauvreté par région 
svy: mean pauv, over(region) noheader cformat(%9.4f)

* Calcul des coéfficients de variation
estat cv

* Indicateurs de pauvreté: incidence, profondeur et sévérité
ssc install povdeco // pour installer l'ado povdeco

* Poids en entier
generate fpoids = ceil(poids+0.5)

* povdeco pcexp [fweight = fpoids], pline(333440.5) bygroup(region) summarize
povdeco pcexp [fweight = fpoids], varpline(zref) bygroup(region) summarize

* Taux par départements des régions n° 1, 7, 11 et 13
quietly svy, subpop(if inlist(region,1 ,7, 11, 13)): mean pauv, ///
 over(departement) noheader cformat(%9.4f)
estat cv

*-------------------------------------------------------------------------------
*------------- 5. Estimation de la pauvreté avec sae ---------------------------
*-------------------------------------------------------------------------------
* Installation de l'ado sae (se connecter à internet)
ssc install sae
clear

* Compression de la base du recensement (pas besoin d'importer en memoire)
capture erase rgphae_mata
sae data import, datain("rgphae.dta") area(depid) uniqid(menid) ///
 varlist($hhmodel $valpha region departement hhsize) dataout("rgphae_mata")

* Implementation du modèle
use mysurvey, clear
sae model h3 pcexp $hhmodel [aw=poids], area(depid) alfatest(residus)

* Diagnostic du model: Calcul du residus
predict residual, stdp
pnorm residual // P-P plot
graph export graphics.png, as(png) replace

* Diagnostic du model: Test de normalité de Kolmogorov
quietly summarize residual
ksmirnov residual = normal((residual-r(mean))/r(sd))

* Diagnostic du model: Test du skewness
sktest residual

* Pauvreté par région avec sae pour retrouver ceux de l'EHCVM
capture erase reg_ind.dta
sae sim h3 pcexp $hhmodel [aw=poids], area(region) mcrep(100) bsrep(200) ///
 lnskew matin("rgphae_mata") seed(648743) pwcensus(hhsize) ///
 indicators(fgt0 fgt1 fgt2) aggids(0 4) uniqid(menid) plines(333440.5) ///
 ydump("reg_ind") addvars(region departement)

* Labels des Régions
label define region 1 dakar 2 ziguinchor 3 diourbel 4 "saint louis" ///
 5 tambacounda 6 kaolack 7 thies 8 louga 9 fatick 10 kolda ///
 11 matam 12 kaffrine 13 kedougou 14 sedhiou 0 "National"
label values Unit region

* Calcul des CV
rename avg_fgt?* fgt?
rename mse_avg_fgt?* mse_fgt?
gen cv = sqrt(mse_Mean)/Mean
save pauv_reg.dta, replace

* Affichage des taux: les valeurs sont conformes aux IC de l'EHCVM
list Unit fgt0 cv, separator(0)

* Estimation de la pauvreté départementale avec sae
use mysurvey, clear

capture erase dep_ind.dta
sae sim h3 pcexp $hhmodel [aw=poids], area(depid) mcrep(100) bsrep(200) ///
 lnskew matin("rgphae_mata") seed(648743) pwcensus(hhsize) ///
 indicators(fgt0 fgt1 fgt2) aggids(0 4) uniqid(menid) plines(333440.5) ///
 ydump("dep_ind") addvars(region departement)

* Labélisation des départements
quietly {
    label define ldep 1011 DAKAR 1012 PIKINE 1013 RUFISQUE, replace
    label define ldep 1021 BIGNONA 1022 OUSSOUYE 1023 ZIGUINCHOR, add
    label define ldep 1033 MBACKE 1041 DAGANA 1042 PODOR, add
    label define ldep 1051 BAKEL 1052 TAMBACOUNDA 1053 GOUDIRY, add
    label define ldep 1061 KAOLACK 1062 "NIORO DU RIP" 1071 MBOUR, add
    label define ldep 1072 THIES 1073 TIVAOUANE 1081 KEBEMER, add
    label define ldep 1083 LOUGA 1091 FATICK 1093 GOSSAS, add
    label define ldep 1101 KOLDA 1102 VELINGARA, add
    label define ldep 1111 MATAM 1112 KANEL 1121 KAFFRINE, add
    label define ldep 1122 BIRKILANE 1123 KOUNGHEUL, add
    label define ldep 1131 KEDOUGOU 1132 SALEMATA 1133 SARAYA, add
    label define ldep 1142 BOUNKILING 1143 GOUDOMP 1032 DIOURBEL, add
    label define ldep 1014 GUEDIAWAYE 1031 BAMBEY, add
    label define ldep 1043 "SAINT LOUIS" 1054 KOUMPENTOUM, add
    label define ldep 1063 GUINGUINEO 1082 LINGUERE, add
    label define ldep 1092 FOUNDIOUGNE 1103 "MEDINA YORO FOULAH", add
    label define ldep 1113 "RANEROU FERLO" 1124 "MALEM HODAR", add
    label define ldep 1141 SEDHIOU 0 "Sénégal", add
    label value Unit ldep
}

* Calcul des CV
rename avg_fgt?* fgt?
rename mse_avg_fgt?* mse_fgt?
gen cv = sqrt(mse_Mean)/Mean
save pauv_dep.dta, replace

* Affichage des taux: les valeurs sont conformes aux IC de l'EHCVM
list Unit fgt0 cv, separator(0)

*-------------------------------------------------------------------------------
*------------- 6. Cartographie des résultats -----------------------------------
*-------------------------------------------------------------------------------

* Création d'un code (en évitant les espaces)
decode Unit, generate(unid)
replace unid = strlower(ustrtrim(stritrim(unid)))
duplicates report unid
drop if !Unit

* Mettre la pauv_dep.dta base dans le frame depart
frame rename default depart

* Créer un frame maps pour les données spatiales
frame create maps
cwf maps

* Importer la base spatiale déjà préparée
use Maps/base_new.dta, clear

*rename NOM unid (en évitant les espaces)
replace unid = strlower(ustrtrim(stritrim(unid)))
save, replace

* Retour à la base estimation.dta
cwf depart

* Fusion avec la base spatiale
merge 1:1 unid using Maps/base_new.dta, nogen

* Base globale avec données spatiales
save pauv_dep_data, replace

* Création du de la base de label
replace fgt0 = round(100*fgt0, .1) if fgt0 < 1
replace cv = round(100*cv, .1) if cv < 1
cap decode Unit, generate(dep)
quietly {
    expand 2, gen(typs)
    gen labs = dep if !typs
    replace labs = string(fgt0) +"("+string(cv)+"%"+")" if typs == 1
    keep id x_c y_c typs labs Unit
    save pauv_dep_lab, replace
}

* Installation de l'ado spmap pour la création des cartes
ssc install spmap

* Cartographie des résultats par régions
use pauv_dep_data, clear

spmap fgt0 using Maps/cord_new, id(id) fcolor(Heat) ///
 label(data(pauv_dep_lab) label(labs) xcoord(x_c) ycoord(y_c) ///
 position(12 0) angle(0 0) gap(*.1 *0.5) size(tiny tiny) ///
 color(black blue%80) by(typs)) clnumber(14) legenda(off) ///
 title("Pauvreté départementale") note("Source: Tall, 2024")

* Sauvegarde de la figure
graph export zmaps.png, as(png) replace

* Filtre sur la région de Dakar
use pauv_dep_lab, clear
gen region = mod(int(Unit/10),100), before(Unit)
* replace region = 1 if missing(region)
keep if region == 1 // filtre sur Dakar
replace labs = "KEUR MASSAR" if missing(Unit) & !typs
replace labs = "??" if missing(Unit) & typs
save dklab, replace

* Retour sur la base des départements
use pauv_dep_data, clear
spmap fgt0 using Maps/cord_new if region == 1, id(id) ///
 fcolor(yellow%1 yellow%5 yellow%10 yellow%20) label(data(dklab) ///
 label(labs) xcoord(x_c) ycoord(y_c) position(12 0) angle(0 0) ///
 gap(*.1 *0.5) size(tiny tiny) color(black blue%80) by(typs)) ///
 legenda(off) title("Pauvreté départementale") note("Source: Tall, 2024")

* Sauvegarde de la figure sur Dakar
graph export z13dkmaps.png, as(png) replace

* Suppression des fichiers temporaires
local tampo "mysurvey.dta rgphae.dta rgphae_mata estimation.dta rgph_ind"
foreach x of local tampo  {
    capture erase `x'
}
