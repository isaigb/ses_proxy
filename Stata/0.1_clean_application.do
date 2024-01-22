********************************************************************
* Clean Application file *
* Author: Isai Garcia-Baza
********************************************************************


*Loading
use "${rawdata}/application/application_04_14_22.dta", clear


*Renaming
rename *, lower

	
* Creating sortable intended term
	tab app_term_ipeds, m 
	gen apptermyear = substr(app_term_ipeds, -4, .)
	destring apptermyear, replace
	
	gen apptermtype = .
		replace apptermtype = 1 if strpos(app_term_ipeds, "Spring")
		//replace apptermtype = 2 if strpos(matric_term_ipeds, "Summer I")
		//replace apptermtype = 3 if strpos(matric_term_ipeds, "Summer II")
		//replace apptermtype = 3 if strpos(matric_term_ipeds, "Summer Session II")
		replace apptermtype = 4 if strpos(app_term_ipeds, "Fall")
		label define apptermtype 1 "Spring" 2 "Summer 1" 3 "Summer 2" 4 "Fall"
		label values apptermtype apptermtype
		tab app_term_ipeds apptermtype, m
	
* Dropping obs for matriculations prior to Fall 2015
	drop if apptermyear <= 2014
	drop if apptermyear == 2015 & (apptermtype == 1 | apptermtype == 2 | apptermtype == 3)
	tab app_term_ipeds institution, m //checking, looks good
	tab app_term_ipeds, m

* Keeping applications for Freshman and Transfer
tab admission_type intended_career , m
keep if admission_type == "Freshman" | admission_type == "Transfer"

*Keeping applications for undergrad career
	tab intended_career, m
	keep if intended_career == "Undergraduate" //keeping undergrads

*keeping apps for inteded BA
keep if intended_degree_level == "Bachelor's"

* Keeping Primary unduplicated and primary application flagged applications 
keep if primary_undup_app == "Y"
keep if primary_application_flag == "Y"

* Data check
bysort app_term_ipeds: tab admission_type admit_flag, m
/* The numbers look very good, we are slightly over the reported amounts in 
   terms of applications but we are slightly under in terms of admissions counts.*/
	
* Keeping applications from admitted students
	tab admit_flag, m
	keep if admit_flag == "Y" //keeping admitted

* Dropping UNC school of the arts data 
	drop if institution == "UNCSA"


*Checks for duplicates, plan to dedupe by newid and institution
	duplicates tag newid institution, generate(newidinstdupes)
	tab newidinstdupes, m // multiple applications per institutions exist
	
	sort newid apptermyear apptermtype 
	//browse if newidinstdupes >= 1
	//browse if newidinstdupes == 2
	duplicates report newid institution app_term_ipeds //are there multiple apps to same inst in same year? -- Yes
	
	
*Keeping last application by newid institution and app_term_ipeds
	gen keep = 0
		replace keep = 1 if newidinstdupes == 0
		bysort newid institution (apptermyear apptermtype): replace keep = 1 if newidinstdupes >= 1 & _n == _N //groups observations by newid and institution. It then sorts within these groups using apptermyear and apptermtype. It will replace keep = 1 if the observations have duplicates and if the observation number (within each group) equals the total number of observations in the group. (i.e., if the observation is last of its group)
	tab newidinstdupes keep, m 
	
	keep if keep == 1
	drop keep newidinstdupes
	duplicates report newid institution

*Cleaning Zipcode
	gen zipcode = substr(student_perm_zipcode, 1, 5)
	replace zipcode = subinstr(zipcode, " ", "", .) // removed all blanks
	replace zipcode = "" if strlen(zipcode) != 5 // setting zips not of length 5 to blank
	replace zipcode = "" if regexm(zipcode, "[a-zA-Z]+") // searches for letters in zip, replaces to missing
	replace zipcode = "" if zipcode == "00000" | zipcode == "00-23" | zipcode == "00004" | zipcode == "00020" | zipcode == "99999"
	
	gen imputedzip = 0
	gen missingzip = 0
		replace missingzip = 1 		if zipcode == ""
		replace imputedzip = 1 		if zipcode == "" & hs_zip != ""
		replace zipcode = hs_zip 	if zipcode == "" & hs_zip != ""
		
		replace imputedzip = 0 		if strlen(zipcode) <= 4
		replace zipcode = "" 		if strlen(zipcode) <= 4
				
*Cleaning HS admit GPA
	//Convert GPAs to 4.0 scale where on a different scale
	//Those missing a scale category look like 4.0 scale
	gen hs_gpa = admit_hs_gpa // if inlist(gpa_scale_a,"4.0","Migrated 4.0","Converted 4.0","")
	replace hs_gpa=admit_hs_gpa*(4/10) if gpa_scale_a=="10.0"
	replace hs_gpa=admit_hs_gpa*(4/100) if gpa_scale_a=="100"
	replace hs_gpa=admit_hs_gpa*(4/100) if gpa_scale_a== "Not Applicable" & gpa_scale_w == "100"
	replace hs_gpa=admit_hs_gpa*(4/12) if gpa_scale_a=="12.0"
	replace hs_gpa=admit_hs_gpa*(4/5) if gpa_scale_a=="5.0"
	replace hs_gpa=admit_hs_gpa*(4/6) if gpa_scale_a=="6.0"
	replace hs_gpa=admit_hs_gpa*(4/7) if gpa_scale_a=="7.0"
	replace hs_gpa=admit_hs_gpa*(4/8) if gpa_scale_a=="8.0"


*Cleaning ACT and SAT scores
	merge m:1 act_super using "${filepath}/data_raw/act_sat_mapping.dta"
	gen mapped_sat=sat_super2_ipeds //creates a var that will combine test performance across SAT and ACT.
	replace mapped_sat = SAT if mapped_sat==. & act_super != . //if the student did not take the SAT but did take the ACT, their ACT score will be mapped to equivalent SAT and stored.
	drop _merge SAT

* Creating application presence indicator
	gen isinapplication = 1
* Transfer indicator
	gen istransfer = 0
		replace istransfer = 1 if admission_type == "Transfer"
* International indicator
	gen isinternational = 0
		replace isinternational = 1 if student_perm_country_code != "USA" & student_perm_country_code != "" 
	
* Merging in zcta crosswalk variable 
gen year = apptermyear
merge m:1 zipcode year using "${filepath}/data_clean/zip_to_zcta_formerge.dta"
drop if _merge == 2 // dropping zcta's that were not matched.
drop year

*Sorting and saving
sort newid institution
save "${filepath}/data_clean/Application_formerge.dta", replace

/*
Deduplicated by newid and institution 
*/
