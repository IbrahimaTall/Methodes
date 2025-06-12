*########################## Commercer à programmer #########################################
sysuse auto, clear
*-------------------------- 1. Les boucles -------------------------------------------------
* Création des variables alea1, alea4, alea7 et alea10
forvalues i = 1(3)10 {
  * set seed 12345
  generate alea`i' = uniform()
}
