********************************************************************
* Clean zip code to ZCTA crosswalk and prep for merge *
* Author: Isai Garcia-Baza
********************************************************************
/*
Notes: 

Raw data were found at https://udsmapper.org/zip-code-to-zcta-crosswalk/

These files are maintained by the American Academy of Family Physicians and a number of other healthcare groups (see: https://udsmapper.org/about/)

*/

* Importing UDS zip to zcta crosswalk 2015
import excel using "${filepath}/data_raw/ZipCodetoZCTACrosswalk2015UDS.xlsx", clear firstrow

rename *, lower
rename zip zipcode
rename zcta_use zcta
gen year = 2015

keep zipcode zcta year


* Looping over rest of the files
forvalues num = 2016(1)2022 {
	
	di " Starting year `num'"
	
	capture frame drop temp
	
	frame create temp

	frame temp: import excel using "${filepath}/data_raw/ZIPCodetoZCTACrosswalk`num'UDS.xlsx", clear firstrow
	frame temp: rename *, lower

	frame temp: gen year = `num'
	
	frame temp: rename zip_code zipcode
	frame temp: keep zipcode zcta year
	
	tempfile savefile
	
	frame temp: save `savefile'
	append using `savefile'
}



* Duplicates check
duplicates report zipcode // looks good
duplicates report zipcode year // 1 zipcode has duplicate
drop if zipcode == "96898" & zcta == "No ZCTA"
duplicates report zipcode year // looks good

save "${filepath}/data_clean/zip_to_zcta_formerge.dta", replace
/*
Unique by zipcode year
*/
