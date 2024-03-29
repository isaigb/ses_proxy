# SES Proxy
The goal of this project was to develop a proxy measure for socioeconomic status using the Census' publicly available American Community Survey (ACS) data. The proxy is intended for use in higher education research where zip code data are available but financial aid/income data are not. A technical memo is currently in progress and will be linked to from here once it is completed and published online.

This project initially started out from data restrictions surrounding the use of financial aid administrative data. We were tasked with exploring the feasibility of creating a proxy measure of socioeconomic status that captured characteristics such as:
 - Income
 - First generation status

And other variables that are important predictors of academic outcomes. To measure the effectiveness of this proxy we set out to estimate different models predicting key outcomes in higher education research using administrative financial aid data and comparing it to parameter estimates from regressions using our proxy measure. A good proxy measure would capture the same information contained in the financial aid data but from unrestricted sources.

Key indicators of success are:
 - Replacement of financial aid data (ground truth) with proxy does not change parameter estimate magnitude and direction across model specifications
 - $R^2$ remains similar in magnitude

We used existing literature from health policy and education to identify key variables from the US Census' American Community Survey. 

Lastly, because I currently work primarily with Stata users, the Stata code found here serves as ground truth for what I did for this project and will remain with the data management team moving forward.

## TODO
 - Add PCA analysis `.do` file
 - Add Python code for generating proxy using PCA

## Organization
The `Stata` folder contains Stata code used to clean the data, generate PCA components, and measure the success of the proxy variable(s). Data were gathered using a combination of manual downloads and the Census API using the R package `tidycensus`, see the "Setting up for R and Stata" section for more details. Once downloaded, the `0.0_data_cleaning_Control.do` runs the project from start to finish and calls in the appropriate do files when necessary.

The `R` folder houses the script that downloads the ACS 5-year estimates for 2015-2020.

`Python` folder is currently a work in progress and will house Python code that downloads ACS data and generates the proxy variables within a single module.

## Setting Up for R and Stata

- Run the R script that downloads ACS data and exports to Stata dta file. Ensure you have `tidycensus`, `tidyverse`, and `foreign` packages installed.
    - Upload files to raw data folder.
- Download zip code to ZCTA crosswalk files for years 2015-2020 from https://udsmapper.org/zip-code-to-zcta-crosswalk/
    - Upload files to raw data folder.
- Run `0.0_data_cleaning_Control.do` in Stata.

## Setting up for Python using Anaconda
:construction: Currently a work in progress and will be updated when it is in a more finished state.

To set up conda environment from the command line or VS Code terminal:
```
conda create -n sesproxy python=3.10.9 ipython statsmodels numpy matplotlib pandas jupyter scikit-learn conda-forge::census conda-forge::us
```

To activate the newly created environment:
```
conda activate sesproxy
```

To execute the script
```
python makeproxy.py
```