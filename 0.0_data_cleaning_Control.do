********************************************************************
/*
Author: Isai Garcia-Baza

Purpose: This file controls ALL do files needed to construct and evaluate the 
SES proxy measure and should be run in its entirety.
*/
********************************************************************


********************************************************************
* 0 Setup *
********************************************************************

clear all
version 17.0
capture log close
set more off
	
* Set file path
global filepath "/proj/ncefi/uncso/projects/sesproxy"

global rawdata "/proj/ncefi/uncso/rawdata-stata/new_uncso_data"


********************************************************************
* 1 Cleaning the data *
********************************************************************
*Log setup
global logname "sesproxy_datacleanlog_${S_DATE}"
log using "${filepath}/logs/${logname}", replace
set linesize 200


* Time Stamp
di "Log begins on $S_DATE at $S_TIME."


* Running file that cleans ACS data
do "${filepath}/do_files/0.1_clean_acs.do"


* Running file that cleans career data
do "${filepath}/do_files/0.1_clean_career.do"


* Running file that cleans completion data
do "${filepath}/do_files/0.1_clean_completion.do"


* Running file that cleans finaid data
do "${filepath}/do_files/0.1_clean_finaid.do"


* Running files that clean zip2zcta then application since it depends on zip2zcta
do "${filepath}/do_files/0.1_clean_zip2zcta.do"
do "${filepath}/do_files/0.1_clean_application.do"


* Making analytic file by merging the above
do "${filepath}/do_files/0.2_make_analytic.do"


*closing log and saving as pdf
log close
	
	//settings to change pagesize and font in output
	translator set smcl2pdf pagesize custom
        translator set smcl2pdf pagewidth 11.0
        translator set smcl2pdf pageheight 8.5
	translator set smcl2pdf fontsize 8
	    
	translate "${filepath}/logs/${logname}.smcl" "${filepath}/logs/${logname}.pdf", replace

	
********************************************************************
* 2 Making PCA *
********************************************************************
* Log setup
global logname "sesproxy_make_pca_log_${S_DATE}"
log using "${filepath}/logs/${logname}", replace
set linesize 200

* Making PCA components
do "${filepath}/do_files/1.0_make_pca.do"

*closing log and saving as pdf
log close
	
	//settings to change pagesize and font in output
	translator set smcl2pdf pagesize custom
        translator set smcl2pdf pagewidth 11.0
        translator set smcl2pdf pageheight 8.5
	translator set smcl2pdf fontsize 8
	    
	translate "${filepath}/logs/${logname}.smcl" "${filepath}/logs/${logname}.pdf", replace

	
********************************************************************
* 3 Analyzing PCA performance *
********************************************************************
* Log setup
global logname "sesproxy_pca_analysis_log_${S_DATE}"
log using "${filepath}/logs/${logname}", replace
set linesize 200

* Making PCA components
do "${filepath}/do_files/2.0_pca_analysis.do"

*closing log and saving as pdf
log close
	
	//settings to change pagesize and font in output
	translator set smcl2pdf pagesize custom
        translator set smcl2pdf pagewidth 11.0
        translator set smcl2pdf pageheight 8.5
	translator set smcl2pdf fontsize 8
	    
	translate "${filepath}/logs/${logname}.smcl" "${filepath}/logs/${logname}.pdf", replace
