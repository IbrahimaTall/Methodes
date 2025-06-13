*########################## Commercer à programmer #########################################
* La base de données du système
sysuse auto, clear
*-------------------------- 1. Les boucles forvalues ---------------------------------------
* Création des variables alea1, alea4, alea7 et alea10
forvalues i = 1(3)10 {
    * set seed 12345
    generate alea`i' = uniform()
}
* Création des variables norm1, norm4, norm7 et norm10
forvalues i = 1 3 to 10 {//Autre format: (i = 1 3: 10)
    generate norm`i' = normal()
}

*-------------------------- 2. Les boucles foreach -----------------------------------------
* Affichage de nombres impairs de 1 à 20
foreach x of numlist 1(2)20 {
    display "`x'"
}
* Summarize des variables numériques
quietly ds, has(type float)
foreach x of varlist `r(varlist)' {
    summarize `x'
}
*-------------------------- 3. Les macro -----------------------------------------
local n = 1
local ++n
display `n'
glogal listvar make foreign
display $listvar
* Porpriétés d'une commande 
display "`:properties regress'"
* Type de résultats
display "`:results regress'"
* Nb Chars du plus long label
display "`:label (foreign) maxlength'"
* Label du code
display "`:label origin 0'"
* Caractéristiques
display "`:char _dta[]'"
