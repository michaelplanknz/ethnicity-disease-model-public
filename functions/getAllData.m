function dataComb = getAllData(myDataPath, dataFileNames)
% Function that reads in data on daily cases, daily hospital admissions,
% daily deaths, hospital occupancy, and border incidence. Data is split by
% vaccination status and age group
% INPUTS:
% - myDataPath: path to folder containing data
% - dataFileNames: structure with the following fields
%       - epiDataFname: filename of cases, hosp. admissions and deaths datafile
%       - hospOccFname: filename of hosp occupancy datafile
%       - borderIncFname: filename of border incidence datafile
% OUTPUT:
% - dataComb: table containing all data combined



% Import epi data on COVID cases, hosp. admissions and deaths
fName = myDataPath + dataFileNames.epiDataFname;
epiData = importEpiData(fName);


% Create new fields for total daily cases and deaths
epiData.nCasesData = sum(epiData.nCases_O + epiData.nCases_M + epiData.nCases_P + epiData.nCases_A, 2);
epiData.nHospData = sum(epiData.nHosp_O + epiData.nHosp_M + epiData.nHosp_P + epiData.nHosp_A, 2);
epiData.nDeathsData = sum(epiData.nDeaths_O + epiData.nDeaths_M + epiData.nDeaths_P + epiData.nDeaths_A, 2);

% By ethnicity
epiData.nCases_O_overall = sum(epiData.nCases_O, 2);
epiData.nCases_M_overall = sum(epiData.nCases_M, 2);
epiData.nCases_P_overall = sum(epiData.nCases_P, 2);
epiData.nCases_A_overall = sum(epiData.nCases_A, 2);
epiData.nHosp_O_overall = sum(epiData.nHosp_O, 2);
epiData.nHosp_M_overall = sum(epiData.nHosp_M, 2);
epiData.nHosp_P_overall = sum(epiData.nHosp_P, 2);
epiData.nHosp_A_overall = sum(epiData.nHosp_A, 2);
epiData.nDeaths_O_overall = sum(epiData.nDeaths_O, 2);
epiData.nDeaths_M_overall = sum(epiData.nDeaths_M, 2);
epiData.nDeaths_P_overall = sum(epiData.nDeaths_P, 2);
epiData.nDeaths_A_overall = sum(epiData.nDeaths_A, 2);

% Importing data on hospital occupancy
fName = myDataPath + dataFileNames.hospOccFname;
hospData = readtable(fName, "Sheet", "NZ total");
hospData.Properties.VariableNames = ["date", "hospOccTotalMOH"];
hospData = hospData(datenum(hospData.date) >= datenum('25JAN2022'), :);
hospData.hospOccTotalMOH = str2double(hospData.hospOccTotalMOH);

% Importing data on incidence in border workers
fName = myDataPath + dataFileNames.borderIncFname;
borderData = readtable(fName);
borderData.WeekEnding = datetime(string(borderData.WeekEnding));
borderData = borderData(~isnat(borderData.WeekEnding), :);
borderData.date = borderData.WeekEnding-7;          % Tests week ending X roughly indicative of new infections around X-7

% Merge into one table
tmp = outerjoin(epiData, hospData, 'Keys', 'date', 'MergeKeys', true);
dataComb = outerjoin(tmp, borderData, 'Keys', 'date', 'MergeKeys', true);



end


