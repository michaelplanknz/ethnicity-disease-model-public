epiData.csv is a CSV data file containing a table with the following fields:
* t - date from 1 Jan 2022 to 31 Dec 2024
* nCases_M_i, nCases_P_i, nCases_A_i, nCases_O_i - daily number of reported Covid-19 cases in age group i for Maori, Pacific, Asian, and European/other ethnicity groups respectively.
* nHosp_M_i, nHosp_P_i, nHosp_A_i, nHosp_O_i - daily number of new Covid-19 related hospital admissions cases in age group i for Maori, Pacific, Asian, and European/other ethnicity groups respectively.
* nDeaths_M_i, nDeaths_P_i, nDeaths_A_i, nDeaths_O_i - daily number of Covid-19-attributed deaths in age group i for Maori, Pacific, Asian, and European/other ethnicity groups respectively.

There are 16 age groups: 0-4 years, 5-9 years, ..., 70-74 years, 75 years and older.

Data was received from Te Whatu Ora on 14 Jan 2025 and this extract was created on 24 Jan 2025.

Note: this data includes imputed ethnicity data in cases where this was missing. Details below.

==================================================================================================================================================

Creating MPAO ethnicity variable...  ...45905 MELAA records classified as Euro/other

Using NHI ethnicity field where available to fill 16816 unknowns as: 
   512 Maori
   390 Pacific Peoples
   2054 Asian
   4857 European -> (European or Other)
   280 MELAA     -> (European or Other)
   218 Other     -> (European or Other)
leaving 8505 unknown

Found 8505 (0.3%) cases with unknown ethnicity
Imputed ethnicity data for 8505/8505 cases (8493 with fine match @ 4008.6 matches per case, 12 with coarse match @ 1649.8 matches per case)
Leaving 0 cases with unknown ethnicity, assuming to be European or Other

==================================================================================================================================================






