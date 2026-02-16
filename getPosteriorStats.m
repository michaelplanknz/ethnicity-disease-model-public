clear
close all

% Script to read in the posterior samples for the previously fitted model
% and display some summary statistics


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Initialisation of paths, file names and global parameter settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('functions');
 
% Name of the file containing the previous results of the parameter fitting process
fNameParams = sprintf('parameter_fitting_results/parameter_results.mat');

% CrI width to report
intervalQt = 0.95;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Posterior parameter distribution loading 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in fitted parameter sets (in table Theta100) and associated error metric (in dUniFiltered100) 
fprintf('\nLoading fitted parameter sets...\n')
load(fNameParams, 'Theta100', 'dUniFiltered100');


% Read the names of the fitted parameters from the saved results file:
parsToFit = Theta100.Properties.VariableNames;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Create a table with the mean and 95% CrI for each parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Functions to add a zero-centred random variable to selected parameters
% according to random deviates [0,1] specified in input parameter Theta
plusMinus = @(z, r)(2*r*z - r);                     % uniform perturbation between +/- r, z is a random deviate [0,1]
plusMinusInt = @(z, r)(floor((2*r+1)*z) - r );      % uniform perturbation on integers between +/- r, z is a random deviate [0,1]

nPars = length(parsToFit);
nVals = height(Theta100);

parName = repmat("", nPars, 1);
parVals = zeros(nPars, nVals);
parUnit = repmat("", nPars, 1);
parDispType = repmat("", nPars, 1);


% For each parameter, specify table enrty for parameter name and units, calculate
% numeric values for each saved sample, and formatting display type (int,
% 2dp or 4dp)
iCounter = 1;
parName(iCounter) = "Outbreak seed date";
parVals(iCounter, :) = 18 + plusMinusInt(Theta100.dateSeed, 3); 
parUnit(iCounter) = "days";
parDispType(iCounter) = "int";

iCounter = iCounter+1;
parName(iCounter) = "R_e(t) in period 1";
parVals(iCounter, :) = 3.25 * (0.68 + plusMinus(Theta100.Cstart, 0.1));
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "Period 1-2 ramp start date";
parVals(iCounter, :) = 68 + plusMinusInt(Theta100.rampStart, 5); 
parUnit(iCounter) = "days";
parDispType(iCounter) = "int";

iCounter = iCounter+1;
parName(iCounter) = "Period 1-2 ramp window";
parVals(iCounter, :) = 55 + plusMinusInt(Theta100.rampDays, 20);
parUnit(iCounter) = "days";
parDispType(iCounter) = "int";

iCounter = iCounter+1;
parName(iCounter) = "R_e(t) in period 2";
parVals(iCounter, :) = 3.25 * (1.1 + plusMinus(Theta100.Cramp, 0.21));
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "Period 2-3 ramp start date";
parVals(iCounter, :) = 257 + plusMinusInt(Theta100.ramp2Start, 5); 
parUnit(iCounter) = "days";
parDispType(iCounter) = "int";

iCounter = iCounter+1;
parName(iCounter) = "Period 2-3 ramp window";
parVals(iCounter, :) = 10 + plusMinusInt(Theta100.ramp2Days, 9);
parUnit(iCounter) = "days";
parDispType(iCounter) = "int";

iCounter = iCounter+1;
parName(iCounter) = "Period 2-3 factor increase in R_e(t)";
parVals(iCounter, :) = 1.2 + plusMinus(Theta100.Cramp2, 0.1);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "Contact matrix relaxation factor";
parVals(iCounter, :) = 0.4 + plusMinus(Theta100.relaxAlpha, 0.4);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "Contact matrix relaxation window";
parVals(iCounter, :) = 70 + plusMinusInt(Theta100.MRampDays, 20);
parUnit(iCounter) = "days";
parDispType(iCounter) = "int";

iCounter = iCounter+1;
parName(iCounter) = "Testing probability multiplier";
parVals(iCounter, :) = 1 + plusMinus(Theta100.pTestMult, 0.2);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "IFR probability multiplier";
parVals(iCounter, :) = 1 + plusMinus(Theta100.IFR, 0.5);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "IHR probability multiplier";
parVals(iCounter, :) = 1 + plusMinus(Theta100.IHR, 0.5);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "Immunity waning rate";
parVals(iCounter, :) = 0.0045 * (1 + plusMinus(Theta100.waneRate, 0.5));
parUnit(iCounter) = "(day-1)";
parDispType(iCounter) = "4dp";

iCounter = iCounter+1;
parName(iCounter) = "BA.5 immune evasion";
parVals(iCounter, :) = 0.4 + plusMinus(Theta100.vocWane, 0.3);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

iCounter = iCounter+1;
parName(iCounter) = "Antiviral effect on IFR";
parVals(iCounter, :) = 0.5 + plusMinus(Theta100.aViralEffect, 0.1);
parUnit(iCounter) = "";
parDispType(iCounter) = "2dp";

% Calculate median and lower and upper quantiles for each parameter
parLevels = quantile(parVals, [0.5, (1-intervalQt)/2, (1+intervalQt)/2], 2 );

parText = repmat("", nPars, 1);
for iRow = 1:nPars
    if parDispType(iRow) == "int"
        parText(iRow) = sprintf('%.0f [%.0f, %.0f] %s', parLevels(iRow, :),  parUnit(iRow));
    elseif parDispType(iRow) == "2dp"
        parText(iRow) = sprintf('%.2f [%.2f, %.2f] %s', parLevels(iRow, :), parUnit(iRow));
    elseif parDispType(iRow) == "4dp"
        parText(iRow) = sprintf('%.4f [%.4f, %.4f] %s', parLevels(iRow, :), parUnit(iRow));        
    end
end

% Make table
tbl = table(parName, parText);
tbl = renamevars(tbl, {'parName', 'parText'}, {'Parameter', 'Posterior'});

% Save table as CSV file
writetable(tbl, 'figures/posterior_table.csv');


