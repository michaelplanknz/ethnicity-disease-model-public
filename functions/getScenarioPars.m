function   [useEthVaxData, assort, totalContFreq, OR_hosp, OR_death, Rt_mult] = getScenarioPars(iScenario, nEthnicities)

% Define scenarios via scenario-specific parameter
%
% OUTPUTS:
% - useEthVaxData - true to use ethnicity-sepcific vaccination data, false
% to apply average vaccination rates to all groups
% - mixMatrix - nEthnicities x nEthnicities mixing matrix describing
% relative mixing rates within and between groups (matrix of ones for proportionate
% mixing, identity matrix for within-group mixing only)
% totalContFreq - vector specifying the relative contact rates for each
% ethnicitiy group
% OR_hosp - vector specifying the odds ratio for hospitalisation for each
% group
% OR_death - vector specifying the odds ratio for death for each
% group
% Rt_mult - multiplier on R0 (relative to its default value)
%
% Note ethncity-specific variables (mixMatrix, totalContFreq, OR_hosp, OR_death)
% are always in the order  ["European", "Maori", "Pacific", "Asian"]


if iScenario == 1
    % Null four ethnicity model (same vaccination rates and no
    % ethnicity-specific mixing or severity)
    useEthVaxData = false;
    assort = 0;
    totalContFreq = ones(1, nEthnicities);
    OR_hosp = ones(1, nEthnicities);
    OR_death =  ones(1, nEthnicities);
    Rt_mult = 1;

elseif iScenario == 2
    % Ethnicity-specific vaccination rates
    useEthVaxData = true;
    assort = 0;
    totalContFreq = ones(1, nEthnicities);
    OR_hosp = ones(1, nEthnicities);
    OR_death =  ones(1, nEthnicities);
    Rt_mult = 1;

elseif iScenario == 3
    % (i) Ethnicity-specific vaccination rates 
    % (ii) severities of hospitalisation and death
    useEthVaxData = true;
    assort = 0;
    totalContFreq = ones(1, nEthnicities);
    OR_hosp = [1, 1.7, 2.3, 1];
    OR_death =  [1, 1.7, 1.6, 0.6];
    Rt_mult = 1;

elseif iScenario == 4
    % (i) Ethnicity-specific vaccination rates
    % (ii) assortative mixing
    % (iii) total contact frequency 
    useEthVaxData = true;
    assort = 0.2;
    totalContFreq = [1, 1.8, 2.8, 0.8];
    OR_hosp = ones(1, nEthnicities);
    OR_death =  ones(1, nEthnicities);
    Rt_mult = 1;

elseif iScenario == 5
    % (i) Ethnicity-specific vaccination rates
    % (ii) severities of hospitalisation and death
    % (iii) assortative mixing and total contact frequency
    useEthVaxData = true;
    assort = 0.2;
    totalContFreq = [1, 1.1, 1.5, 0.8];
    scale_factor = 0.5;
    OR_hosp = 1-scale_factor + scale_factor*[1, 1.7, 2.3, 1];
    OR_death = 1-scale_factor + scale_factor*[1, 1.7, 1.6, 0.6];
    Rt_mult = 1;
end


