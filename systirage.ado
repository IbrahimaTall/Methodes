*! Version V0.0.1 18juin2025 IbTALL
program define systirage, rclass byable(recall)
version 14
syntax varlist(min=1 max=1 numeric) [, strata(varlist) noENTIER(string)]
tempvar strate vartxt varcode selected
tempname ndv ndstr nivstr nivvar preced
scalar `ndstr' = 1
quietly distinct `varlist', missing
scalar local `ndv' r(ndistinct)
qui gen `selected' = .
if "`strata'" != "" {
  quietly distinct `strata', missing joint
  quietly scalar local `ndstr' r(ndistinct)
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
  }
  if "`entier'" == "entier" {
    qui levelsof `varcode', generate(`nivvar')
    scalar local `preced' = 0
    foreach x in numlist `r(levels)' {
      tempname pas`x' prem`x'
      qui count if `varcode' == `x'
      scalar local `pas`x'' = ceil(r(N)/`x')
      scalar local prem`x' = ceil(runiform() * ``pas`x''')
      replace `selected' = mod(_n - `prem`x'' - `preced', `pas') == 0 if `varcode' == `x'
      qui count if `varcode' == `x'
      scalar local `preced' = ``preced'' + r(N)
    }
  }
