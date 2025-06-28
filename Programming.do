*########################## Commercer à programmer #########################################
 adopath //Les directions
sysdir // idem que plus-haut
* La base de données du système
sysuse auto, clear // Base d'essai
*-------------------------- 1. Les boucles forvalues ---------------------------------------
* Création des variables alea1, alea4, alea7 et alea10
forvalues i = 1(3)10 { // Première forme
    * set seed 12345 //Fixer
    generate alea`i' = uniform()
}
* Création des variables norm1, norm4, norm7 et norm10
forvalues i = 1 3 to 10 {//Autre format: (i = 1 3: 10)
    generate norm`i' = normal()
}
*-------------------------- 2. Les boucles foreach -----------------------------------------
* Affichage de nombres impairs de 1 à 20
foreach x of numlist 1(2)20 {
    * Affichage
    display "`x'"
}
* Summarize des variables numériques
quietly ds, has(type float)
foreach x of varlist `r(varlist)' {
    summarize `x'
}
*-------------------------- 3. Les matrices ------------------------------------------------
matrix define A = I(3) //Matrix identité carrée 3x3
matrix define B = (1,4,8\2,5,9\7,2,6) //Matrice simple carrée de dimension 3x3
matrix define C = J(3,3,0) //Matrice null inférieure 3x3
matrix Binv = inv(B) //Inverse de B
matrix Ainv = invsym(A) //Inverse symétrique de A
matrix D = cholesky(4*I(3) + A’*A) //Matrice de Choleski
matrix E = sweep(B,1) //Fonction sweep()
matrix F = corr(C) //Fonction Coorelation
matrix G = diag(2,5,7) //Matrice diagonale de dimension 3x3
matrix H = vec(D) //Vecteurs
matrix K = vecdiag(D) //Vecteur diagonal
matrix U = matuniform(3,4) //Matrice aléatoire
matrix L = hadamard(B,C) //Hadamard fonctions
matrix rownames A = alpha "My r2" Phi
matrix colnames A = col "My c2" rho
matlist 2*A, border(rows) rowtitle(rows) left(4) //border(rows)==border(top+bottom)
*-------------------------- 4. Les macro ----------------------------------------------------
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

*-------------------------- 5. Les macro ----------------------------------------------------
capture drop prog9010.ado
*! prog9010 v01 15 juin 2025
program prog9010, rclass
   version 13
   syntax varlist(max=1 numeric) [if] [in] [, noPRINT]
   tempname p9010 N
   marksample touse
   quietly summarize `varlist' if `touse', detail
   scalar `p9010' = r(90) - r(10)
   scalar `N' = _N
   if "`print'" != "noprint" {
      display as txt "Intervalle est p9010 = " as result `p9010'
   } 
   else {
      display as txt ""
   }
   return scalar p9010 = `p9010'
end
