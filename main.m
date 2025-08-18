%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            ODE model for Omicron outbreak in New Zealand
%       with parameter uncertainty quantification via simple ABC
%
% This script reads in fitted parameters for a model without ethnicity
% stratification (see Datta et al. 2024) and runs a selection of
% ethnicity-stratified models with different ethnicity effects
%
% The population is split into 4 ethnicity groups: Maori, Pacific, Asian
% and European/other.
% This leads to 16x4 = 64 age-ethnicity combinations and so arrays of size
% 16 in the non-ethnicity model are replaced by arrays of size 64.
% By convention, these are ordered throughout as:
% [age_1 eth_1, age_2 eth_1, ... , age_15 eth_4, age_16 eth 4].
% The ethnicity groups are ordered:
% (1) European/other, (2) Maori, (3) Pacific, (4) Asian.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Initialisation of paths, file names and global parameter settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all

addpath('functions');

% Flag for running sensitivity
% Set to false to use the HSU population, or true to use the ERP population
sensitivity = false;    

% Number of parameter combinations to run for each scenario
% Set to zero to run all parameter sets, or a positive integer to run a specified number of parameter sets only
fewer_runs = 0; 

% Specify which trajectory to save as the "best fit" trajectory
% Set to "lowest err" to use the trajectory with lowes error (smallest
% value of 'dUniFiltered') in the prior fitting routine
% Set to "post mean" to use the mean of the posterior parameter set
best_fit_option = "post mean";

% Name of the file containing the previous results of the parameter fitting process
fNameParams = sprintf('parameter_fitting_results/parameter_results.mat');

% End of simulation date
% needs to be 6th August 2023 or later, otherwise crashes (related to antivirals)
tModelRunTo = datenum('06-Aug-2023'); 

% Scenario names
scenario_names = ["1. Baseline"; "2. Vaccines"; "3. Vaccines-severity"; "4. Vaccines-mixing"; "5. Vaccines-severity-mixing"];

% Ethnicity names
eth_names = ["European"; "Māori"; "Pacific"; "Asian"]; 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Posterior parameter distribution loading 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get data file names
[myDataPath, dataFileNames] = getDataFileNames(sensitivity);


% Read in fitted parameter sets (in table Theta100) and associated error metric (in dUniFiltered100) 
fprintf('\nLoading fitted parameter sets...\n')
load(fNameParams, 'Theta100', 'dUniFiltered100');




% Read the names of the fitted parameters from the saved results file:
parsToFit = Theta100.Properties.VariableNames;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Scenario simulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Trajectories to save ("95" = trajectories below the 95th pc of the distance
% function, "Best" = trajectory with the smallest distance function)
intervalQt = 0.95;
labels = [string(100*intervalQt), "Best"];


% Only need to run the model the "best x percent" of parameter sets
% (x=95) so create a set of filtered parameters combinations Theta
% with associated dUniFiltered
condition = dUniFiltered100 <= quantile(dUniFiltered100, intervalQt);

Theta = Theta100(condition, :);
dUniFiltered = dUniFiltered100(condition);

% Set number of runs
num_runs = length(dUniFiltered);
if fewer_runs > 0 && fewer_runs < num_runs
    % Do fewer runs
    num_runs = fewer_runs;
    % Truncate Theta and dUniFiltered variables to the number of samples run:
    Theta = Theta(1:num_runs, :);
    dUniFiltered = dUniFiltered(1:num_runs);
end


nScenarios = numel(scenario_names); 
nEthnicities = length(eth_names);


% Run multiple scenarios (model variations)
for iScenario = 1:nScenarios 

    fprintf('Scenario %i of %i\n', iScenario, nScenarios);

    % Get scenario-specific parameters
    [useEthVaxData, assort, totalContFreq, OR_hosp, OR_death, Rt_mult] = getScenarioPars(iScenario, nEthnicities);

    % Get base parameter set common to all simulations for this scenario
    parBase = getBasePar(tModelRunTo, myDataPath, dataFileNames, nEthnicities, useEthVaxData, assort, totalContFreq, OR_hosp, OR_death, Rt_mult);

    % Vector of dates for which the model will be run
    t = parBase.tBase;

    % Set odeOptions (needs a dummy IC so that the size of the solution is
    % vector is known)
    dummyIC = getIC(parBase);
    odeOptions = odeset('NonNegative', ones(size(dummyIC))' );

    % Run current scenario for all best 1% fitted runs
    parfor iSample = 1:num_runs % test on small number of samples
        fprintf('Sample %i of %i\n', iSample, length(dUniFiltered))
        epiVarsCompact(iSample) = runOneSim(t, parBase, Theta(iSample, :), odeOptions );
    end

    % Save all simulated trajectories (best x pc)
    if sensitivity == 0
        fOut = sprintf('output/Scenario_%s_%s_fit.mat', scenario_names(iScenario), labels(1));
    elseif sensitivity == 1
        fOut = sprintf('output/Scenario_%s_%s_sensitivity.mat', scenario_names(iScenario), labels(1));
    end
    save(fOut, 't', 'epiVarsCompact', 'Theta', 'parBase', 'dUniFiltered');

    % Store the full Theta and dUniFiltered temporarily before saving the
    % 'best' trajectory
    ThetaSav = Theta;
    dUniFilteredSav = dUniFiltered;

    if best_fit_option == "lowest err"
        % Store trajectory with the lowst value of dUniFiltered in Theta,
        % epiVarsCompact, etc. ready for saving
        [~, condition] = min(dUniFiltered);
        Theta = Theta(condition, :);
        dUniFiltered = dUniFiltered(condition);
        epiVarsCompact = epiVarsCompact(condition);
    elseif best_fit_option == "post mean"
        % Run a new simulation using the posterior mean parameter values
        % (mean of Theta)

        % Calculate mean of Theta (and remove the prefix "mean_" that varfun applies to the variable
        % names)
        ThetaMean = removePrefix(varfun(@mean, Theta100));
        epiVarsCompact = runOneSim(t, parBase, ThetaMean, odeOptions );

        % Save dUniFiltered as NaN to indicate that there is no known error
        % funciton value for this trajectory as it was not run as part of
        % the original fitting procedures
        dUniFiltered = NaN;

        % Temporarily store ThetaMean in Theta for saving
        Theta = ThetaMean;
    else
        error('best_fit_option must be wither "lowest err" or "post mean"');
    end

    % Save the 'best fit' trajectory to file
    if sensitivity == 0
        fOut = sprintf('output/Scenario_%s_%s_fit.mat', scenario_names(iScenario), labels(2));
    elseif sensitivity == 1
        fOut = sprintf('output/Scenario_%s_%s_sensitivity.mat', scenario_names(iScenario), labels(2));
    end
    save(fOut, 't', 'epiVarsCompact', 'Theta', 'parBase', 'dUniFiltered');

    % Restore full Theta and dUniFiltered
    Theta = ThetaSav;
    dUniFiltered = dUniFilteredSav;
end

fprintf('Simulations finished.\n');

