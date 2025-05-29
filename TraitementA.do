/*-------------------------------------------------------------------------------
Ibrahima Tall
#-------------------------------------------------------------------------------
*/
webuse set "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data"
global dataurl "https://github.com/GeoCenter/StataTraining/raw/master/Day2/Data"
capture log close
log using "$pathlog\Day2Homework.log", replace
import delimited "$dataurl/wb_indicators.csv", clear
browse
describe
count if inlist("..", yr2007, yr2008, yr2013, yr2014) == 1
foreach x of varlist yr2007 yr2008 yr2013 yr2014 {
    replace `x' = "" if inlist("..", `x')
    destring `x', gen(`x'_ds) 
}
drop yr2007 yr2008 yr2013 yr2014
rename *_ds* **
drop seriescode
replace seriesname = "gdp_growth" if seriesname == "GDP growth (annual %)"
replace seriesname = "ag_gdp" if seriesname == "Agriculture, value added (% of GDP)"
replace seriesname = "tax_gdp" if seriesname == "Tax revenue (% of GDP)"
reshape wide yr*, i(countryname) j(seriesname, string)
ds, not(type string)
local renlist = r(varlist)
set tr on 
foreach v of local renlist {
	display in yellow "We are on `v' variable now"
	local x : variable label `v'
	display in yellow "ensure that the variable label for `x' is a valid name and store it in y"
	local y = strtoname("`x'")
	display in white "Now we'll rename `v' to be `y'"
	rename `v' `y' 
	display in white "Our variable should now be named `y'"
}
set tr off
rename *_yr* **
reshape long ag_gdp@ gdp_growth@ tax_gdp@, i(countryname) j(year)
label var ag_gdp "agricultural sector (value added) as % of gdp"
label var gdp_growth "gdp growth rate"
label var tax_gdp "taxes collected as % of gdp"
twoway(connected ag_gdp gdp_growth tax_gdp year, sort), by(countryname) scheme(s1color)
table countryname year, c(mean gdp_growth) f(%9.2fc) row col
encode countryname, gen(country_id)
sort countryname year
gen loc_time_id = real( string(country_id) + string(year) )
isid loc_time_id
saveold "C:\Users\t\Documents\GitHub\StataTraining\Day2\Data\wb_indicators_long.dta", replace
/* Extra credit: reshape the data 1 more time to get a "real" tidy dataset.
* In this case, we want to combine the gdps into a single variable that is 
* identified by a gdp type variable. First, rename our gdp variables
ren(ag_gdp gdp_growth tax_gdp) (gdpag gdpgrowth gdptax)

* Think about syntax: new variable to be created (j) is gdpType
* variables we are squashing into there are gdp_ag, gdp_growth, and gdp_tax)
reshape long gdp@, i(loc_time_id) j(gdpType, string)
la var gdp "gdp values"
la var gdpType "type of gdp, growth is overall growth"

* ### NOTE!: This complicates the merge somewhat, you'll likely have to execute a many-to-many
* merge b/c neither dataset will have a unique id!
*/

* Load in the foreign assistance data and look at it's structure? What do you notice?
* Is there a unique id? No, so it will be a many to 1 merge at this point
cls
use "$dataurl/FA_merge.dta", clear
clist


* Merge with WB data so we can look at indicators alongside foreign assistance data
merge m:1 loc_time_id using "$dataurl/wb_indicators_long.dta"


* Pretty much finished, but you could go crazy and reshape one more time to stack all the gdp variables!
ren(ag_gdp gdp_growth tax_gdp) (gdpag gdpgrowth gdptax)

* Our unique variable combination (i) is loc_time_i + category
* Our variable we want to create (j) is gdpType, this is to be filled with a string
reshape long gdp@, i(loc_time_id category) j(gdpType, string)
la var gdp "Gdp values"
* Probably enough reshaping for today! How does gdp look compared to spending?
