help import
cd // this will show us what our current working directory is
global pathin "/Users/Aaron/Desktop/StataTraining/Day1/Data/" 
cd $pathin // this changes our working directory location
insheet using "StataTraining.csv", clear
save FAD.dta, /// file will save to the same directory we defined working in
replace	//replaces the file if its already existing
