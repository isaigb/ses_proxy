********************************************************************
* Make the Analytic file *
* Author: Isai Garcia-Baza
*********************************************************************
	
*Merging Career and Completion
	use "${filepath}/data_clean/Career_formerge.dta", clear
	merge 1:1 newid using "${filepath}/data_clean/Completion_formerge.dta", gen(merge1_careercomp)
	
	drop if merge1_careercomp == 2 //dropping graduates who are not found in the career file.
	

*Merging in financial aid
	merge 1:1 newid using "${filepath}/data_clean/Finaidyear_formerge.dta", gen(merge2_finaid)
	drop if merge2_finaid == 2 //dropping rows from finaid that did not match

	
*Merging in application
	merge 1:1 newid institution using "${filepath}/data_clean/Application_formerge.dta", gen(merge3_app)
	drop if merge3_app == 2 // dropping rows from app file that did not match 
	gen year = apptermyear //creating a year var for use in next merge
	tab app_term_ipeds merge3_app, m 
	drop if app_term_ipeds == "" // dropping observations that don't have an application term variable
	drop if merge3_app == 1 // dropping observations that were not matched to applications, data QC confirms this.

*Merging in ACS
	merge m:1 zcta year using "${filepath}/data_clean/ACS_formerge.dta", gen(merge4_acs)
	drop if merge4_acs == 2 // dropping rows from ACS that did not match
	
	
	
*Saving as analytic file
	save "${filepath}/data_clean/analyticfile.dta", replace


	
/* TO  CREATE INSPECTION FILE RUN THE CODE IN THE CUSTOM FUNCTIONS FOLDER

missingfafsa isinfinaid isinfinaidnofafsa missingzip isincompletion isinapplication istransfer isinternational isinacs

*/
