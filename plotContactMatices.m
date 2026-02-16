
% Script to plot contact matrices for the model

clear
close all

addpath('functions');

% Flag for running sensitivity
% Set to false to use the HSU population, or true to use the ERP population
sensitivity = false;    


% Get data file names
[myDataPath, dataFileNames] = getDataFileNames(sensitivity);

% Get population data
nAgeGroups = 16;
nEthnicities = 4;
[popCountMatrix, ethnicityLabels] = getPopData(myDataPath + dataFileNames.popSizeFname, nAgeGroups, nEthnicities); 

% Read Prem matrix
C = readmatrix(myDataPath + dataFileNames.CMdataFname);

% Get matrix for scenario 1 (proportionate mixing)
iScenario = 1;
[~, assort, totalContFreq, ~, ~, ~] = getScenarioPars(iScenario, nEthnicities);
C_detBal_PM = calcContactMatrix(C, popCountMatrix, assort, totalContFreq); 

% Get matrix for scenario 4 (ethnicity-specific contact rates and assortative mixing)
iScenario = 4;
[useEthVaxData, assort, totalContFreq, OR_hosp, OR_death, Rt_mult] = getScenarioPars(iScenario, nEthnicities);
C_detBal_scenario = calcContactMatrix(C, popCountMatrix, assort, totalContFreq); 

% Plot matrices
h = figure(1);
h.Position = [508          65         620        1003];
tiledlayout(2, 1, 'TileSpacing', 'compact');
nexttile;
imagesc(C_detBal_PM);
clim([0 9])
colorbar;
xlabel('group contact to')
ylabel('group contact from')
ha = gca;
ha.XTick = nAgeGroups/2 + nAgeGroups*(0:(nEthnicities-1));
ha.XTickLabel = ethnicityLabels;
ha.YTick = nAgeGroups/2 + nAgeGroups*(0:(nEthnicities-1));
ha.YTickLabel = ethnicityLabels;
title('(a) scenarios 1-3, proportionate mixing')
nexttile;
imagesc(C_detBal_scenario);
clim([0 9])
colorbar;
xlabel('group contact to')
ylabel('group contact from')
ha = gca;
ha.XTick = nAgeGroups/2 + nAgeGroups*(0:(nEthnicities-1));
ha.XTickLabel = ethnicityLabels;
ha.YTick = nAgeGroups/2 + nAgeGroups*(0:(nEthnicities-1));
ha.YTickLabel = ethnicityLabels;
title('(b) scenario 4, ethnicity-specific mixing')

% Save figures
saveas(h, 'figures/contact_matrices.png');
