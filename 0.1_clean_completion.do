********************************************************************
* Import Completion File *
* Author: Isai Garcia-Baza
********************************************************************


*Loading Completion
use "${rawdata}/completion/completion_04_14_22.dta", clear

*Renaming vars to lowercase
rename *, lower

*Keeping Undergraduate students
	keep if career == "Undergraduate"
	//commenting the command below gives us about 1k more completions
	//keep if degree_level == "Bachelor's" //Keeping those pursuing Bachelor's
	drop if institution == "UNCSA"

*Keeping those who started at or after Fall 2015
	//drop troublesome observations
	tab matric_term_ipeds, m
	drop if strpos(matric_term_ipeds, "Graduate File") //dropping all obs with "Graduate File" in matriculation variable
	drop if strpos(matric_term_ipeds, "Summer Session II") // same as above but different string.
	drop if strpos(matric_term_ipeds, "Winter")
	drop if matric_term_ipeds == "" //dropping completely empty matric term observations
	tab matric_term_ipeds, m

	//creating sortable matriculation term and year
	gen matrictermyear = substr(matric_term_ipeds, -4, .)
	destring matrictermyear, replace
	
	gen matrictermtype = .
		replace matrictermtype = 1 if strpos(matric_term_ipeds, "Spring")
		//replace matrictermtype = 2 if strpos(matric_term_ipeds, "Summer I")
		//replace matrictermtype = 3 if strpos(matric_term_ipeds, "Summer II")
		//replace matrictermtype = 3 if strpos(matric_term_ipeds, "Summer Session II")
		replace matrictermtype = 4 if strpos(matric_term_ipeds, "Fall")
		label define matrictermtype 1 "Spring" 2 "Summer 1" 3 "Summer 2" 4 "Fall"
		label values matrictermtype matrictermtype
	//dropping obs for matriculations prior to Fall 2015
	drop if matrictermyear <= 2014
	drop if matrictermyear == 2015 & (matrictermtype == 1 | matrictermtype == 2 | matrictermtype == 3)
	tab matric_term_ipeds institution, m //checking, looks good
	tab matric_term_ipeds, m
	
	
*creating term year and type vars that are sortable
	tab snapshot_term, m
	gen termyear = substr(snapshot_term, -4, .)
	destring termyear, replace
	
	gen termtype = .
		replace termtype = 1 if strpos(snapshot_term, "Spring")
		replace termtype = 2 if strpos(snapshot_term, "Summer I")
		replace termtype = 3 if strpos(snapshot_term, "Summer II")
		replace termtype = 4 if strpos(snapshot_term, "Fall")
		label define termtype 1 "Spring" 2 "Summer 1" 3 "Summer 2" 4 "Fall"
		label values termtype termtype

		
	
*Deduplication by newid
	duplicates report newid
	duplicates tag newid, generate(newiddupes)
		sort newid termyear termtype
		/*
		browse if newiddupes >= 1
		browse if newiddupes == 2 //checking those who appear twice
		browse if newiddupes == 3 //checking those who appear 3 times
		browse if newiddupes == 5 //checking those who appear 6 times
		*/
	
	//sorting by degree such that primary degree is first before others
	gen degree_sort = .
		replace degree_sort = 1 if student_first_major == "Y"
		replace degree_sort = 2 if student_first_major == "N"
		tab degree_sort, m
		
	
	//sorting then dropping
	gen keep = 0
		replace keep = 1 if newiddupes == 0 //keeping everyone who is already unique by newid
		sort newid termyear termtype
		bysort newid (degree_sort termyear termtype): replace keep = 1 if _n == 1 & newiddupes >= 1 //groups by newid and then sorts within group based on the term year and type. Finally it replaces keep = 1 for the first observation within the newid group (i.e., it keeps the first degree earned per newid)
		//Checking
		/*
		browse if newiddupes >= 1
		browse if newiddupes == 2 //checking those who appear twice
		browse if newiddupes == 3 //checking those who appear 3 times
		browse if newiddupes == 5 //checking those who appear 6 times
		*/
	tab newiddupes keep, m
	keep if keep == 1
	
	//checking that it worked
	duplicates report newid //fully deduplicated
	
	

	
*Prepping for merge
	destring nc_uid, replace
	drop newiddupes degree_sort
	
*Creating time to completion vars
// TODO: Review this and check if it needs to be reworked for summer awards.
	//gen test_time_to_completion = termyear - matrictermyear //missing half years
	
	gen time_to_completion = .
		replace time_to_completion = termyear - matrictermyear if matrictermtype == 4 & termtype <= 3 & matrictermyear < termyear //add 0 for started in fall ended in spring of a later year 
		replace time_to_completion = (termyear - matrictermyear) + .5 if matrictermtype == 4 & termtype == 4 & matrictermyear < termyear //add .5 for started in fall ended in fall of a later year 
		replace time_to_completion = (termyear - matrictermyear) + .5 if matrictermtype == 1 & termtype <= 4 & matrictermyear < termyear //add .5 for started in spring ended in spring/summer of a later year 
		replace time_to_completion = (termyear - matrictermyear) + 1 if matrictermtype == 1 & termtype == 4 & matrictermyear < termyear //add .5 for started in spring ended in fall of a later year 
		
		replace time_to_completion = (termyear - matrictermyear) + .5 if matrictermtype == 4 & termtype == 4 & matrictermyear == termyear //add .5 for started in fall ended in fall of the same year
		replace time_to_completion = (termyear - matrictermyear) + .5 if matrictermtype == 1 & termtype <= 3 & matrictermyear == termyear //add .5 for started in spring ended in spring/summer of the same year
		replace time_to_completion = (termyear - matrictermyear) + 1 if matrictermtype == 1 & termtype == 4 & matrictermyear == termyear //add 1 for started in spring ended in fall of the same year

* Creating categories of time to completion
	gen time_to_completion_cat = .
		replace time_to_completion_cat = 1 if time_to_completion <= 4 //completed in 4
		replace time_to_completion_cat = 2 if time_to_completion > 4 & time_to_completion <= 5
		replace time_to_completion_cat = 3 if time_to_completion > 5 & time_to_completion != .
		
		label define time_to_completion_cat 0 "did not complete" 1 "<=4 time to completion" 2 "<=5 & > 4 time to completion" 3 ">5 time to complete"
		label values time_to_completion_cat time_to_completion_cat
		
		
	tab time_to_completion time_to_completion_cat, m

	
	//completion flag
	gen completed = 1
	
	gen isincompletion = 1
		
	




//sort and save
sort newid
save "${filepath}/data_clean/Completion_formerge.dta", replace
/*
Deduplicated by newid
*/
