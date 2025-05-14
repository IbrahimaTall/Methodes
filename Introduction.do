help import
cd // this will show us what our current working directory is
global pathin "/Users/Aaron/Desktop/StataTraining/Day1/Data/" 
cd $pathin // this changes our working directory location
insheet using "StataTraining.csv", clear
save FAD.dta, /// file will save to the same directory we defined working in
replace	//replaces the file if its already existing
browse
use FAD.dta
describe
sort spent
gsort - spent //allows us to sort in decending order (negative sign)
list benefitingcountry agency spent in 1/10 // this gives us the first 10 lines
list benefitingcountry agency spent in 1/10
sum spent, d // gives more detail
bysort fiscalyear: sum spent
table fiscalyear, c(mean spent med spent count spent)
table fiscalyear if sector == "Agriculture", c(mean spent med spent)
table fiscalyear sector	if inlist(sector, "Agriculture", "Nutrition", "Malaria"), c(mean spent)
hist spent if fiscalyear==2012 & fiscalyeartype=="Obligations", frequency
