********************************************************************
/* 
Author: Isai Garcia-Baza

Purpose: Uses analytic file and other files to generate the PCA components
*/
********************************************************************
********************************************************************



*************************************************
* 1 Import ACS data only and run PCA
	//ACS ONLY
/* Using full ACS at zipcodd level dataset */
*************************************************
	
	use "${filepath}/data_clean/ACS_formerge.dta", clear
	
	label var s1901_c01_012_estimate "HHS median income ($)"
	label var s1501_c02_015_estimate "Pct. pop. >=25 with BA+"
	label var s1701_c03_001_estimate "Pct. Pop. below poverty"
	//label var s1701_c03_004_estimate "Pct. < 18 y/o for pop. below poverty"
	label var s1701_c03_035_estimate "Pct. FT employed 16+ y/o for pop. below poverty"
	

	//conducting pca
	pca s1901_c01_012_estimate s1501_c02_015_estimate s1701_c03_001_estimate s1701_c03_035_estimate
	
	//TODO: Add exporting code for correlation tables etc.
	
	//TODO: check if per-year PCA is better
	
	/*
	levelsof year, local(years) clean
	foreach i of local years {
		di "PCA for year: `i'"
		pca s1901_c01_012_estimate s1501_c02_015_estimate s1701_c03_001_estimate s1701_c03_035_estimate if year == `i'
	}
	*/
		
	//generating components
	predict component1, score
	egen pca_acs_only_c1 = std(component1)
	drop component1
	//labels
	label var pca_acs_only_c1 "Compnt. 1 (std) ACS Only PCA"
	vl create vl_pca_acs_components = (pca_acs_only_c1)

	
	
	desc s1901_c01_012_estimate s1701_c03_001_estimate s1501_c02_015_estimate s1701_c03_035_estimate
	
	*Plotting components and eigenvalues
	screeplot, ci yline(1) title("(${S_DATE})PCA Eigenvalues of ACS ONLY")
	graph export "${filepath}/figures/pca_acs_only_screeplot_${S_DATE}.png", replace
	
	// Generating quartile indicator variable
	xtile pca_acs_only_quartile = pca_acs_only_c1, nq(4)
	label var pca_acs_only_quartile "Zipcode level quartiles based on CPA component 1"
	
	
	//saving file
	keep zcta year pca_acs_only_c1 pca_acs_only_quartile
	save "${filepath}/data_clean/acsonlypcavalues.dta", replace

********************************************************************
* 2 Import analytic file *
********************************************************************
use "${filepath}/data_clean/analyticfile.dta", clear


drop keep
gen keep = .
	replace keep = 1 if merge2_finaid == 3 & merge3_app == 3 //keeping only those which have both finaid and application data

misstable patterns isinapplication  isinacs  isinfinaid isincompletion keep

//keep if keep == 1


merge m:1 zcta year using "${filepath}/data_clean/ACS_formerge.dta", gen(analytic_acs_merge)
drop if analytic_acs_merge == 2 // dropping ACS zcta's that were unmerged.


	
*Update every PCA	
	
*Creating variable list
	vl clear
	vl create vl_finaidvars = (primary_efc_parent primary_efc_student finaid_dependent_dummy first_gen_dummy pell_offer_dummy)
	
	label var primary_efc_parent "Parent EFC"
	label var primary_efc_student "Student EFC"
	label var finaid_dependent_dummy "Dummy: student is dependent"
	label var first_gen_dummy "Dummy: student is first gen"
	label var pell_offer_dummy "Dummy: student offered pell"
	
	
	vl create vl_acsvars = (s1901_c01_012_estimate s1701_c03_001_estimate s1501_c02_015_estimate s1701_c03_035_estimate)
	
	
	label var s1901_c01_012_estimate "HHS median income ($)"
	label var s1701_c03_001_estimate "Pct. Pop. below poverty"
	label var s1501_c02_015_estimate "Pct. pop. >=25 with BA+"
	label var s1701_c03_035_estimate "Pct. of FT employed 16+ y/o below poverty"
	
	//for section 2 variables
	vl create vl_schoolagepoverty = (s1701_c03_004) // for share of HS in poverty
	label var s1701_c03_004 "Pct. of school-age children 5-17 who are in poverty"
	
	//missigness of initial vars
	mdesc $vl_finaidvars $vl_acsvars $vl_schoolagepoverty
	
*************************************************
	//Finaid + ACS
*************************************************
	//running pca
	pca $vl_finaidvars $vl_acsvars $vl_schoolagepoverty
	//generating components
	predict component1 component2 component3, score
	egen pca_fa_acs_c1 = std(component1)
	egen pca_fa_acs_c2 = std(component2)
	egen pca_fa_acs_c3 = std(component3)
	//labels
	label var pca_fa_acs_c1 "Compnt. 1 (std) Finaid+ACS PCA"
	label var pca_fa_acs_c2 "Compnt. 2 (std) Finaid+ACS PCA"
	label var pca_fa_acs_c3 "Compnt. 3 (std) Finaid+ACS PCA"
	drop component1 component2 component3
	//making varlist
	vl create vl_pca_combined_components = (pca_fa_acs_c1 pca_fa_acs_c2 pca_fa_acs_c3)
	
	desc $vl_finaidvars $vl_acsvars $vl_schoolagepoverty
	screeplot, ci yline(1) title("(${S_DATE})PCA Eigenvalues of Finaid+ACS")
	graph export "${filepath}/figures/pca_acs_finaidscreeplot_${S_DATE}.png", replace

*************************************************
	//Finaid ONLY
/* 
3/22 - Predicted components 1,2 and then standardized
     - Checking missingess of EFC parent and student.
*/
*************************************************
	pca $vl_finaidvars
	//predicting and standardizing components
	predict component1 component2, score
	egen pca_fa_only_c1 = std(component1)
	egen pca_fa_only_c2 = std(component2)
	label var pca_fa_only_c1 "Std. 1st component of Finaid only PCA"
	label var pca_fa_only_c2 "Std. 2nd component of Finaid only PCA"
	drop component1 component2
	
	//making varlist
	vl create vl_pca_finaid_components = (pca_fa_only_c1 pca_fa_only_c2)
	
	desc $vl_finaidvars
	screeplot, ci yline(1) title("(${S_DATE})PCA Eigenvalues of Finaid ONLY")
	graph export "${filepath}/figures/pca_finaid_only_screeplot_${S_DATE}.png", replace


*************************************************
* Merging in ACS only components
*************************************************
	merge m:1 zcta year using "${filepath}/data_clean/acsonlypcavalues.dta", gen(merge5_acspcavals)
	drop if merge5_acspcavals == 2 //dropping rows from acs data that did not merge 
	
	vl create vl_pca_acs_components = (pca_acs_only_c1)

