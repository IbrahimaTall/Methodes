*! Version V0.0.1 18juin2025 IbTALL
program define systirage, rclass byable(recall)
version 14
syntax varlist(min=1 max=1 numeric) [, strata(varlist) noENTIER(string)]
tempvar strate vartxt varcode
tempname ndv ndstr nivstr nivvar
scalar `ndv' = 1
scalar `ndstr' = 1
quietly distinct `varlist', missing
scalar local `ndv' r(ndistinct)
if "`strata'" != "" {
  quietly distinct `strata', missing joint
  scalar local `ndstr' r(ndistinct)
}
if ``ndv'' != ``ndstr'' {
  display "{error:La taille doit être unique dans le groupe}"
  exit 203
}
else {
  quietly {
    egen `strate' = group(`strata') label
    generate `vartxt' = string(`varlist')
    encode `vartxt', generate(`varcode')
    levelsof `strate', generate(`nivstr') 
    levelsof `varcode', generate(`nivvar')
  }
}
