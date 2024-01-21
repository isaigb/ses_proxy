###############################################
# Script for downloading ACS data using tidycensus
# Author: Isai Garcia-Baza
###############################################

#Library
library(tidycensus)
library(tidyverse)
library(foreign)

#Loading variables and table names
acs_vars_19_subject <- load_variables(2019, "acs5/subject", cache = TRUE)


# TODO: make a function or rework this code to loop over values and subject tables

# s1901 variables
#Loop iterates from 2015 to 2020, creates a new object per year called s1501_acs5_YEAR, and then calls the data in
for(i in 2015:2020) {
  assign(paste("s1901_acs5_", eval(i), sep = ""), 
         get_acs(geography = "zcta", 
                 table = "S1901", 
                 year = eval(i), 
                 survey = "acs5", 
                 show_call = TRUE, 
                 cache_table = TRUE))
}

#Adding year column
s1901_acs5_2015['year'] <- 2015
s1901_acs5_2016['year'] <- 2016
s1901_acs5_2017['year'] <- 2017
s1901_acs5_2018['year'] <- 2018
s1901_acs5_2019['year'] <- 2019
s1901_acs5_2020['year'] <- 2020
#Appending all files then dropping
s1901_acs5_appended <- bind_rows(s1901_acs5_2015, s1901_acs5_2016, s1901_acs5_2017, s1901_acs5_2018, 
                                 s1901_acs5_2019, s1901_acs5_2020)
rm(s1901_acs5_2015, s1901_acs5_2016, s1901_acs5_2017, s1901_acs5_2018, s1901_acs5_2019, s1901_acs5_2020)

#Using pivot_wider() to widen the dataset
tempacs <- s1901_acs5_appended
s1901_acs5_appended <- pivot_wider(tempacs, 
                                 id_cols = c(GEOID, year), 
                                 names_from = variable, 
                                 values_from = c(estimate, moe),
                                 names_glue = "{variable}_{.value}")
rm(tempacs)




# s1501 variables
#Loop iterates from 2015 to 2020, creates a new object per year called s1501_acs5_YEAR, and then calls the data in
for(i in 2015:2020) {
  assign(paste("s1501_acs5_", eval(i), sep = ""), 
         get_acs(geography = "zcta", 
                 table = "S1501", 
                 year = eval(i), 
                 survey = "acs5", 
                 show_call = TRUE, 
                 cache_table = TRUE))
}
#Adding year column (couldn't figure out how to loop this)
s1501_acs5_2015['year'] <- 2015
s1501_acs5_2016['year'] <- 2016
s1501_acs5_2017['year'] <- 2017
s1501_acs5_2018['year'] <- 2018
s1501_acs5_2019['year'] <- 2019
s1501_acs5_2020['year'] <- 2020
#Appending all files
s1501_acs5_appended <- bind_rows(s1501_acs5_2015, s1501_acs5_2016, s1501_acs5_2017, s1501_acs5_2018, 
                                 s1501_acs5_2019, s1501_acs5_2020)
rm(s1501_acs5_2015, s1501_acs5_2016, s1501_acs5_2017, s1501_acs5_2018, s1501_acs5_2019, s1501_acs5_2020)

#Using pivot_wider() to widen the dataset
tempacs <- s1501_acs5_appended
s1501_acs5_appended <- pivot_wider(tempacs, 
                                 id_cols = c(GEOID, year), 
                                 names_from = variable, 
                                 values_from = c(estimate, moe),
                                 names_glue = "{variable}_{.value}")
rm(tempacs)



#s1701 variables
#Loop iterates from 2015 to 2020, creates a new object per year called s1701_acs5_YEAR, and then calls the data in
for(i in 2015:2020) {
  assign(paste("s1701_acs5_", eval(i), sep = ""), 
         get_acs(geography = "zcta", 
                 table = "S1701", 
                 year = eval(i), 
                 survey = "acs5", 
                 show_call = TRUE, 
                 cache_table = TRUE))
}
#Adding year column (couldn't figure out how to loop this)
s1701_acs5_2015['year'] <- 2015
s1701_acs5_2016['year'] <- 2016
s1701_acs5_2017['year'] <- 2017
s1701_acs5_2018['year'] <- 2018
s1701_acs5_2019['year'] <- 2019
s1701_acs5_2020['year'] <- 2020
#Appending all files
s1701_acs5_appended <- bind_rows(s1701_acs5_2015, s1701_acs5_2016, s1701_acs5_2017, s1701_acs5_2018, 
                               s1701_acs5_2019, s1701_acs5_2020)
rm(s1701_acs5_2015, s1701_acs5_2016, s1701_acs5_2017, s1701_acs5_2018, s1701_acs5_2019, s1701_acs5_2020)

#Using pivot_wider() to widen the dataset
tempacs <- s1701_acs5_appended
s1701_acs5_appended <- pivot_wider(tempacs, 
                                 id_cols = c(GEOID, year), 
                                 names_from = variable, 
                                 values_from = c(estimate, moe),
                                 names_glue = "{variable}_{.value}")
rm(tempacs)



#s2502 variables
#Loop iterates from 2015 to 2020, creates a new object per year called s2502_acs5_YEAR, and then calls the data in
for(i in 2015:2020) {
  assign(paste("s2502_acs5_", eval(i), sep = ""), 
         get_acs(geography = "zcta", 
                 table = "S2502", 
                 year = eval(i), 
                 survey = "acs5", 
                 show_call = TRUE, 
                 cache_table = TRUE))
}
#Adding year column (couldn't figure out how to loop this)
s2502_acs5_2015['year'] <- 2015
s2502_acs5_2016['year'] <- 2016
s2502_acs5_2017['year'] <- 2017
s2502_acs5_2018['year'] <- 2018
s2502_acs5_2019['year'] <- 2019
s2502_acs5_2020['year'] <- 2020
#Appending all files
s2502_acs5_appended <- bind_rows(s2502_acs5_2015, s2502_acs5_2016, s2502_acs5_2017, s2502_acs5_2018, 
                               s2502_acs5_2019, s2502_acs5_2020)
rm(s2502_acs5_2015, s2502_acs5_2016, s2502_acs5_2017, s2502_acs5_2018, s2502_acs5_2019, s2502_acs5_2020)

#Using pivot_wider() to widen the dataset
tempacs <- s2502_acs5_appended
s2502_acs5_appended <- pivot_wider(tempacs, 
                                 id_cols = c(GEOID, year), 
                                 names_from = variable, 
                                 values_from = c(estimate, moe),
                                 names_glue = "{variable}_{.value}")
rm(tempacs)



# Combining all frames and exporting to Stata

#must now leftjoin using geoid and year
fullacs <- full_join(s1901_acs5_appended, s1701_acs5_appended, by = c("GEOID", "year"))
fullacs <- full_join(fullacs, s1501_acs5_appended, by = c("GEOID", "year"))
fullacs <- full_join(fullacs, s2502_acs5_appended, by = c("GEOID", "year"))

#Exporting as Stata .dta
write.dta(fullacs, 
          file = "acs5_2015to2020.dta",
          version = 10)

#Exporting as CSV
write.csv(fullacs, 
          na= ".", 
          file = "acs5_2015to2020.csv")

#Removing old files
rm(s1501_acs5_appended, s1701_acs5_appended, s1901_acs5_appended, s2502_acs5_appended)



#Exporting variable labels
acs_vars_19 <- load_variables(2019, "acs5/subject", cache = TRUE)
acs_vars_s1901 <- filter(acs_vars_19, grepl('S1901', name))
acs_vars_s1701 <- filter(acs_vars_19, grepl('S1701', name))
acs_vars_s1501 <- filter(acs_vars_19, grepl('S1501', name))
acs_vars_s2502 <- filter(acs_vars_19, grepl('S2502', name))
acs_vars_labels <- bind_rows(acs_vars_s1901, acs_vars_s1701, acs_vars_s1501, acs_vars_s2502)
rm(acs_vars_s1901, acs_vars_s1701, acs_vars_s1501, acs_vars_s2502) #removing no longer needed
write.csv(acs_vars_labels, file = "acs_vars_labels.csv")

# end