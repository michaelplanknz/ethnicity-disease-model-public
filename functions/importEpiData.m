function epiData = importEpiData(fName)

% Import date on cases, hopsital admissions and deaths from epiData.csv and
% make a table

% Import data
tbl = readtable(fName);

% Date variable
epiData.date = tbl.t;

% For each ethnicity (MPAO), create an n x 16 array from the 16 columns
% representing case counts in 16 age groups
epiData.nCases_M = [tbl.nCases_M_1, tbl.nCases_M_2, tbl.nCases_M_3, tbl.nCases_M_4, tbl.nCases_M_5, tbl.nCases_M_6, tbl.nCases_M_7, tbl.nCases_M_8, tbl.nCases_M_9, tbl.nCases_M_10, tbl.nCases_M_11, tbl.nCases_M_12, tbl.nCases_M_13, tbl.nCases_M_14, tbl.nCases_M_15, tbl.nCases_M_16];
epiData.nCases_P = [tbl.nCases_P_1, tbl.nCases_P_2, tbl.nCases_P_3, tbl.nCases_P_4, tbl.nCases_P_5, tbl.nCases_P_6, tbl.nCases_P_7, tbl.nCases_P_8, tbl.nCases_P_9, tbl.nCases_P_10, tbl.nCases_P_11, tbl.nCases_P_12, tbl.nCases_P_13, tbl.nCases_P_14, tbl.nCases_P_15, tbl.nCases_P_16];
epiData.nCases_A = [tbl.nCases_A_1, tbl.nCases_A_2, tbl.nCases_A_3, tbl.nCases_A_4, tbl.nCases_A_5, tbl.nCases_A_6, tbl.nCases_A_7, tbl.nCases_A_8, tbl.nCases_A_9, tbl.nCases_A_10, tbl.nCases_A_11, tbl.nCases_A_12, tbl.nCases_A_13, tbl.nCases_A_14, tbl.nCases_A_15, tbl.nCases_A_16];
epiData.nCases_O = [tbl.nCases_O_1, tbl.nCases_O_2, tbl.nCases_O_3, tbl.nCases_O_4, tbl.nCases_O_5, tbl.nCases_O_6, tbl.nCases_O_7, tbl.nCases_O_8, tbl.nCases_O_9, tbl.nCases_O_10, tbl.nCases_O_11, tbl.nCases_O_12, tbl.nCases_O_13, tbl.nCases_O_14, tbl.nCases_O_15, tbl.nCases_O_16];

% Do the same for admissions
epiData.nHosp_M = [tbl.nHosp_M_1, tbl.nHosp_M_2, tbl.nHosp_M_3, tbl.nHosp_M_4, tbl.nHosp_M_5, tbl.nHosp_M_6, tbl.nHosp_M_7, tbl.nHosp_M_8, tbl.nHosp_M_9, tbl.nHosp_M_10, tbl.nHosp_M_11, tbl.nHosp_M_12, tbl.nHosp_M_13, tbl.nHosp_M_14, tbl.nHosp_M_15, tbl.nHosp_M_16];
epiData.nHosp_P = [tbl.nHosp_P_1, tbl.nHosp_P_2, tbl.nHosp_P_3, tbl.nHosp_P_4, tbl.nHosp_P_5, tbl.nHosp_P_6, tbl.nHosp_P_7, tbl.nHosp_P_8, tbl.nHosp_P_9, tbl.nHosp_P_10, tbl.nHosp_P_11, tbl.nHosp_P_12, tbl.nHosp_P_13, tbl.nHosp_P_14, tbl.nHosp_P_15, tbl.nHosp_P_16];
epiData.nHosp_A = [tbl.nHosp_A_1, tbl.nHosp_A_2, tbl.nHosp_A_3, tbl.nHosp_A_4, tbl.nHosp_A_5, tbl.nHosp_A_6, tbl.nHosp_A_7, tbl.nHosp_A_8, tbl.nHosp_A_9, tbl.nHosp_A_10, tbl.nHosp_A_11, tbl.nHosp_A_12, tbl.nHosp_A_13, tbl.nHosp_A_14, tbl.nHosp_A_15, tbl.nHosp_A_16];
epiData.nHosp_O = [tbl.nHosp_O_1, tbl.nHosp_O_2, tbl.nHosp_O_3, tbl.nHosp_O_4, tbl.nHosp_O_5, tbl.nHosp_O_6, tbl.nHosp_O_7, tbl.nHosp_O_8, tbl.nHosp_O_9, tbl.nHosp_O_10, tbl.nHosp_O_11, tbl.nHosp_O_12, tbl.nHosp_O_13, tbl.nHosp_O_14, tbl.nHosp_O_15, tbl.nHosp_O_16];

% Do the same for deaths
epiData.nDeaths_M = [tbl.nDeaths_M_1, tbl.nDeaths_M_2, tbl.nDeaths_M_3, tbl.nDeaths_M_4, tbl.nDeaths_M_5, tbl.nDeaths_M_6, tbl.nDeaths_M_7, tbl.nDeaths_M_8, tbl.nDeaths_M_9, tbl.nDeaths_M_10, tbl.nDeaths_M_11, tbl.nDeaths_M_12, tbl.nDeaths_M_13, tbl.nDeaths_M_14, tbl.nDeaths_M_15, tbl.nDeaths_M_16];
epiData.nDeaths_P = [tbl.nDeaths_P_1, tbl.nDeaths_P_2, tbl.nDeaths_P_3, tbl.nDeaths_P_4, tbl.nDeaths_P_5, tbl.nDeaths_P_6, tbl.nDeaths_P_7, tbl.nDeaths_P_8, tbl.nDeaths_P_9, tbl.nDeaths_P_10, tbl.nDeaths_P_11, tbl.nDeaths_P_12, tbl.nDeaths_P_13, tbl.nDeaths_P_14, tbl.nDeaths_P_15, tbl.nDeaths_P_16];
epiData.nDeaths_A = [tbl.nDeaths_A_1, tbl.nDeaths_A_2, tbl.nDeaths_A_3, tbl.nDeaths_A_4, tbl.nDeaths_A_5, tbl.nDeaths_A_6, tbl.nDeaths_A_7, tbl.nDeaths_A_8, tbl.nDeaths_A_9, tbl.nDeaths_A_10, tbl.nDeaths_A_11, tbl.nDeaths_A_12, tbl.nDeaths_A_13, tbl.nDeaths_A_14, tbl.nDeaths_A_15, tbl.nDeaths_A_16];
epiData.nDeaths_O = [tbl.nDeaths_O_1, tbl.nDeaths_O_2, tbl.nDeaths_O_3, tbl.nDeaths_O_4, tbl.nDeaths_O_5, tbl.nDeaths_O_6, tbl.nDeaths_O_7, tbl.nDeaths_O_8, tbl.nDeaths_O_9, tbl.nDeaths_O_10, tbl.nDeaths_O_11, tbl.nDeaths_O_12, tbl.nDeaths_O_13, tbl.nDeaths_O_14, tbl.nDeaths_O_15, tbl.nDeaths_O_16];


% Convert from structure to table
epiData = struct2table(epiData);


