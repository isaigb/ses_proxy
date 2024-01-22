********************************************************************
* Clean Financial Aid File *
* Author: Isai Garcia-Baza
********************************************************************

*Loading Financial aid
use "${rawdata}/financialaid/finaid_07_25_22.dta", clear

*Renaming vars to lowercase
rename *, lower

sort newid finaid_process_year

*Keeping Undergraduate students and dropping those in UNC school of the arts
	keep if career == "Undergraduate"
	drop if institution == "UNCSA"
	
*Keeping finaid data for 2015-2016 and beyond
	tab finaid_process_year, m
	gen drop = 0
		replace drop = 1 if strpos(finaid_process_year, "2011")
		replace drop = 1 if strpos(finaid_process_year, "2012")
		replace drop = 1 if strpos(finaid_process_year, "2013")
		replace drop = 1 if strpos(finaid_process_year, "2014")
		tab finaid_process_year drop, m //looks good
	drop if drop == 1
	drop drop

*Keeping first row for each newid
	duplicates tag newid, gen(newiddupes)
	gen keep = 0
		replace keep = 1 if newiddupes == 0 //keeping those who are already deduplicated by newid
		bysort newid (finaid_process_year): replace keep = 1 if newiddupes >= 1 & _n == 1 //groups by newid then sorts within using finaid_process_year. It then will replace keep = 1 if there exist duplicates by newid and if the row is the first of the group.
		tab newiddupes keep, m
	keep if keep == 1
	drop keep newiddupes
	duplicates report newid

* Fixing vars
gen pell_offer_dummy = 0
	replace pell_offer_dummy = 1 if pell_offer_flag == "Y"
	tab pell_offer_dummy pell_offer_flag, m

gen finaid_dependent_dummy = .
	replace finaid_dependent_dummy = 0 if finaid_depend_status == "Independent"
	replace finaid_dependent_dummy = 1 if finaid_depend_status == "Dependent"
	tab finaid_depend_status finaid_dependent_dummy, m

gen first_gen_dummy = .
	replace first_gen_dummy = 1 if first_generation_fafsa == "Yes"
	replace first_gen_dummy = 1 if first_generation_fafsa == "Probable"
	replace first_gen_dummy = 0 if first_generation_fafsa == "No"
	replace first_gen_dummy = 0 if first_generation_fafsa == "Unknown"
	replace first_gen_dummy = 0 if first_generation_fafsa == "Did Not Answer"
	tab first_generation_fafsa first_gen_dummy, m
	
//checking missigness
	bysort finaid_depend_status: mdesc primary_efc primary_efc_parent primary_efc_student
	browse if primary_efc_parent == . & finaid_depend_status == "Independent"
	/*
	Students with missing depend status are missing all EFC variables (14k, 100%)
	Students who are dependent might be missing parent EFC (18k, 8%) but always have primary efc
	Students who are independent might be missing parent efc (23k, 46%) but never missing primary EFC
	*/	
	
*Fixing EFC
	gen fixefc = .
		replace fixefc = 1 if primary_efc_parent == .
		replace fixefc = 1 if primary_efc_student == .
	browse *_efc* if fixefc == 1
	
	//fixing primary_efc_parent
	replace primary_efc_parent = primary_efc - primary_efc_student if fixefc == 1 & primary_efc_parent == . // calculating primary efc parent if we have student and primary data 
	replace primary_efc_parent = 0 if fixefc == 1 & primary_efc_student == . & primary_efc_parent == . & primary_efc == 0
	
	//fixing primary_efc_student
	replace primary_efc_student = primary_efc - primary_efc_parent if fixefc == 1 & primary_efc_student == .
	replace primary_efc_student = 0 if fixefc == 1 & primary_efc_student == . & primary_efc_parent == . & primary_efc == 0
	
*Creating FAFSA Flag
	gen missingfafsa = .
		replace missingfafsa = 1 if fafsa_complete_flag == "N"
		replace missingfafsa = 0 if fafsa_complete_flag == "Y"
	tab missingfafsa, m

*Checking EFC missings
	bysort missingfafsa: mdesc primary_efc //all primary EFC missing for those with missing FAFSA
	
	
* Creating financial aid identifier
	gen isinfinaid = 1
	
* Indicator for is in financial aid file but has no FAFSA
	gen isinfinaidnofafsa = 0
		replace isinfinaidnofafsa = 1 if missingfafsa == 1
	
	
	
	
	
	
	
* A note about non-FAFSA completers
	misstable patterns * if missingfafsa == 1
	// most will be missing almost all variables
	
* Keeping only necessary variables
keep primary_efc primary_efc_parent primary_efc_student finaid_dependent_dummy first_gen_dummy pell_offer_dummy institution finaid_process_year student_cid newid pell_offer_dummy finaid_dependent_dummy first_gen_dummy fixefc missingfafsa isinfinaid isinfinaidnofafsa agi_official
	
*Sorting and saving
sort newid
save "${filepath}/data_clean/Finaidyear_formerge.dta", replace
/*
Deduplicated by newid
*/
