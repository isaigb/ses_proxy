# SES Proxy
The goal of this project was to develop a proxy measure for socioeconomic status using the Census' publicly available American Community Survey (ACS) data. A technical memo is currently in progress and will be linked to from here once it is completed and published online.

Because I currently work primarily with Stata users, the Stata code found here serves as ground truth for what I did for this project and will be the code that will remain with the research team moving forward. There is also an R script that downloads ACS data from the Census API.

## Organization
The Stata folder contains Stata code used to clean the data, generate PCA components, and measure the success of the proxy variable(s). The `0.0_data_cleaning_Control.do` runs the project from start to finish and calls in the appropriate do files when necessary.

The R folder houses the script that downloads the ACS 5-year estimates for 2015-2020.

TODO:
 - Add PCA analysis `.do` file
 - Add Python code for generating proxy using PCA

Python folder is currently a work in progress and will house Python code that downloads ACS data and generates the proxy variables within a single module.

## Setting Up for R and Stata

- Run the R script that downloads ACS data and exports to Stata dta file. Ensure you have `tidycensus`, `tidyverse`, and `foreign` packages installed.
- Download zip code to ZCTA crosswalk files for years 2015-2020 from https://udsmapper.org/zip-code-to-zcta-crosswalk/
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