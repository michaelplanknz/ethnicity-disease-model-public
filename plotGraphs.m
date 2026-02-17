clear 
close all

% Script for plotting graphs of model results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('functions');

% Flag for running sensitivity
% Set to false to use the HSU population, or true to use the ERP population
sensitivity = false;

% Names of the model scenarios to read in and plot
scenario_names = ["1. Baseline"; "2. Vaccines"; "3. Vaccines-severity"; "4. Vaccines-mixing"; "5. Vaccines-severity-mixing"];

% Ethnicity names
eth_names = ["European"; "Māori"; "Pacific"; "Asian"]; 

% Whether to plot relevant graphs as per capita rates or absolute numbers
perCapita = true;      

% If true, any previous figure with the same name will be overwritten
overwriteFig = false;   

% End date for plotting and calculation of cumulative results
plotToDate = datetime(2023, 6, 30);    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Loading results and preparting data for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get data file names
[myDataPath, dataFileNames] = getDataFileNames(sensitivity);

% Read data for plotting
dataComb = getAllData(myDataPath, dataFileNames); 

% Specify file names containing model results
nScenarios = numel(scenario_names); 
filenameBands = cell(1, nScenarios);
filenameBestFit = filenameBands;
for jj = 1:nScenarios
    if sensitivity == false
        filenameBands{jj} = sprintf('output/Scenario_%s_95_fit.mat', scenario_names(jj));
        filenameBestFit{jj} = sprintf('output/Scenario_%s_Best_fit.mat', scenario_names(jj));
        figDir = 'figures/HSU/';
    elseif sensitivity == true
        filenameBands{jj} = sprintf('output/Scenario_%s_95_sensitivity.mat', scenario_names(jj));
        filenameBestFit{jj} = sprintf('output/Scenario_%s_Best_sensitivity.mat', scenario_names(jj));
        figDir = 'figures/ERP/';
    end
end


% Load data and pull out info beforehand to speed up plots
[t, bandsData, bestFitData, tData, realData, popCountMatrix, ...
    popCountMatrix10, popCountVector, popByEth, popByAge] = ...
    summariseScenarioRuns(filenameBands, filenameBestFit, dataComb);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Call plotting functions for each type of graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot aggregated and age-split plots for base scenario
% Aggregated plots
plotModelComparison(t, bandsData, bestFitData, tData, realData, popCountVector, plotToDate, scenario_names, overwriteFig, perCapita, figDir);

% Plots split up by age (aggregate ethnicities)
plotModelComparisonAgeSplit(t, bandsData, bestFitData, tData, realData, popByAge, plotToDate, scenario_names, overwriteFig, perCapita, figDir);


% Leaving these plots out for now
% Ethnicity comparisons (single models)
% for jj = 1:nScenarios
%     plotEthnicityComparison(t, bandsData, bestFitData, tData, realData, popByEth, plotToDate, eth_names, scenario_names, scenario_names{jj}, overwriteFig, perCapita, figDir);
% end

% age splits 
% for jj = 1:nScenarios
%    plotEthnicityComparisonAgeSplit(t, bandsData, bestFitData, tData, realData, popByEth, popCountMatrix10, plotToDate, eth_names, scenario_names, scenario_names{jj}, overwriteFig, perCapita, figDir);
% end

% Split models by ethnicity

% Subset of scenarios to plot in the next graph (make this 1:nScenarios to
% plot all of them)
scenariosToPlot = [1, 3, 4, 5];

% Aggregated plots (set last argument to false for absolute numbers, true for per capita)
plotModelComparisonByEthnicity(t, bandsData, bestFitData, tData, realData, popByEth, plotToDate, scenario_names, eth_names, overwriteFig, perCapita, scenariosToPlot, figDir);

% Split by age
plotModelComparisonAgeSplitByEthnicity(t, bandsData, bestFitData, tData, realData, popCountMatrix10, popByEth, plotToDate, scenario_names, eth_names, overwriteFig, perCapita, figDir);
 
% Get cumulative tables out at certain date and plot
[outTab, outTabAge, cumData, cumDataAge] = cumulativeMetricsByModel(t, bandsData, tData, realData, plotToDate, scenario_names, eth_names);

% Plot results
plotCumulativeSummary(outTab, outTabAge, cumData, cumDataAge, popCountMatrix10, popByEth, overwriteFig, perCapita, figDir);

