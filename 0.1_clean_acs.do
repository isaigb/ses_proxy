********************************************************************
* Clean ACS data and prep for merge on ZCTA *
* Author: Isai Garcia-Baza
********************************************************************

* Cleaning ACS data
*Importing Data
use "${filepath}/data_raw/acs5_2015to2020.dta", clear

*Lowercase
rename *, lower

*Renaming vars
	rename geoid zcta

* Keeping only variables of interest
keep zcta year s1901_c01_012_estimate s1701_c03_001_estimate s1701_c03_004_estimate s1501_c02_015_estimate s1701_c03_035_estimate

* creating indicator for presence in ACS
	gen isinacs = 1

* Final check of missingness for variables we use to form PCA
	misstable patterns s1901_c01_012_estimate s1701_c03_001_estimate s1701_c03_004_estimate s1501_c02_015_estimate s1701_c03_035_estimate

* Duplicates check
duplicates report zcta year // looks good

*Sorting and Saving
sort zcta year
save "${filepath}/data_clean/ACS_formerge.dta", replace
/*
Key is zcta year
*/
