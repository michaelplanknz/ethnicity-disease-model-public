function [myDataPath, dataFileNames] = getDataFileNames(sensitivity)

myDataPath = 'data/';

dataFileNames.epiDataFname =  "epidata.csv";    % Ethnicity and age-specific data for cases, admissions and deaths 

dataFileNames.vaxDataFname = "vaccine_data_national_2023-06-06";              % Vax data (all ethnicities aggregated)
dataFileNames.vaxDataEuropeanFname = "vaccine_data_EuropeanOther_2023-06-06";              % Vax data (European)
dataFileNames.vaxDataMaoriFname = "vaccine_data_Maori_2023-06-06";              % Vax data (Maori)
dataFileNames.vaxDataPacificFname = "vaccine_data_Pacific_2023-06-06";              % Vax data (Pacific)
dataFileNames.vaxDataAsianFname = "vaccine_data_Asian_2023-06-06";              % Vax data (Asian)

dataFileNames.AVdataFname = "therapeutics_by_age_14-Aug-2023.mat";            % Antiviral data
dataFileNames.hospOccFname = "covid-cases-in-hospital-counts-location-16-Aug-2023.xlsx";           % Only used for plotting
if ~sensitivity
    dataFileNames.popSizeFname = "HSU_by_age_eth.csv";                         % NZ population structure (HSU)
else
    dataFileNames.popSizeFname = "TWO_pop_2021.csv";                         % NZ population structure (Stats NZ projections from TWO web tool https://tewhatuora.shinyapps.io/populations-web-tool/)
end
dataFileNames.CMdataFname = "nzcontmatrix.xlsx";                              % Prem contact matrix
dataFileNames.borderIncFname = "border_incidence.csv";

