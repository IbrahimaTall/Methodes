*########################## Commercer à programmer #########################################
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
foreach x of numlist 1 3 9 {
    display "`x'"
}
