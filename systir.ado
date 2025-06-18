*! Version V0.0.1 18juin2025 IbTALL
program define systir, rclass byable(recall)
version 14
syntax varlist(min=1 max=1 numeric) [, strata(varlist) noENTIER(string)]
tempname ndv ndstr
quietly distinct `varlist', missing
scalar local `ndv' r(distinct)
if ``ndv'' != 1 & "`strata'" == "" {
  display error "La taille doit être unique dans le groupe"
  exit 203
}
quietly distinct `strata', missing
scalar local `ndstr' r(distinct)
