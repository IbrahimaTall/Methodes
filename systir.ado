*! Version V0.0.1 18juin2025 IbTALL
program define systir, rclass byable(recall)
version 14
syntax varlist(min=1 max=1 numeric) [, strata(varlist) noENTIER(string)]
tempname ndv ndstr
scalar `ndv' = 1
scalar `ndstr' = 1
quietly distinct `varlist', missing
scalar local `ndv' r(distinct)
if "`strata'" != "" {
  quietly distinct `strata', missing joint
  scalar local `ndstr' r(distinct)
}
if ``ndv'' != ``ndstr'' {
  display "{error:La taille doit être unique dans le groupe}"
  exit 203
}
else {
}
