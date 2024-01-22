********************************************************************
* Clean Career File *
* Author: Isai Garcia-Baza
********************************************************************
/*
This study will focus on Undergraduate students who matriculated in Fall 2015 
or later. Will also drop admits to UNC school of the arts
*/

*Loading Career
use "${rawdata}/career/career_10_05_22.dta", clear

*Renaming vars to lowercase
rename *, lower


*Keeping Undergraduate students and dropping those in UNC school of the arts
	keep if career == "Undergraduate"
	drop if institution == "UNCSA"

	
*Keeping those who started at or after Fall 2015
	//first dropping troublesome observations from matric_term_ipeds
	tab matric_term_ipeds, m
	drop if strpos(matric_term_ipeds, "Graduate File") //dropping all obs with "Graduate File" in matriculation variable
	drop if strpos(matric_term_ipeds, "Migrated Data") // same as above but different string.
	drop if strpos(matric_term_ipeds, "Winter")
	drop if matric_term_ipeds == "" //dropping completely empty matric term observations
	
	tab matric_term_ipeds, m //checking, looks good
	
	//creating term year and type vars that are sortable
	gen matrictermyear = substr(matric_term_ipeds, -4, .)
	destring matrictermyear, replace
	
	gen matrictermtype = .
		replace matrictermtype = 1 if strpos(matric_term_ipeds, "Spring") //prev snapshot_term
		replace matrictermtype = 2 if strpos(matric_term_ipeds, "Summer I")
		replace matrictermtype = 3 if strpos(matric_term_ipeds, "Summer II")
		replace matrictermtype = 3 if strpos(matric_term_ipeds, "Summer Session II")
		replace matrictermtype = 4 if strpos(matric_term_ipeds, "Fall")
		label define matrictermtype 1 "Spring" 2 "Summer 1" 3 "Summer 2" 4 "Fall"
		label values matrictermtype matrictermtype
	//dropping obs that matriculated before fall 2015
	drop if matrictermyear <= 2014
	drop if matrictermyear == 2015 & (matrictermtype == 1 | matrictermtype == 2 | matrictermtype == 3)
	tab matrictermyear matrictermtype, m
	tab institution matric_term_ipeds, m //checking, looks good but Fall 2015 seems low
	
*Creating term year and type vars that are sortable
	gen termyear = substr(snapshot_term, -4, .)
	destring termyear, replace
	
	gen termtype = .
		replace termtype = 1 if strpos(snapshot_term, "Spring")
		replace termtype = 2 if strpos(snapshot_term, "Summer I")
		replace termtype = 3 if strpos(snapshot_term, "Summer II")
		replace termtype = 4 if strpos(snapshot_term, "Fall")
		label define termtype 1 "Spring" 2 "Summer 1" 3 "Summer 2" 4 "Fall"
		label values termtype termtype
		
		
*Keeping the last term a student was enrolled in
	duplicates tag newid, gen(newiddupes) //creating a duplicates indicator
	gen keep = 0 //indicator for which obs to keep
		replace keep = 1 if newiddupes == 0 //keeping everyone who is already unique by newid
		bysort newid (termyear termtype): replace keep = 1 if _n == _N & newiddupes >= 1 //groups by newid then sorts within the group using termyear and termtype. Finally it replaces keep = 1 if the within group observation number equals the total number of observations in the group (i.e., if the observation is the last one of the group)
		//Manually checking below, will comment out to avoid browse window popups.
		/*
		browse if newiddupes >= 1
		browse if newiddupes == 2 //checking those who appear twice
		browse if newiddupes == 3 //checking those who appear 3 times
		browse if newiddupes == 5 //checking those who appear 6 times
		*/
	tab newiddupes keep, m
	keep if keep == 1
		

*Looking over data
	tab termyear termtype, m
	bysort institution: tab termyear termtype, m
	duplicates report newid // fully deduplicated

*dropping unneeded vars
	drop newiddupes
	
*Renaming some vars for merge
	rename major_1_cip_code program_cip_code

*GPA outcome vars
	gen gpa_levels = .
		replace gpa_levels = 3 if cum_over_gpa >= 3 & cum_over_gpa != .
		replace gpa_levels = 2 if cum_over_gpa < 3 & cum_over_gpa >= 2
		replace gpa_levels = 1 if cum_over_gpa < 2 & cum_over_gpa >= 1
		replace gpa_levels = 0 if cum_over_gpa < 1
	label define gpa_levels 3 "GPA >= 3" 2 "GPA >= 2 AND < 3" 1 "GPA >=1 AND < 2" 0 "GPA < 1"
	
	label values gpa_levels gpa_levels

* Indicator for presence in this file
	gen isincareer = 1
	
	
keep institution_id institution institution_code newid nc_uid stdnt_race_ipeds stdnt_race_ipeds_code student_gender_ipeds student_age student_citizenship career primary_career_flag certificate_seeking_flag enrollment_status_code enrollment_status enrollment_status_code_ipeds enrollment_status_ipeds class_level_code class_level student_fte admit_term_code admit_term matric_term_code matric_term matric_term_code_ipeds cum_inst_attempt_hours cum_inst_earned_hours cum_inst_gpa cum_over_attempt_hours cum_over_earned_hours cum_over_gpa  snapshot_term term_inst_attempt_hours term_inst_earned_hours term_inst_gpa matrictermyear matrictermtype termyear gpa_levels isincareer
	


*Saving after sort
sort newid
save "${filepath}/data_clean/Career_formerge.dta", replace
/*
Deduplicated by newid
*/
