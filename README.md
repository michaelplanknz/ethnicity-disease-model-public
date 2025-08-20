# Modelling the transmission and impact of Omicron variants of Covid-19 in different ethnicity groups in Aotearoa New Zealand

# 1. Overview

This repository contains the code for the project 'Modelling the transmission and impact of Omicron variants of Covid-19 in different ethnicity groups in Aotearoa New Zealand'.

The model and code build on earlier work modelling Covid-19 in New Zealand that is described in publications by [Lustig et al. (2023)](https://doi.org/10.1098/rsif.2022.0698) and [Datta et al. (2024)](https://doi.org/10.1016/j.vaccine.2024.01.101).

The key advance in the current work is to stratify the population into four ethnicity groups and model different levels of disease transmission and impact across those groups.

A preprint of the article is available here.


Results in this version were produced using the version of this repo tagged 'v1.0'.
The code was run using Matlab version 2022b.


# 2. Repository structure

The main script that runs the model is `main.m` in the top level of the repository.

Here is a list and description of the folders in the repository:
* **functions**: this folder contains all Matlab functions used to run the main script.
* **data**: this is where the data files needed to run the script are kept, see the table below for a full list.
* **parameter_fitting_results**: this folder contains a Matlab data file containing the results of the previous model fitting and parameter estimation procedure, using the non-ethnicity-stratified model. 
* **output**: this folder contains output files containing model results (these files are read back in for plotting purposes).
* **figures**: the plotting script will save a series of Figures in this directory (in the subdirectory `HSU` for the standard model runs, and in the subdirectory `ERP` for the sensitivity analysis that uses the ERP population data). 

The model reads in data from the following files in the `data/` folder.

|Filename|Description|
|--------------------|-----|
|*epiData.csv*| Data on the daily number of reported Covid-19 cases, new Covid-19 hospital admissions and Covid-19-attributed deaths on each date, stratified by 5-year age group and ethnicity. Note: this dataset cannot be published due for confidentiality reasons and can be requested from Te Whatu Ora Health New Zealand at: data-enquiries@tewhatuora.govt.nz |
|*vaccine_data_national_[YYYY-MM-DD].csv*| Cumulative total number of 1st, 2nd, 3rd and 4th or subsequent vaccine doses given by date and 5-year age band, as at date YYYY-MM-DD. |
|*vaccine_data_[ETHNICITY]_[YYYY-MM-DD].csv*| Cumulative number of 1st, 2nd, 3rd and 4th or subsequent vaccine doses given by date and 5-year age band for people in the given ETHNICITY group, either Māori, Pacific, Asian or European/other, as at date YYYY-MM-DD. |
|*therapeutics_by_age_[DD-MMM-YYYY].mat*| Ministry of Health data for the number of cases with an antiviral prescription in 5-year age groups over time, as at date DD-MMM-YYYY. |
|*covid-cases-in-hospital-counts-location-[DD-MMM-YYYY].xlsx*| Data from file *covid-cases-in-hospital-counts-location.xlsx* file in the *nz-covid-data/cases/* folder of the [MOH Github repo](https://github.com/minhealthnz/nz-covid-data/tree/main/cases), as at date DD-MMM-YYYY.| 
|*border_incidence.xlsx*|  Data collected by M. Plank on the weekly incidence of new infections reported in a routinely tested cohort of border workers in 2022 and stored in [this GitHub page](https://github.com/michaelplanknz/modelling-ba5-in-nz). |
|*nzcontmatrix.xlsx*| Age-structured contact matrix taken from the paper 'Projecting social contact matrices in 152 countries using contact surveys and demographic data' by [Prem et al.](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005697) (specifically the overall age-and-location-specific contact matrix for New Zealand). |
|*HSU_by_age_eth.csv*| Population size estmiates by prioritised ethnicity in 5-year age bands (HSU population 2022) |
|*popproj2018-21.csv*| Population size estmiates by prioritised ethnicity in 5-year age bands (StatsNZ projected population for 2021 - see [here](https://www.tepou.co.nz/resources/dhb-population-profiles-2021-2031-pdf) ). |

Note: epiData.csv is a CSV data file containing a table with the following fields:
* t - date from 1 Jan 2022 to 31 Dec 2024
* nCases_M_i, nCases_P_i, nCases_A_i, nCases_O_i - daily number of reported Covid-19 cases in age group i for Maori, Pacific, Asian, and European/other ethnicity groups respectively.
* nHosp_M_i, nHosp_P_i, nHosp_A_i, nHosp_O_i - daily number of new Covid-19 related hospital admissions cases in age group i for Maori, Pacific, Asian, and European/other ethnicity groups respectively.
* nDeaths_M_i, nDeaths_P_i, nDeaths_A_i, nDeaths_O_i - daily number of Covid-19-attributed deaths in age group i for Maori, Pacific, Asian, and European/other ethnicity groups respectively.

There are 16 age groups: 0-4 years, 5-9 years, ..., 70-74 years, 75 years and older.

Data was received from Te Whatu Ora on 14 Jan 2025 and this extract was created on 24 Jan 2025.



# 3. How to run the model

Set the current directory to the repository's root folder and run the script `main.m`.

This reads in a set of parameter combinations from the previous model fitting procedure. It then runs the model for each parameter combination, under the five scenarios described in the article:
1. Baseline scenario (no ethnicity effects).
2. Ethncitiy-specific vaccination data.
3. Ethncitiy-specific vaccination data and clinical severity parameters.
4. Ethncitiy-specific vaccination data and contact rates.
5. Ethncitiy-specific vaccination data, clinical severity parameters and contact rates.

For each scenario, two output files are saved in the `output/` folder:
* Scenario_[i]_[NAME]_Best_fit.mat
* Scenario_[i]_[NAME]_95_fit.mat
where i the the scenario number and NAME is the scenario name.

The first of these files contains outputs from a single model trajectory using the posterior mean parameter values. 

The second of these files contains outputs from a set of model trajectories, representing a 95% credible range for model outputs. 




# 4. How to make the plots

Run the top-level script `plotGraphs.m`.

This reads in the results generated in the previous step from the `output/` folder, makes a selection of plots, and saves them in the `figures/` folder.

Other graph-plotting scripts that can be run are:
* plotEpiData.m - plots the data on cases, admissions and deaths by age and ethnicity group.
* plotVaccineData.m - plots the cumulative number of vaccine doses by age and ethicity group.

Both of these scripts read the relevant data files in from the `data/` folder.



# 5. Sensitivity analysis on population size data

To run the model using the Statistics NZ ERP data instead of the HSU population data, set the flag `sensitivity` in `main.m` and in `plotGraphs.m` to true.
The output file names for this run will be appended with `sensitivity` and the plots will be saved in the `figures/ERP/` subfolder.

Difference scenarios can be explored by changing the scenario-specific parameters that are returned by the function `getScenarioPars` (see Table of variable names below).


# 6. Key variable names and conventions

There are 16 five-year age groups and 4 ethnicity groups.

By convention the ethncity group are always ordered: [European, Māori, Pacific, Asian].

Vectors of the 64 age-ethnicity combinations are ordered: [Euro age group 1, Euro age group 2, ..., Euro age group 16, Māori age group i, ..., Māori age group 16, Pacific age group 1, ..., Pacific age group 16, Asian age gorup 1, ... Asian age group 16].

|Variable|Description|
|--------------------|-----|
|useEthVaxData|Set to true to use the four ethnicity-specific vaccination data files, or false to the national vaccination data file and distribute vaccine doses across ethnicity groups according to their population sizes (in any given age group)|
|assort|Assortativity constant, taking a value between 0 and 1. A value of 0 corresponds to proportionate mixing, a value of 1 corresponds to mixing strictly within ethnicity groups|
|totalContFreq|Vector specifying the relative total contact rate for each ethnicity group - set to [1, 1, 1, 1] for no ethnicity-specific effects on total contact rates|
|OR_hosp|Vector of odds ratios for hospitalisation for each ethnicity group - set to [1, 1, 1, 1] for no ethnicity-specific effects on risk of hospitalisation|
|OR_death|Vector of odds ratios for death for each ethnicity group - set to [1, 1, 1, 1] for no ethnicity-specific effects on risk of death|
|Rt_mult|Multiplier on the model reproduction number - this is set to 1 in all model scenarios in the paper, but is included to allow different reproduction numbers to be explored|
|popCountMatrix|Matrix whose (i,j) element is the population size in 5-year age group i and ethnicity group j|
|popCountVector|Columns of popCountMatrix concatenated vertically to give a 64x1 vector of population sizes in each age-ethicity combination|
|popByEth|Vector of population sizes in each ethnicity group, aggregated over age|
|popByAge|Vector of population size in each age group, aggregated over ethnicity|
|popCountMatrix10|Similar to popCountMatrix but using 10-year age groups to give an 8x4 matrix|


