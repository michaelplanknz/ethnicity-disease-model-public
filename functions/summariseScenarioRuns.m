function [t, bandsData, bestFitData, tData, realData, popCountMatrix, ...
    popCountMatrix10, popCountVector, popByEth, popByAge] = ...
    summariseScenarioRuns(filenameBands, filenameBestFit, dataComb)
% Function that plots a grid of plots (cases, hospital
% admissions, and deaths), which include a best fit
% line, confidence bands, real data, and vertical lines representing an
% intervention date for each 10year age band

% INPUTS:
% - filenameBands: "folder/filename.mat" for bands data
% - filenameBestFit: "folder/filename.mat" for best fit data
% - dataComb: data for plotting, as output by getAllData.m

% OUTPUTS:
% - t - vector of model time points
% - bandsDataAgeAll: bands for all models by age and ethnicity
% dimensions: t * nruns * ages * ethnicities * 5 * scenarios
% 5 metrics: infections, cases, admissions, hospital occupancy
% and deaths
% - bestFitDataAgeAll: best fit for all models by age and ethnicity
% dimensions: t * ages * ethnicities * 7 * scenarios
% 7 metrics: infections, cases, admissions, hospital occupancy, deaths,
% cumulative first infections, cumulative total infections
% - tData - vector of data time points
% - realData: data formatted with dimensions: tData * ages * 14
% 14 metrics: border infection data (totals stored in the first age group),
% national hospital occupancy (totals stored in the first age group), cases
% for the 4 ethnicities, admissions for the 4 ethnicities, deaths for the 4
% ethnicities



% Go through all runs to compare

for j = 1:numel(filenameBands)

    % ----------------- IMPORT BANDS DATA -------------------------------------
    load(filenameBands{j}, 'epiVarsCompact', 'parBase');

    if j == 1 % first time around, pre-allocate large arrays
        % Bands data has the following indices:
        % 1. Time
        % 2. Trajectory number
        % 3. Age group (10 year bands)
        % 4. Ethnicity group
        % 5. Model output type: 1 = infections, 2 = cases, 3 = admissions, 4 = occupancy, 5 = deaths
        % 6. Scenario number 
        bandsData = zeros(size(epiVarsCompact(1).N, 1), numel(epiVarsCompact), ...
            parBase.nAgeGroups/2, parBase.nEthnicities, 5, numel(filenameBands));

        % Best fit data has the following indices:
        % 1. Time
        % 2. Age group (10 year bands)
        % 3. Ethnicity group
        % 4. Model output type: 1 = infections, 2 = cases, 3 = admissions, 4 = occupancy, 5 = deaths, 6 = cumulative first infections, 7 = cumulative first infectoins plus reinfectoins
        % 5. Scenario number         
        bestFitData = zeros(size(epiVarsCompact(1).N, 1), parBase.nAgeGroups/2, ...
            parBase.nEthnicities, 7, numel(filenameBands));
    end

    % Get variables for plotting
  [newDailyCases0, newDailyCases1, newDailyCases2, newDailyCases3, ...
        newDailyCasesr, newDailyHosp0, newDailyHosp1, newDailyHosp2, ...
        newDailyHosp3, newDailyHospr, newDailyDeaths0, newDailyDeaths1, ...
        newDailyDeaths2, newDailyDeaths3, newDailyDeathsr, Hocc, ~, ~, E1, ...
        E2, ~, ~] = getVarsToPlot(epiVarsCompact);

    % Sum over immunity status
    newDailyCases = newDailyCases0 + newDailyCases1 + newDailyCases2 + newDailyCases3 + newDailyCasesr;
    newDailyHosp = newDailyHosp0 + newDailyHosp1 + newDailyHosp2 + newDailyHosp3 + newDailyHospr;
    newDailyDeaths = newDailyDeaths0 + newDailyDeaths1 + newDailyDeaths2 + newDailyDeaths3 + newDailyDeathsr;

    % take care of multiple ethnicities by adding extra dimension
    newDailyInfections_byEth = zeros(size(newDailyCases, 1), size(newDailyCases, 3), ...
        parBase.nAgeGroups, parBase.nEthnicities); % cases
    newDailyCases_byEth = newDailyInfections_byEth; % infections
    newDailyHosp_byEth = newDailyInfections_byEth; % hospitalisations
    hospitalOccupancy_byEth = newDailyInfections_byEth; % hospital occupancy
    newDailyDeaths_byEth = newDailyInfections_byEth; % deaths

    for i = 1:parBase.nEthnicities % go through ethnicities
        indices_pick = ((i-1)*parBase.nAgeGroups+1):(i*parBase.nAgeGroups);
        newDailyInfections_byEth(:, :, :, i) = permute(1/parBase.tE* ...
            (E1(:, indices_pick, :)+E2(:, indices_pick, :)), [1 3 2]);
        newDailyCases_byEth(:, :, :, i) = permute(newDailyCases(:, indices_pick, :), [1 3 2]);
        newDailyHosp_byEth(:, :, :, i) = permute(newDailyHosp(:, indices_pick, :), [1 3 2]);
        hospitalOccupancy_byEth(:, :, :, i) = permute(Hocc(:, indices_pick, :), [1 3 2]);
        newDailyDeaths_byEth(:, :, :, i) = permute(newDailyDeaths(:, indices_pick, :), [1 3 2]);
    end

    bandsData(:, :, :, :, :, j) = max(0, cat(5, ...
        newDailyInfections_byEth(:, :, 1:2:end, :) + newDailyInfections_byEth(:, :, 2:2:end, :), ...
        newDailyCases_byEth(:, :, 1:2:end, :) + newDailyCases_byEth(:, :, 2:2:end, :), ...
        newDailyHosp_byEth(:, :, 1:2:end, :) + newDailyHosp_byEth(:, :, 2:2:end, :), ...
        hospitalOccupancy_byEth(:, :, 1:2:end, :) + hospitalOccupancy_byEth(:, :, 2:2:end, :), ...
        newDailyDeaths_byEth(:, :, 1:2:end, :) + newDailyDeaths_byEth(:, :, 2:2:end, :)));


    % ----------------- IMPORT BEST FIT DATA ----------------------------------
    load(filenameBestFit{j}, 'epiVarsCompact', 'parBase', 't');
    t = datetime(t,'ConvertFrom','datenum');

    % Get variables for plotting
    [newDailyCases0, newDailyCases1, newDailyCases2, newDailyCases3, ...
        newDailyCasesr, newDailyHosp0, newDailyHosp1, newDailyHosp2, ...
        newDailyHosp3, newDailyHospr, newDailyDeaths0, newDailyDeaths1, ...
        newDailyDeaths2, newDailyDeaths3, newDailyDeathsr, Hocc, ~, ~, E1, ...
        E2, ~, ~] = getVarsToPlot(epiVarsCompact);

    % Sum over immunity status
    newDailyCases = newDailyCases0 + newDailyCases1 + newDailyCases2 + newDailyCases3 + newDailyCasesr;
    newDailyHosp = newDailyHosp0 + newDailyHosp1 + newDailyHosp2 + newDailyHosp3 + newDailyHospr;
    newDailyDeaths = newDailyDeaths0 + newDailyDeaths1 + newDailyDeaths2 + newDailyDeaths3 + newDailyDeathsr;

    % take care of multiple ethnicities by adding extra dimension
    newDailyInfections_byEth = zeros(size(newDailyCases, 1), parBase.nAgeGroups, parBase.nEthnicities); % cases
    newDailyCases_byEth = newDailyInfections_byEth; % infections
    newDailyHosp_byEth = newDailyInfections_byEth; % hospitalisations
    hospitalOccupancy_byEth = newDailyInfections_byEth; % hospital occupancy
    newDailyDeaths_byEth = newDailyInfections_byEth; % deaths
    exposed1_byEth = newDailyInfections_byEth; % cumulative first exposure
    exposed2_byEth = newDailyInfections_byEth; % cumulative second+ exposure

    for i = 1:parBase.nEthnicities % Iteratively add ethnicities (mean for pTestTS95)
        indices_pick = ((i-1)*parBase.nAgeGroups+1):(i*parBase.nAgeGroups);
        newDailyInfections_byEth(:, :, i) = 1/parBase.tE* ...
            (E1(:, indices_pick)+E2(:, indices_pick));
        newDailyCases_byEth(:, :, i) = newDailyCases(:, indices_pick);
        newDailyHosp_byEth(:, :, i) = newDailyHosp(:, indices_pick);
        hospitalOccupancy_byEth(:, :, i) = Hocc(:, indices_pick);
        newDailyDeaths_byEth(:, :, i) = newDailyDeaths(:, indices_pick);
        exposed1_byEth(:, :, i) = 1/parBase.tE*cumsum(E1(:, indices_pick), 1);
        exposed2_byEth(:, :, i) = 1/parBase.tE*cumsum(E2(:, indices_pick), 1);
    end

    bestFitData(:, :, :, :, j) = cat(5, ...
        newDailyInfections_byEth(:, 1:2:end, :) + newDailyInfections_byEth(:, 2:2:end, :), ...
        newDailyCases_byEth(:, 1:2:end, :) + newDailyCases_byEth(:, 2:2:end, :), ...
        newDailyHosp_byEth(:, 1:2:end, :) + newDailyHosp_byEth(:, 2:2:end, :), ...
        hospitalOccupancy_byEth(:, 1:2:end, :) + hospitalOccupancy_byEth(:, 2:2:end, :), ...
        newDailyDeaths_byEth(:, 1:2:end, :) + newDailyDeaths_byEth(:, 2:2:end, :), ...
        exposed1_byEth(:, 1:2:end, :) + exposed1_byEth(:, 2:2:end, :), ...
        exposed1_byEth(:, 1:2:end, :) + exposed1_byEth(:, 2:2:end, :) + ...
        exposed2_byEth(:, 1:2:end, :) + exposed2_byEth(:, 2:2:end, :));

end

% ------------------- PULL IN POPULATION NUMBERS --------------------------

popCountMatrix = parBase.popCountMatrix; % as 16 x 4 matrix
popCountMatrix10 = popCountMatrix(1:2:end, :)+popCountMatrix(2:2:end, :); % as 8 x 4 matrix (10 year age groups)
popCountVector = parBase.popCountVector; % as 64 x 1 column vector
popByEth = sum(popCountMatrix); % within each ethnicity, aggregating over age
popByAge = sum(popCountMatrix10, 2); % within each 10-year age group, aggregating over ethnicity


% ------------------- IMPORT REAL DATA ------------------------------------

tData = dataComb.date;


% Real data has the following indices:
% 1. Time
% 2. Age group (10 year bands)
% 3. Outcome: border infection data, national hospital occupancy, cases
% (other), cases (Maori), cases (Pacific), cases (Asian), admissions ... ,
% deaths ...

% Scale infections up to population
% Fudge infections and hospital occupancy to be same size matrix as other ones
realData = cat(3, [dataComb.NationalBorder/7/1e3*sum(popCountMatrix(:)) ...
    zeros(numel(dataComb.NationalBorder), 7)], ...
    [dataComb.hospOccTotalMOH zeros(numel(dataComb.NationalBorder), 7)], ...
    dataComb.nCases_O(:, 1:2:end) + dataComb.nCases_O(:, 2:2:end), ...
    dataComb.nCases_M(:, 1:2:end) + dataComb.nCases_M(:, 2:2:end), ...
    dataComb.nCases_P(:, 1:2:end) + dataComb.nCases_P(:, 2:2:end), ...
    dataComb.nCases_A(:, 1:2:end) + dataComb.nCases_A(:, 2:2:end), ...
    dataComb.nHosp_O(:, 1:2:end) + dataComb.nHosp_O(:, 2:2:end), ...
    dataComb.nHosp_M(:, 1:2:end) + dataComb.nHosp_M(:, 2:2:end), ...
    dataComb.nHosp_P(:, 1:2:end) + dataComb.nHosp_P(:, 2:2:end), ...
    dataComb.nHosp_A(:, 1:2:end) + dataComb.nHosp_A(:, 2:2:end), ...
    dataComb.nDeaths_O(:, 1:2:end) + dataComb.nDeaths_O(:, 2:2:end), ...
    dataComb.nDeaths_M(:, 1:2:end) + dataComb.nDeaths_M(:, 2:2:end), ...
    dataComb.nDeaths_P(:, 1:2:end) + dataComb.nDeaths_P(:, 2:2:end), ...
    dataComb.nDeaths_A(:, 1:2:end) + dataComb.nDeaths_A(:, 2:2:end));

end